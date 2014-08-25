//
//  BTChatViewController.m
//  SayAbout
//
//  Created by admin on 14-8-18.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import "AppDelegate.h"
#import "XHFoundationCommon.h"

#import "XHNewsTableViewController.h"
#import "XHQRCodeViewController.h"

#import "XHPopMenu.h"
#import "UIView+XHBadgeView.h"

#import "MultiSelectItem.h"
#import "MultiSelectViewController.h"
#import "XHBaseNavigationController.h"

#import "SBJsonParser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Toast+UIView.h"

#import "BTApplication.h"
#import "BTChatViewController.h"
#import "BTChatTableViewCell.h"
#import "BTChatMessageTableViewController.h"

@interface BTChatViewController ()

@end

@implementation BTChatViewController

Boolean _isLoading;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if (_refreshHeaderView == nil)
    {
      EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 10.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.view.bounds.size.height)];
      view1.delegate = self;
        [self.tableView addSubview:view1];
        _refreshHeaderView = view1;
    }
    
    [_refreshHeaderView refreshLastUpdatedDate];

    [self load_topics:self._page_cur + 1];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    _refreshHeaderView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ChatViewCell";
    BTChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[BTChatTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.titleLabel.font = [UIFont systemFontOfSize:20];
        cell.createrLabel.font = [UIFont systemFontOfSize:14];
        cell.timeLabel.font = [UIFont systemFontOfSize:14];
        
        cell.createrLabel.textColor = [UIColor grayColor];
        cell.timeLabel.textColor = [UIColor grayColor];
    }
    
    if (indexPath.row < self.dataSource.count)
    {
        
        // 修改为新的消息结构 蒲剑
        NSDictionary *topic = self.dataSource[indexPath.row];
        
        cell.titleLabel.text = [topic objectForKey:@"content"];
        cell.createrLabel.text = [topic objectForKey:@"sender"];
        cell.timeLabel.text = [topic objectForKey:@"time_samp"];
        
        AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        NSString *url = [@"" stringByAppendingFormat:@"%@%@%@", delegate._http,delegate._server, [topic objectForKey:@"avatar"]];
        
        cell.imageView.image = [[ UIImage alloc]initWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:url]] ];

    }
    
    [cell.imageView setupCircleBadge];
    
    return cell;
    
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *topic = self.dataSource[indexPath.row];
    
    [self enterMessage: topic];
}


#pragma mark - EGORefreshTableHeaderDelegate
- (void)reloadTableViewDataSource
{
    NSLog(@"==开始加载数据");
    _reloading = YES;
}

- (void)doneLoadingTableViewData
{
    NSLog(@"doneLoadingTableViewData");
    //NSLog(@"===加载完数据");
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    NSLog(@"egoRefreshTableHeaderDidTriggerRefresh");
    
    [self reloadTableViewDataSource];
    [self load_topics:self._page_cur + 1];
}

//返回当前是刷新还是无刷新状态
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    NSLog(@"egoRefreshTableHeaderDataSourceIsLoading");
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    NSLog(@"egoRefreshTableHeaderDataSourceLastUpdated");
    return [NSDate date];
}


#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // NSLog(@"scrollViewDidScroll");
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // NSLog(@"scrollViewDidEndDragging");
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - load chats
- (void)load_topics: (int) page
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    int order = -1;
    int perpage = 5;
    
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@%@%d%@%d%@%d", delegate._http,delegate._server, @"/chats", @"?page=",page,@"&order=",order,@"&perpage=",perpage];
    
    NSURL *url = [NSURL URLWithString:strURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setUseCookiePersistence : YES];
    [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    
    request.delegate = self;
    request.didFinishSelector = @selector(load_topics_finished:);
    request.didFailSelector = @selector(load_topics_failed:);
    [request startAsynchronous];
}

- (void)load_topics_finished:(ASIHTTPRequest *)request
{
    NSString *topics_str = [request responseString];
    NSLog(@"topics_str : %@", topics_str);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:topics_str];
    if (!json)
    {
        NSLog(@"cleaned...");
        [self.view makeToast:@"加载数据格式错误，请检查网络及手机是否工作正常。"];
    }
    else
    {
        int s_pages = [(NSString*)[json objectForKey:@"pages"] intValue];
        int s_page = [(NSString*)[json objectForKey:@"page"] intValue];
        
        // NSMutableArray *dataSource = [[NSMutableArray alloc] init];
        
        NSArray *items = [json objectForKey:@"items"];
        for(int i=(items.count - 1);i>=0;i--)
        
        {
            NSDictionary *item = [items objectAtIndex:(i)];
            
            NSDictionary *creator = [item objectForKey:@"_creator"];
            NSMutableArray *persons = [item objectForKey:@"_persons"];
            NSMutableArray *personnames = [[NSMutableArray alloc]init];
            NSString *avatar = @"";
            NSString *sender = @"";
            for(int k=0;k<persons.count;k++)
            {
                NSDictionary *p = (NSDictionary *)[persons objectAtIndex:k];
                [personnames addObject:[p objectForKey:@"name"]];
                if(k==0)
                {
                    avatar = (NSString *)[p objectForKey:@"avatar"];
                }
                else
                {
                    avatar = (NSString *)[p objectForKey:@"qunliao"];
                }
            }
            
            // 判断发送人是否是当前用户
            AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
            if (delegate._userid==[creator objectForKey:@"_id"])
            {
                
            }
            else
            {
                sender = [creator objectForKey:@"name"];
                avatar = [creator objectForKey:@"avatar"];
            }
            
            NSMutableDictionary *topic = [[NSMutableDictionary alloc]init];
            NSNumber *newnum = [NSNumber numberWithInt:1]; // 后期细化
            
            [topic setValue:[item objectForKey:@"_id"]  forKey:@"id"];
            [topic setValue:[item objectForKey:@"title"]  forKey:@"content"];
            
            [topic setValue:avatar forKey:@"avatar"];
            [topic setValue:sender forKey:@"sender"];
            [topic setValue:[item objectForKey:@"updateAt"] forKey:@"time_samp"];
            [topic setValue:newnum forKey:@"newnum"];
            
            [self.dataSource addObject:topic];
        }
        
        self._page_cur = s_page;
        self._pages_cur = s_pages;
        
        [self.tableView reloadData];
        [self doneLoadingTableViewData];
    }
}

- (void)enterMessage:(NSDictionary *) topic {
    
    NSString *topicid = (NSString *)[topic objectForKey:@"id"];
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate._chatmessage_topic = topic;
    delegate._chatmessage_topicid = topicid;
    
    BTChatMessageTableViewController *messageTableViewController = [[BTChatMessageTableViewController alloc] init];
    
    messageTableViewController.title = @"";
    
    messageTableViewController._topic_id_cur = topicid;
    
    [self.navigationController pushViewController:messageTableViewController animated:YES];
}

- (void)load_topics_failed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error localizedFailureReason]);
    [self.view makeToast:@"加载数据失败，请检查网络及手机是否工作正常。"];

    [self.tableView reloadData];
    [self doneLoadingTableViewData];
}

@end

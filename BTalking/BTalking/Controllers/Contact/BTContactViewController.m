//
//  ContactTableViewController.m
//  SayAbout
//
//  Created by admin on 14-8-19.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import "XHPopMenu.h"
#import "UIView+XHBadgeView.h"

#import "MultiSelectItem.h"
#import "MultiSelectViewController.h"
#import "XHBaseNavigationController.h"

#import "SBJsonParser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Toast+UIView.h"

#import "AppDelegate.h"
#import "BTApplication.h"
#import "BTContactViewController.h"
#import "BTContactTableViewCell.h"
#import "BTContactInfoViewController.h"
#import "BTFriendFindAddViewController.h"


@interface BTContactViewController ()


@property (nonatomic, strong) NSMutableArray *dataSource;



@end

@implementation BTContactViewController

@synthesize tableView, btn_select;

static const int _ReqSelectPeople = 0;

+(int) ReqSelectPeople
{
    return _ReqSelectPeople;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(!self.dataSource)
    {
       self.dataSource = [[NSMutableArray alloc]init];
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

//    if (_refreshHeaderView == nil)
//    {
//        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 10.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.view.bounds.size.height)];
//        view1.delegate = self;
//        [self.tableView addSubview:view1];
//        _refreshHeaderView = view1;
//    }
//    
//    [_refreshHeaderView refreshLastUpdatedDate];
    
    [self load_topics:self._page_cur + 1];
    
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
    static NSString *cellIdentifier = @"ContactViewCellIdentifier";
    BTContactTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[BTContactTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.lb_username.font = [UIFont systemFontOfSize:20];
        cell.lb_loginname.font = [UIFont systemFontOfSize:14];

    }
    
    if (indexPath.row < self.dataSource.count)
    {
        
        // 修改为新的消息结构 蒲剑
        NSDictionary *topic = self.dataSource[indexPath.row];
        
        cell.lb_loginname.text = [topic objectForKey:@"username"];
        cell.lb_username.text = [topic objectForKey:@"name"];
        
        AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        NSString *url = [@"" stringByAppendingFormat:@"%@%@%@", delegate._http,delegate._server, [topic objectForKey:@"avatar"]];
        
        cell.iv_avatar.image = [[ UIImage alloc]initWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:url]] ];
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
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *topic = self.dataSource[indexPath.row];
    
    [self enter_contact: topic];
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



- (IBAction)select_contact:(id)sender {
    BTFriendFindAddViewController *findfriendTableViewController = [[BTFriendFindAddViewController alloc] init];
    self.mRequestId = _ReqSelectPeople;
    findfriendTableViewController.mResponseId = _ReqSelectPeople;
    
    findfriendTableViewController.delegate = self;
    [self.navigationController pushViewController:findfriendTableViewController animated:YES];
}


- (void)load_topics: (int) page
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@", delegate._http,delegate._server, @"/contact"];
    NSURL *url = [NSURL URLWithString:strURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
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
        

        
        NSMutableArray *dataSource = [[NSMutableArray alloc] init];
        
        NSDictionary *groups = [json objectForKey:@"friends"];
        
        NSMutableArray *allitems = [[NSMutableArray alloc] init];

        NSEnumerator *enums = [groups keyEnumerator];
        
        //定义一个不确定类型的对象
        NSString *groupname;
        //遍历输出
        while(groupname = [enums nextObject])
        {
            NSMutableArray *items = [groups objectForKey:groupname];

            for(int i=0;i<[items count];i++)
            {
                NSDictionary *item = [items objectAtIndex:i];
                
                NSString *userid = [item objectForKey:@"userid"];
                NSString *username = [item objectForKey:@"username"];
                NSString *name = [item objectForKey:@"name"];
                NSString *avatar = [item objectForKey:@"avatar"];
                
                
                NSMutableArray *depts = [item objectForKey:@"depts"];
                
                NSString *dept = @"";
                if(depts.count>0)
                {
                    dept = [[depts objectAtIndex:0] objectForKey:@"name"];
                }
                
                NSMutableDictionary *contact = [[NSMutableDictionary alloc]init];
                
                [contact setValue:userid  forKey:@"id"];
                [contact setValue:username  forKey:@"username"];
                [contact setValue:name  forKey:@"name"];
                [contact setValue:avatar  forKey:@"avatar"];
                [contact setValue:dept  forKey:@"dept"];
                
                [dataSource addObject:contact];
            }
        }
        
        self.dataSource = dataSource;
        
        self._page_cur = s_page;
        self._pages_cur = s_pages;
        
        [self.tableView reloadData];
        [self doneLoadingTableViewData];
    }
    
}

- (void)enter_contact:(NSDictionary *) topic {
    
    NSString *userid = (NSString *)[topic objectForKey:@"id"];

    
    BTContactInfoViewController *contactinfoViewController = [[BTContactInfoViewController alloc] init];
    
    contactinfoViewController.title = @"";
    
    contactinfoViewController._userid = userid;
    
    [self.navigationController pushViewController:contactinfoViewController animated:YES];
}




#pragma mark - OnResultValueDelegate

-(void)on_result_value:(NSDictionary *) values requestId:(NSInteger) requestId; //
{
    self._page_cur = 0;
    self._pages_cur = 0;
    
    [self load_topics:self._page_cur + 1];
    
}



@end

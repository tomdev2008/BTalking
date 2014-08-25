//
//  XHMessageRootViewController.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-26.
//  Copyright (c) 2014年 蒲剑 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "AppDelegate.h"
#import "BTTopicViewController.h"

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
#import "REMenu.h"

#import "BTApplication.h"
#import "BTTopicTableViewCell.h"
#import "BTMeetingCreateViewController.h"
#import "BTTaskCreateViewController.h"
#import "BTChatMessageTableViewController.h"
#import "BTSetViewController.h"
#import "Httptools.h"

@interface BTTopicViewController ()

@property (nonatomic, strong) XHPopMenu *popMenu;

@end

@implementation BTTopicViewController

@synthesize _querystring;

Boolean _isLoading;

UIViewController *uiviewController; //测试

#pragma mark - Propertys

- (XHPopMenu *)popMenu {
    if (!_popMenu) {
        NSMutableArray *popMenuItems = [[NSMutableArray alloc] initWithCapacity:6];
        for (int i = 0; i < 5; i ++) {
            NSString *imageName;
            NSString *title;
            switch (i) {
                case 0: {
                    imageName = @"contacts_add_friend";
                    title = @"添加会议";
                    break;
                }
                case 1: {
                    imageName = @"contacts_add_voip";
                    title = @"添加任务";
                    break;
                }
                case 2: {
                    imageName = @"contacts_add_newmessage";
                    title = @"发起私聊";
                    break;
                }
                default:
                    break;
            }
            
            XHPopMenuItem *popMenuItem = [[XHPopMenuItem alloc] initWithImage:[UIImage imageNamed:imageName] title:title];
            [popMenuItems addObject:popMenuItem];
        }
        
        WEAKSELF
        _popMenu = [[XHPopMenu alloc] initWithMenus:popMenuItems];
        _popMenu.popMenuDidSlectedCompled = ^(NSInteger index, XHPopMenuItem *popMenuItems) {
            if (index == 0) {
                [weakSelf meeting_create];
            }else if (index == 1 ) {
                [weakSelf task_create];
            }
            else if (index == 2 ) {
                [weakSelf chat_create];
            }
        };
    }
    return _popMenu;
}

#pragma mark - Propertys

- (XHPopMenu *)popMenuSet {
    if (!_popMenu) {
        NSMutableArray *popMenuItems = [[NSMutableArray alloc] initWithCapacity:6];
        for (int i = 0; i < 5; i ++) {
            NSString *imageName;
            NSString *title;
            switch (i) {
                case 0: {
                    imageName = @"contacts_add_friend";
                    title = @"test";
                    break;
                }
                case 1: {
                    imageName = @"contacts_add_voip";
                    title = @"设置";
                    break;
                }
                default:
                    break;
            }
            XHPopMenuItem *popMenuItem = [[XHPopMenuItem alloc] initWithImage:[UIImage imageNamed:imageName] title:title];
            [popMenuItems addObject:popMenuItem];
        }
        
        WEAKSELF
        _popMenu = [[XHPopMenu alloc] initWithMenus:popMenuItems];
        _popMenu.popMenuDidSlectedCompled = ^(NSInteger index, XHPopMenuItem *popMenuItems) {
            if (index == 0) {
                [weakSelf meeting_create];
            }else if (index == 1 ) {
                [weakSelf task_create];
            }
            else if (index == 2 ) {
                [weakSelf chat_create];
            }
        };
    }
    return _popMenu;
}


- (void)meeting_create
{

    BTMeetingCreateViewController *meetingCreateViewController = [[BTMeetingCreateViewController alloc] init];
    [self.navigationController pushViewController:meetingCreateViewController animated:YES];
}

- (void)task_create
{
    BTTaskCreateViewController *taskCreateViewController = [[BTTaskCreateViewController alloc] init];
    [self.navigationController pushViewController:taskCreateViewController animated:YES];
    
}

- (void)chat_create
{
    self.mRequestId = BTChatCreateSelectPeople;
    BTFriendFindViewController *findfriendTableViewController = [[BTFriendFindViewController alloc] init];
    findfriendTableViewController.delegate = self;
    [self.navigationController pushViewController:findfriendTableViewController animated:YES];
}

- (void)go_set
{
    BTSetViewController *setViewController = [[BTSetViewController alloc] init];
    [self.navigationController pushViewController:setViewController animated:YES];
}


#pragma mark - DataSource

- (void)load_topics: (int) page
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    int order = -1;
    int perpage = 5;
    
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@%@%d%@%d%@%d", delegate._http,delegate._server, @"/docs", @"?page=",page,@"&order=",order,@"&perpage=",perpage];
    
    NSString *params = [HttpTools method_get_params:self._querystring];
    strURL = [strURL stringByAppendingFormat:@"%@", params];
    
    NSURL *url = [NSURL URLWithString:strURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setUseCookiePersistence : YES];
    [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [request setValidatesSecureCertificate:NO];
    
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
        
        NSArray *items = [json objectForKey:@"items"];
        for(int i=0;i<[items count];i++)
        {
            NSDictionary *topic = [items objectAtIndex:(i)];
            [self.dataSource addObject:topic];
        }
        
        self._page_cur = s_page;
        self._pages_cur = s_pages;
        
        [self.tableView reloadData];
        [self doneLoadingTableViewData];
    }
}

- (void)load_topics_failed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error localizedFailureReason]);
    [self.view makeToast:@"网络访问失败，请检查网络及手机是否工作正常。"];

    [self.tableView reloadData];
    [self doneLoadingTableViewData];
}


#pragma mark - Life Cycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *item_topic = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(show_menu_topic)];
    
    UIBarButtonItem *item_set = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(show_menu_set)];
    
    self.navigationItem.rightBarButtonItems = @[item_set, item_topic];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TopicViewCellIdentifier";
    BTTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell)
    {
        cell = [[BTTopicTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
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
        
        NSString *title = [topic objectForKey:@"title"];
        //NSString *topicid = [topic objectForKey:@"_id"];
        NSString *createtime = [topic objectForKey:@"createAt"];
        NSString *creatercname = [[topic objectForKey:@"_creator"] objectForKey:@"name"];
        
        cell.titleLabel.text = title;
        cell.createrLabel.text = creatercname;
        cell.timeLabel.text = createtime;
        
        int ctype = [(NSNumber *)[topic objectForKey:@"type"] intValue];
        switch (ctype) {
            case BTTopicTypeMeeting:
            {
                cell.typeImage.image = [UIImage imageNamed:@"ic_meeting.png"];
                break;
            }
            case BTTopicTypeTask:
            {
                cell.typeImage.image = [UIImage imageNamed:@"ic_task.png"];
                break;
            }
            default:
                break;
        }
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

#pragma mark - PassMeetingValue Delegate

-(void)set_people_values:(NSMutableArray *)users requestId:(NSInteger)requestId
{
    NSString *uids = @"";
    
    for(int i=0;i<users.count;i++)
    {
        NSDictionary *user = (NSDictionary*)[users objectAtIndex:i];
        NSString *uid = (NSString*)[user objectForKey:@"_id"];
        
        uids = [uids stringByAppendingFormat:@"%@", uid];
        if(i<users.count-1)
        {
            uids = [uids stringByAppendingFormat:@"%@", @","];

        }
    }
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@", delegate._http,delegate._server, @"/pchats"];
    NSURL *url = [NSURL URLWithString:strURL];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence : YES];
    [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:uids forKey:@"personsList"];
    
    request.delegate = self;
    request.didFinishSelector = @selector(create_chat_finished:);
    request.didFailSelector = @selector(create_chat_failed:);
    [request startAsynchronous];

}


- (void)create_chat_finished:(ASIHTTPRequest *)request
{
    NSString *json_str = [request responseString];
    NSLog(@"json_str : %@", json_str);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:json_str];
    if (!json)
    {
        NSLog(@"cleaned...");
    }
    else
    {
        NSDictionary *doc = [json objectForKey:@"doc"];
        
        NSMutableDictionary *topic = [[NSMutableDictionary alloc]init];
        
        [topic setValue:[doc objectForKey:@"_id"] forKey:@"id"];
        
        [self enter_message_chat:topic];
    }
}

- (void)create_chat_failed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error localizedFailureReason]);
}

- (void)enter_message_chat:(NSDictionary *) topic {
    
    NSLog(@"%@", uiviewController.navigationController);
    
    [uiviewController.navigationController popViewControllerAnimated:YES];
    
    
    NSString *topicid = (NSString *)[topic objectForKey:@"id"];
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate._chatmessage_topic = topic;
    delegate._chatmessage_topicid = topicid;
    
    BTChatMessageTableViewController *messageTableViewController = [[BTChatMessageTableViewController alloc] init];
    
    messageTableViewController.title = @"";
    
    messageTableViewController._topic_id_cur = topicid;
    
        NSLog(@"%@", self.navigationController);
    
    [self.navigationController pushViewController:messageTableViewController animated:YES];
}




//最新下拉菜单

- (void)show_menu_topic
{
    [_menu_topic close];
    [_menu_set close];
    
    if(_menu_topic.isOpen)
    {
        return [_menu_topic close];
    }
    
    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"新会议"
                                                    subtitle:@"您想发起一个新的会议：）"
                                                       image:[UIImage imageNamed:@"contacts_add_friend"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);
                                                          [self meeting_create];
                                                          
                                                      }];
    
    REMenuItem *exploreItem = [[REMenuItem alloc] initWithTitle:@"新任务"
                                                       subtitle:@"您想发起一个任务：）"
                                                          image:[UIImage imageNamed:@"contacts_add_voip"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             [self task_create];

                                                         }];
    
    REMenuItem *activityItem = [[REMenuItem alloc] initWithTitle:@"私聊"
                                                        subtitle:@"您想和他人进行单独沟通：）"
                                                           image:[UIImage imageNamed:@"contacts_add_newmessage"]
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              NSLog(@"Item: %@", item);
                                                              [self chat_create];
                                                          }];
    
    homeItem.tag = 0;
    exploreItem.tag = 1;
    activityItem.tag = 2;
    
    _menu_topic = [[REMenu alloc] initWithItems:@[homeItem, exploreItem, activityItem]];
    _menu_topic.cornerRadius = 4;
    _menu_topic.shadowColor = [UIColor blackColor];
    _menu_topic.shadowOffset = CGSizeMake(0, 1);
    _menu_topic.shadowOpacity = 1;
    _menu_topic.imageOffset = CGSizeMake(5, -1);
    
    [_menu_topic showFromNavigationController:self.navigationController];
}

- (void)show_menu_set
{
    [_menu_topic close];
    [_menu_set close];

    if(_menu_set.isOpen)
    {
        return [_menu_set close];
    }
    
    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"我"
                                                    subtitle:@"Return to Home Screen"
                                                       image:[UIImage imageNamed:@"Icon_Home"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);
                                                          

                                                      }];
    
    REMenuItem *exploreItem = [[REMenuItem alloc] initWithTitle:@"设置"
                                                       subtitle:@"修改个人应用设置参数"
                                                          image:[UIImage imageNamed:@"Icon_Explore"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             [self go_set];
                                                         }];
    
    homeItem.tag = 0;
    exploreItem.tag = 1;

    
    _menu_set = [[REMenu alloc] initWithItems:@[homeItem, exploreItem]];
    _menu_set.cornerRadius = 4;
    _menu_set.shadowColor = [UIColor blackColor];
    _menu_set.shadowOffset = CGSizeMake(0, 1);
    _menu_set.shadowOpacity = 1;
    _menu_set.imageOffset = CGSizeMake(5, -1);
    
    [_menu_set showFromNavigationController:self.navigationController];
}

#pragma mark - Action

- (void)enterMessage:(NSDictionary *) topic {
    
    NSString *topicid = (NSString *)[topic objectForKey:@"_id"];
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate._chatmessage_topic = topic;
    delegate._chatmessage_topicid = topicid;
    delegate._viewid = @"ChatMessage";
    
    BTChatMessageTableViewController *messageTableViewController = [[BTChatMessageTableViewController alloc] init];
    
    messageTableViewController.title = @"";
    
    messageTableViewController._topic_id_cur = topicid;
    
    [self.navigationController pushViewController:messageTableViewController animated:YES];
}

- (void)enterNewsController {
    XHNewsTableViewController *newsTableViewController = [[XHNewsTableViewController alloc] init];
    [self pushNewViewController:newsTableViewController];
}

- (void)enterQRCodeController {
    XHQRCodeViewController *QRCodeViewController = [[XHQRCodeViewController alloc] init];
    [self pushNewViewController:QRCodeViewController];
}

- (void)showMenuOnView:(UIBarButtonItem *)buttonItem {
    [self.popMenu showMenuOnView:self.view atPoint:CGPointZero];
}

@end

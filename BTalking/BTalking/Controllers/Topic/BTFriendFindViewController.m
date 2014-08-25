//
//  BTFriendFiindViewController.m
//  SayAbout
//
//  Created by admin on 14-7-23.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import "SBJsonParser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "AppDelegate.h"
#import "BTFriendFindViewController.h"
#import "BTFriendTableViewCell.h"
#import "SSSearchBar.h"
#import "BTMeetingCreateViewController.h"
#import "BTChatMessageTableViewController.h"

@interface BTFriendFindViewController ()<SSSearchBarDelegate>


@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation BTFriendFindViewController

@synthesize tableView, searchBar;

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
    
    self.tableView.delegate = self; //指定列表代理程序
    self.tableView.dataSource = self;
    
    self.searchBar.cancelButtonHidden = NO;
    self.searchBar.placeholder = NSLocalizedString(@"搜索", nil);
    self.searchBar.delegate = self; // 指定搜索代理程序
    [self.searchBar becomeFirstResponder];
    
    [self load_contacts];
    
}

- (void)load_contacts
{
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@", delegate._http,delegate._server, @"/contact" ];
    NSURL *url = [NSURL URLWithString:strURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request setUseCookiePersistence : YES];
    [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    
    
    request.delegate = self;
    request.didFinishSelector = @selector(load_contacts_finished:);
    request.didFailSelector = @selector(load_contacts_failed:);
    [request startAsynchronous];
}

- (void)load_contacts_finished:(ASIHTTPRequest *)request
{
    NSString *contacts_str = [request responseString];
    NSLog(@"contacts_str : %@", contacts_str);
    
    [self parse_json_contacts:contacts_str];
}

- (void)parse_json_contacts:(NSString *) contacts_str
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:contacts_str];
    if (!json)
    {
        NSLog(@"cleaned...");
    }
    else
    {
        NSMutableArray *dataSource = [[NSMutableArray alloc] init];
        
        NSDictionary *obj = [json objectForKey:@"friends"];
        
        for(NSString *key in obj)
        {
            NSArray *group = obj[key];
            
            for(int i=0;i<group.count;i++)
            {
                NSDictionary *user = [group objectAtIndex:i];
                NSLog(@"%@", (NSString*)[user objectForKey:@"name"]);
                                NSLog(@"%@", (NSString*)[user objectForKey:@"username"]);
                [dataSource addObject:user];
            }
        }
        
        self.dataSource = dataSource;
        [self.tableView reloadData];
    }
    
}

- (void)load_contacts_failed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error localizedFailureReason]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FriendCell";
    BTFriendTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[BTFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.lb_username.font = [UIFont systemFontOfSize:20];
    }
    
    if (indexPath.row < self.dataSource.count)
    {
        NSDictionary *user = [self.dataSource objectAtIndex:indexPath.row];
        cell.lb_username.text = [user objectForKey:@"name"];
        cell.lb_loginname.text = [user objectForKey:@"username"];
        
        [cell.btn_checked addTarget:self action:@selector(check_user:) forControlEvents:UIControlEventTouchUpInside];
        
    }

    
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(section ==0)
    {
        return 0;
    }
    else
    {
        UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 20.0)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [button setFrame:CGRectMake(275.0, 5.0, 30.0, 30.0)];
        button.tag = section;
        button.hidden = NO;
        [button setBackgroundColor:[UIColor clearColor]];
        [button addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchDown];
        [myView addSubview:button];
        return myView;
    }
}

-(void) check_user:(UIButton *)sender
{
    NSLog(@"%@", @"check me.");
    if (sender.selected == FALSE)
    {
        [sender setSelected:TRUE];
    }
    else
    {
        [sender setSelected:FALSE];
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"您点击了取消按钮");
    [self.searchBar resignFirstResponder]; // 丢弃第一使用者
}
#pragma mark - 实现键盘上Search按钮的方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"您点击了键盘上的Search按钮");
    
    [self search_contact];
    
}
#pragma mark - 实现监听开始输入的方法
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"开始输入搜索内容");
    return YES;
}
#pragma mark - 实现监听输入完毕的方法
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    NSLog(@"输入完毕");
    return YES;
}



-(void) search_contact
{
    
    [self.dataSource removeAllObjects];
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSString *username = self.searchBar.text;
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@%@", @"http://", delegate._server, @"/finduserbyname/", username];
    NSURL *url = [NSURL URLWithString:strURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request setUseCookiePersistence : YES];
    [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    
    
    request.delegate = self;
    request.didFinishSelector = @selector(search_contact_finished:);
    request.didFailSelector = @selector(search_contact_failed:);
    [request startAsynchronous];

    
}

-(void) search_contact_finished:(ASIHTTPRequest *)request
{
    NSString *contacts_str = [request responseString];
    NSLog(@"contacts_str : %@", contacts_str);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:contacts_str];
    if (!json)
    {
        NSLog(@"cleaned...");
    }
    else
    {
        NSMutableArray *dataSource = [[NSMutableArray alloc] init];
        
        NSArray *concats = [json objectForKey:@"items"];
        
        
            for(int i=0;i<concats.count;i++)
            {
                NSDictionary *user = [concats objectAtIndex:i];
                NSLog(@"%@", (NSString*)[user objectForKey:@"name"]);
                NSLog(@"%@", (NSString*)[user objectForKey:@"username"]);
                NSLog(@"%@", (NSString*)[user objectForKey:@"_id"]);
                
                [dataSource addObject:user];
            }

        
        self.dataSource = dataSource;
        [self.tableView reloadData];
    }
}

-(void) search_contact_failed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error localizedFailureReason]);
}

-(void) add_contact
{
    NSLog(@"%@", @"add_contact click.");
    
    NSMutableArray *users = [[NSMutableArray alloc]init];
    
    for(int i=0;i<self.dataSource.count;i++)
    {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];

        BTFriendTableViewCell *cell = (BTFriendTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        
        if(cell.btn_checked.state == UIControlStateSelected)
        {
            [users addObject:self.dataSource[i]];
        }
    }
    
    switch (self.delegate.mRequestId)
    {
//        case BTMeetingSelectAdmin:
//        {
//            [self.delegate set_admin_value:users];
//            break;
//        }
//        case BTMettingSelectPeople:
//        {
//            [self.delegate set_people_value:users];
//            break;
//        }
//        case BTTaskSelectAdmin:
//        {
//            [self.delegate set_admin_value:users];
//            break;
//        }
//        case BTTaskSelectPeople:
//        {
//            [self.delegate set_people_value:users];
//            break;
//        }
            

        case BTChatCreateSelectPeople:
        {
            [self set_people_values:users requestId:self.delegate.mRequestId];
        }
        default:
            break;
    }
}


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




#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save_persons:(id)sender
{
    [self add_contact];

}
@end

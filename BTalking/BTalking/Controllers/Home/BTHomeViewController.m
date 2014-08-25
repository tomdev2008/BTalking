//
//  BTHomeViewController.m
//  SayAbout
//
//  Created by admin on 14-7-16.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import "BTHomeViewController.h"
#import "BTTopicViewController.h"
#import "XHBaseNavigationController.h"
#import "AppDelegate.h"

@interface BTHomeViewController ()

@property (strong, nonatomic) OCBorghettiView *accordion;

@end

@implementation BTHomeViewController



@synthesize menuDictionary;

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
    // Do any additional setup after loading the view.

    // 初始化菜单数据
    NSString* plistPath = [[NSBundle mainBundle] pathForResource: @"HomeMenu"
                                                        ofType: @"plist"];
    
    NSLog(@"%@", plistPath);
    
    self.menuDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSMutableArray *menus = (NSMutableArray *)[self.menuDictionary objectForKey:@"menu"];

    for(int i=0;i<menus.count;i++)
    {
        NSMutableDictionary *amenu = (NSMutableDictionary*)[menus objectAtIndex:i];
        NSMutableArray *submenus = [amenu objectForKey:@"submenu"];
        
        NSLog(@"%@",submenus);
        
        
        for(int j=0;j<submenus.count;j++)
        {
            NSMutableDictionary *asubmenu = (NSMutableDictionary *)[submenus objectAtIndex:j];
            NSLog(@"%@",asubmenu);
            
            NSString *title = [asubmenu objectForKey:@"title"];
            NSString *cid = [asubmenu objectForKey:@"cid"];
            
            NSLog(@"%@%@%@", title, @":", cid);
        }
    }
    
    self.dataSource = menus;
    
    NSLog(@"%@", menuDictionary);
    
     [self setupAccordion];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupAccordion
{
    self.menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];    [self.menuTable setTag:1];
    [self.menuTable setDelegate:self];
    [self.menuTable setDataSource:self];
    
    [self.view addSubview:self.menuTable];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSMutableArray *menus = (NSMutableArray *)[self.menuDictionary objectForKey:@"menu"];
//    return menus.count;
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSMutableDictionary *amenu = (NSMutableDictionary*)[self.dataSource objectAtIndex:section];
    NSMutableArray *submenus = [amenu objectForKey:@"submenu"];
    return submenus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

//    NSMutableArray *menus = (NSMutableArray *)[self.menuDictionary objectForKey:@"menu"];
//    NSMutableDictionary *amenu = (NSMutableDictionary*)[menus objectAtIndex:indexPath.section];
//    NSMutableArray *submenus = [amenu objectForKey:@"submenu"];
//    
//    NSLog(@"%@",submenus);
//    
//    NSMutableDictionary *asubmenu = (NSMutableDictionary *)[submenus objectAtIndex:indexPath.row];
//    
//    NSLog(@"%@",asubmenu);
//    
//    NSString *title = [asubmenu objectForKey:@"title"];
//    NSString *cid = [asubmenu objectForKey:@"cid"];
    
    NSMutableDictionary *amenu = (NSMutableDictionary*)[self.dataSource objectAtIndex:indexPath.section];
    NSMutableArray *submenus = [amenu objectForKey:@"submenu"];
    NSMutableDictionary *asubmenu = [submenus objectAtIndex:indexPath.row];
    
    NSString *title = [asubmenu objectForKey:@"title"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"borghetti_cell"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"borghetti_cell"];
    
    cell.textLabel.font = [UIFont fontWithName:@"Avenir" size:16];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", title];
    cell.textLabel.textColor = [UIColor colorWithRed:0.46f green:0.46f blue:0.46f alpha:1.0f];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSMutableArray *menus = (NSMutableArray *)[self.menuDictionary objectForKey:@"menu"];
    NSMutableDictionary *amenu = (NSMutableDictionary*)[menus objectAtIndex:section];
    NSString *title = (NSString*)[amenu objectForKey:@"title"];
    
    return title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.menuTable deselectRowAtIndexPath:indexPath animated:YES];

    NSMutableDictionary *amenu = (NSMutableDictionary*)[self.dataSource objectAtIndex:indexPath.section];
    NSMutableArray *submenus = [amenu objectForKey:@"submenu"];
    NSMutableDictionary *asubmenu = [submenus objectAtIndex:indexPath.row];
    
    NSString *cid = [asubmenu objectForKey:@"cid"];
    
    if([@"owner" isEqualToString:cid])
    {
        [self search_tasks_owner];
    }
    else
    if([@"actor" isEqualToString:cid])
    {
        [self search_tasks_actor];
    }
    else
    if([@"all" isEqualToString:cid])
    {
        [self search_tasks_all];
    }
    else
    if([@"meeting" isEqualToString:cid])
    {
        [self search_tasks_meeting];
    }
    else
    if([@"task" isEqualToString:cid])
    {
    [self search_tasks_task];
    }
    else
    if([@"chat" isEqualToString:cid])
    {
        [self search_tasks_chat];
    }
    else
    if([@"today" isEqualToString:cid])
    {
        [self search_tasks_today];
    }
    else
    if([@"day3" isEqualToString:cid])
    {
        [self search_tasks_day3];
    }
    else
    if([@"week" isEqualToString:cid])
    {
        [self search_tasks_week];
    }
    
}

-(void) search_tasks_owner
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    XHBaseNavigationController *topicNavigationController = (XHBaseNavigationController *)[delegate._rootTabBarController.viewControllers objectAtIndex:1];
    
    BTTopicViewController *topicViewController = [topicNavigationController.viewControllers objectAtIndex:0];
    topicViewController.dataSource = [[NSMutableArray alloc] init];
    topicViewController._querystring = [[NSMutableDictionary alloc] init];
    
    [topicViewController._querystring setObject:@"owner" forKey:@"ftype"];
    [topicViewController load_topics:1];
    
    [delegate._rootTabBarController setSelectedIndex:1]; //切换至主题视图
}

-(void) search_tasks_actor
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    XHBaseNavigationController *topicNavigationController = (XHBaseNavigationController *)[delegate._rootTabBarController.viewControllers objectAtIndex:1];
    
    BTTopicViewController *topicViewController = [topicNavigationController.viewControllers objectAtIndex:0];
    topicViewController.dataSource = [[NSMutableArray alloc] init];
    topicViewController._querystring = [[NSMutableDictionary alloc] init];
    
    [topicViewController._querystring setObject:@"actor" forKey:@"ftype"];
    [topicViewController load_topics:1];
    
    [delegate._rootTabBarController setSelectedIndex:1]; //切换至主题视图
    
}

-(void) search_tasks_all
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    XHBaseNavigationController *topicNavigationController = (XHBaseNavigationController *)[delegate._rootTabBarController.viewControllers objectAtIndex:1];
    
    BTTopicViewController *topicViewController = [topicNavigationController.viewControllers objectAtIndex:0];
    topicViewController.dataSource = [[NSMutableArray alloc] init];
    topicViewController._querystring = [[NSMutableDictionary alloc] init];
    
    [topicViewController load_topics:1];
    
    [delegate._rootTabBarController setSelectedIndex:1]; //切换至主题视图
}

-(void) search_tasks_meeting
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    XHBaseNavigationController *topicNavigationController = (XHBaseNavigationController *)[delegate._rootTabBarController.viewControllers objectAtIndex:1];
    
    BTTopicViewController *topicViewController = [topicNavigationController.viewControllers objectAtIndex:0];
    topicViewController.dataSource = [[NSMutableArray alloc] init];
    topicViewController._querystring = [[NSMutableDictionary alloc] init];
    [topicViewController._querystring setObject:@"meetings" forKey:@"type"];
    
    [topicViewController load_topics:1];
    
    [delegate._rootTabBarController setSelectedIndex:1]; //切换至主题视图
}

-(void) search_tasks_task
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    XHBaseNavigationController *topicNavigationController = (XHBaseNavigationController *)[delegate._rootTabBarController.viewControllers objectAtIndex:1];
    
    BTTopicViewController *topicViewController = [topicNavigationController.viewControllers objectAtIndex:0];
    topicViewController.dataSource = [[NSMutableArray alloc] init];
    topicViewController._querystring = [[NSMutableDictionary alloc] init];
    [topicViewController._querystring setObject:@"tasks" forKey:@"type"];
    
    [topicViewController load_topics:1];
    
    [delegate._rootTabBarController setSelectedIndex:1]; //切换至主题视图
}

-(void) search_tasks_chat
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [delegate._rootTabBarController setSelectedIndex:2]; //切换至主题视图
}

-(void) search_tasks_today
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    XHBaseNavigationController *topicNavigationController = (XHBaseNavigationController *)[delegate._rootTabBarController.viewControllers objectAtIndex:1];
    
    BTTopicViewController *topicViewController = [topicNavigationController.viewControllers objectAtIndex:0];
    topicViewController.dataSource = [[NSMutableArray alloc] init];
    topicViewController._querystring = [[NSMutableDictionary alloc] init];
   [topicViewController._querystring setObject:@"today" forKey:@"type"];
    
    [topicViewController load_topics:1];
    
    [delegate._rootTabBarController setSelectedIndex:1]; //切换至主题视图
}

-(void) search_tasks_day3
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    XHBaseNavigationController *topicNavigationController = (XHBaseNavigationController *)[delegate._rootTabBarController.viewControllers objectAtIndex:1];
    
    BTTopicViewController *topicViewController = [topicNavigationController.viewControllers objectAtIndex:0];
    topicViewController.dataSource = [[NSMutableArray alloc] init];
    topicViewController._querystring = [[NSMutableDictionary alloc] init];
   [topicViewController._querystring setObject:@"day3" forKey:@"type"];
    
    [topicViewController load_topics:1];
    
    [delegate._rootTabBarController setSelectedIndex:1]; //切换至主题视图
}

-(void) search_tasks_week
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    XHBaseNavigationController *topicNavigationController = (XHBaseNavigationController *)[delegate._rootTabBarController.viewControllers objectAtIndex:1];
    
    BTTopicViewController *topicViewController = [topicNavigationController.viewControllers objectAtIndex:0];
    topicViewController.dataSource = [[NSMutableArray alloc] init];
    topicViewController._querystring = [[NSMutableDictionary alloc] init];
    [topicViewController._querystring setObject:@"week" forKey:@"type"];
    
    [topicViewController load_topics:1];
    
    [delegate._rootTabBarController setSelectedIndex:1]; //切换至主题视图
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

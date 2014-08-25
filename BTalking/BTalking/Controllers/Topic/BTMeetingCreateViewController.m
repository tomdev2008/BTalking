//
//  BTMeetingCreateViewController.m
//  SayAbout
//
//  Created by admin on 14-7-22.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//
#import "SBJsonParser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "AppDelegate.h"

#import "BTTopicViewController.h"
#import "BTMeetingCreateViewController.h"
#import "BTFriendFindViewController.h"
#import "Toast+UIView.h"

@interface BTMeetingCreateViewController ()

@property NSMutableArray* admins; // 负责人

@property NSMutableArray* peoples; // 参与人

@end

@implementation BTMeetingCreateViewController

@synthesize btn_admin, btn_begintime, btn_endtime, btn_people, btn_save;

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
    
    self.admins = [[NSMutableArray alloc]init];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save_meeting:)];//为导航栏添加右侧按钮

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)select_admin:(id)sender {
    
    self.mRequestId = BTMeetingSelectAdmin;
    BTFriendFindViewController *findfriendTableViewController = [[BTFriendFindViewController alloc] init];
    findfriendTableViewController.delegate = self;
    [self.navigationController pushViewController:findfriendTableViewController animated:YES];
}

- (IBAction)select_begintime:(id)sender {
}

- (IBAction)select_endtime:(id)sender {
}

- (IBAction)select_people:(id)sender {
    self.mRequestId = BTMettingSelectPeople;
    BTFriendFindViewController *findfriendTableViewController = [[BTFriendFindViewController alloc] init];
    findfriendTableViewController.delegate = self;
    [self.navigationController pushViewController:findfriendTableViewController animated:YES];
}

- (IBAction)select_place:(id)sender {
}

- (IBAction)save_meeting:(id)sender {
    if([self.tv_title.text isEqualToString:@""])
    {
        [self.view makeToast:@"会议标题不能为空。"];
        return;
    }
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@", @"http://", delegate._server, @"/meetings/"];
    NSURL *url = [NSURL URLWithString:strURL];

    
    NSString *uids_admin = [[NSString alloc]init];
    
    for(int i=0;i<self.admins.count;i++)
    {
        NSDictionary *user = (NSDictionary*)[self.admins objectAtIndex:i];
        NSString *uid = (NSString*)[user objectForKey:@"_id"];
        uids_admin = [uids_admin stringByAppendingFormat:@"%@", uid];
        if(i<self.admins.count-1)
        {
            uids_admin = [uids_admin stringByAppendingFormat:@"%@", @","];
        }
    }
    
    NSString *uids_people = [[NSString alloc]init];
    
    for(int i=0;i<self.peoples.count;i++)
    {
        NSDictionary *user = (NSDictionary*)[self.peoples objectAtIndex:i];
        NSString *uid = (NSString*)[user objectForKey:@"_id"];
        uids_people = [uids_admin stringByAppendingFormat:@"%@", uid];
        if(i<self.peoples.count-1)
        {
            uids_people = [uids_people stringByAppendingFormat:@"%@", @","];
        }
    }
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence : YES];
    [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:delegate._userid forKey:@"_creator"];
    [request setPostValue:self.tv_title.text forKey:@"title"];
    [request setPostValue:uids_admin forKey:@"chairman"];
    [request setPostValue:uids_people forKey:@"personsList"];
    
    request.delegate = self;
    request.didFinishSelector = @selector(create_meeting_finished:);
    request.didFailSelector = @selector(create_meeting_failed:);
    [request startAsynchronous];
}

-(void) create_meeting_finished:(ASIHTTPRequest *)request
{
    
    NSLog(@"保存会议成功。");
    [self.view makeToast:@"保存会议成功。"];
    

    //    BTTopicViewController *topicViewController = [[BTTopicViewController alloc] init];
    //    [self.navigationController pushViewController:topicViewController animated:YES];

}


-(void) create_meeting_failed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"保存会议异常: %@", [error localizedFailureReason]);
    [self.view makeToast:@"保存会议异常，请检查网络及设备，如仍无法解决，请联系我们。"];
}


-(void)set_admin_value:(NSMutableArray *)users
{
    NSString *value = @"";
    
    for(int i=0;i<users.count;i++)
    {
        NSDictionary *user = (NSDictionary*)[users objectAtIndex:i];
        NSString *cname = (NSString*)[user objectForKey:@"name"];
        value = [value stringByAppendingFormat:@"%@", cname];
        if(i<users.count-1)
        {
            value = [value stringByAppendingFormat:@"%@", @","];
        }
    }
    self.tv_admin.text = value;
    self.admins = users;
}

-(void)set_people_value:(NSMutableArray *)users
{
    NSString *value = @"";
    
    for(int i=0;i<users.count;i++)
    {
        NSDictionary *user = (NSDictionary*)[users objectAtIndex:i];
        NSString *cname = (NSString*)[user objectForKey:@"name"];
        value = [value stringByAppendingFormat:@"%@", cname];
        if(i<users.count-1)
        {
            value = [value stringByAppendingFormat:@"%@", @","];
        }
    }
    self.tv_people.text = value;
    self.peoples = users;
}


@end

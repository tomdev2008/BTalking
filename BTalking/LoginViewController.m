//
//  LoginViewController.m
//  SayAbout
//
//  Created by admin on 14-7-9.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SBJsonParser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "XHBaseTabBarController.h"
#import "XHBaseNavigationController.h"

#import "XHContactTableViewController.h"
#import "XHDiscoverTableViewController.h"
#import "XHProfileTableViewController.h"
#import "XHMacro.h"

#import "BTHomeViewController.h"
#import "BTTopicViewController.h"
#import "BTChatViewController.h"
#import "BTContactViewController.h"
#import "BTSetViewController.h"
#import "Toast+UIView.h"
#import "MessageTools.h"

#import "XHMessage.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

NSString *c_userid;
NSString *c_loginname;
NSString *c_username;
NSString *c_password;
NSString *c_server;



NSMutableArray *testList; //测试
int sno;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    delegate._userid = [defaults objectForKey:@"_userid"];
    delegate._loginname = [defaults objectForKey:@"_loginname"];
    delegate._username = [defaults objectForKey:@"_username"];
    delegate._password = [defaults objectForKey:@"_password"];
    delegate._ptoken = [defaults objectForKey:@"_ptoken"];

    // 产品发布后为预设服务器地址
    delegate._server = [defaults objectForKey:@"_server"];
    
    NSLog(@"userid:%@", [defaults objectForKey:@"_userid"]);
    NSLog(@"loginname:%@", [defaults objectForKey:@"_loginname"]);
    NSLog(@"username:%@", [defaults objectForKey:@"_username"]);
    NSLog(@"password:%@", [defaults objectForKey:@"_password"]);
    NSLog(@"server:%@", [defaults objectForKey:@"_server"]);
    NSLog(@"ptoken:%@", [defaults objectForKey:@"_ptoken"]);
    NSLog(@"http:%@", delegate._http);
    
//    self.tv_loginname.text = delegate._loginname;
//    self.tv_password.text = delegate._password;
//    self.tv_server.text = delegate._server;
    
    // 检查登录信息是否具备
    if(delegate._ptoken == nil || [delegate._ptoken isEqualToString:@""])
    {
        return;
    }

    if(delegate._userid == nil || [delegate._userid isEqualToString:@""])
    {
        return;
    }
    
    if(delegate._password == nil || [delegate._password isEqualToString:@""])
    {
        return;
    }
    
    // 登录信息具备，自动登录，否则等候用户手动登录
    // [self request_login:delegate._loginname password:delegate._password server:delegate._server ptoken:delegate._ptoken];
    
    
    testList = [[NSMutableArray alloc]init];
    sno = 1;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)login:(id)sender
{
//    [self test];
//    return;
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if(delegate._ptoken == nil || [delegate._ptoken isEqualToString:@""])
    {
        [self.view makeToast:@"设备尚未注册网络成功，请退出重试。"];
        return;
    }
    
    if([self.tv_loginname.text isEqualToString:@""])
    {
        [self.view makeToast:@"用户名不能为空。"];
        return;
    }
    
    if([self.tv_password.text isEqualToString:@""])
    {
        [self.view makeToast:@"密码不能为空。"];
        return;
    }
 
    NSString *loginname = [self.tv_loginname text];
    NSString *password = [self.tv_password text];
    NSString *server = [self.tv_server text];
    
    delegate._server = server;
    delegate._loginname = loginname;
    delegate._password = password;
    
    [self request_login:loginname password:password server:server ptoken:delegate._ptoken];
     
}

- (void)request_login:(NSString *)loginname password:(NSString *)password server:(NSString *)server ptoken:(NSString *) ptoken
{
    // 保存全局变量 服务器地址
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@", delegate._http,server, @"/phonelogin" ];
    
    NSURL *url = [NSURL URLWithString:strURL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:loginname forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:@"iphone" forKey:@"equip"];
    [request setPostValue:ptoken forKey:@"equipid"];
    
    [request setValidatesSecureCertificate:NO];
    
    request.delegate = self;
    request.didFinishSelector = @selector(request_login_finished:);
    request.didFailSelector = @selector(request_login_failed:);
    [request startAsynchronous];
}

- (void)request_login_finished:(ASIHTTPRequest *)request
{
    NSString *str_response = [request responseString];
    NSLog(@"requestFinished : %@", str_response);
    
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:str_response];
    if (!json)
    {
        [self.view makeToast:@"登录失败，请检查登录信息是否正确。"];
        NSLog(@"cleaned...");
        return;
    }
    else
    {
        NSString *userid = (NSString*)[json objectForKey:@"_id"];
        NSString *loginname = (NSString*)[json objectForKey:@"username"];
        NSString *username = (NSString*)[json objectForKey:@"name"];
        
        delegate._userid = userid;
        delegate._loginname = loginname;
        delegate._username = username;
        
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        [defaults setObject:delegate._userid forKey:@"_userid"];
        [defaults setObject:delegate._loginname forKey:@"_loginname"];
        [defaults setObject:delegate._username forKey:@"_username"];
        [defaults setObject:delegate._password forKey:@"_password"];
        [defaults setObject:delegate._ptoken forKey:@"_ptoken"];
        [defaults setObject:delegate._server forKey:@"_server"];
        
        [self go_main];
        
    }
}

- (void)request_login_failed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error localizedFailureReason]);
    
    [self.view makeToast:@"登录失败，请检查网络及手机是否工作正常。"];
}

-(void)go_main
{
    // home
    BTHomeViewController *homeViewController = [[BTHomeViewController alloc] init];
    homeViewController.title = NSLocalizedStringFromTable(@"Home", @"MessageDisplayKitString", @"首页");
    homeViewController.tabBarItem.image = [UIImage imageNamed:@"WeChat"];
    XHBaseNavigationController *homeNavigationController = [[XHBaseNavigationController alloc] initWithRootViewController:homeViewController];
    
     
    // topic
    BTTopicViewController *topicViewController = [[BTTopicViewController alloc] init];
    topicViewController.title = NSLocalizedStringFromTable(@"Topic", @"MessageDisplayKitString", @"事务");
    topicViewController.tabBarItem.image = [UIImage imageNamed:@"Contact"];
    XHBaseNavigationController *topicNavigationController = [[XHBaseNavigationController alloc] initWithRootViewController:topicViewController];
    
//    topicViewController._querystring = [[NSMutableDictionary alloc]init];
    
    // chat
    BTChatViewController *chatViewController = [[BTChatViewController alloc] init];
    chatViewController.title = NSLocalizedStringFromTable(@"Chat", @"MessageDisplayKitString", @"私聊");
    chatViewController.tabBarItem.image = [UIImage imageNamed:@"SNS"];
    XHBaseNavigationController *chatNavigationController = [[XHBaseNavigationController alloc] initWithRootViewController:chatViewController];
    
    // contact
    BTContactViewController *contactViewController = [[BTContactViewController alloc] init];
    contactViewController.title = NSLocalizedStringFromTable(@"Friend", @"MessageDisplayKitString", @"联系人");
    contactViewController.tabBarItem.image = [UIImage imageNamed:@"Profile"];
    XHBaseNavigationController *contactNavigationController = [[XHBaseNavigationController alloc] initWithRootViewController:contactViewController];

    
    XHBaseTabBarController *rootTabBarController = [[XHBaseTabBarController alloc] init];
    
    rootTabBarController.viewControllers = [NSArray arrayWithObjects:homeNavigationController, topicNavigationController, chatNavigationController,contactNavigationController, nil];

    
    // setup UI Image
    UIColor *color = [UIColor colorWithRed:0.176 green:0.576 blue:0.980 alpha:1.000];
    [rootTabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbarBkg"]];
    [rootTabBarController.tabBar setSelectedImageTintColor:color];
    
    if (CURRENT_SYS_VERSION >= 7.0) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.071 green:0.060 blue:0.086 alpha:1.000]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    } else {
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.071 green:0.060 blue:0.086 alpha:1.000]];
    }
    
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:17], NSFontAttributeName, nil]];
    
    self.view.window.rootViewController = rootTabBarController;
    
    [self.view.window makeKeyAndVisible];
    
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate._rootTabBarController = rootTabBarController;
    
    
    
    NSLog(@"count:%d", delegate._rootTabBarController.viewControllers.count);
    NSLog(@"%@", [delegate._rootTabBarController.viewControllers objectAtIndex:0]);
    NSLog(@"%@", [delegate._rootTabBarController.viewControllers objectAtIndex:1]);
    
    
    id object = [delegate._rootTabBarController.viewControllers objectAtIndex:1];
    
            NSLog(@"%@", [object class]);
    

    XHBaseNavigationController *nav1 = (XHBaseNavigationController *)[delegate._rootTabBarController.viewControllers objectAtIndex:1];
    
    NSLog(@"count:%d", nav1.viewControllers.count);
    BTTopicViewController *view1 = [nav1.viewControllers objectAtIndex:0];
    
    NSLog(@"%@", [view1 class]);
    
    NSLog(@"title: %@", view1.title);
    
    if([view1 isKindOfClass:[BTHomeViewController class]])
    {
        NSLog(@"%@", [object class]);
    }
    else
    if([view1 isKindOfClass:[BTTopicViewController class]])
    {
        NSLog(@"%@", [object class]);
    }
    else
    if([view1 isKindOfClass:[BTChatViewController class]])
        {
            NSLog(@"%@", [object class]);
        }
        else
        if([view1 isKindOfClass:[BTContactViewController class]])
            {
                NSLog(@"%@", [object class]);
            }
    
//    NSLog(@"%@", topicViewController1);
//    NSLog(@"%d", topicViewController1._page_cur);
//    NSLog(@"%@", topicViewController1._querystring);
}


-(void) test
{
    for(int i=0;i<5;i++)
    {
        NSString *text = [@"" stringByAppendingFormat:@"%@%d", @"c", sno];
        NSString *sender = @"pujian";
        NSDate *date = [NSDate date];
        XHMessage *message = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
        [testList insertObject:message atIndex:0];
        sno = sno + 1;
    }
    
    for(int i=0;i<testList.count;i++)
    {
        XHMessage *message = [testList objectAtIndex:i];
        NSLog(@"%@%d%@%@", @"num", i, @":", message.text);
    }
}

@end

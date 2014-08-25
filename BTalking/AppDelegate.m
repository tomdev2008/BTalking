//
//  AppDelegate.m
//  BTalking
//
//  Created by admin on 14-8-20.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import "AppDelegate.h"
#import "XHBaseTabBarController.h"
#import "XHBaseNavigationController.h"

#import "XHContactTableViewController.h"
#import "XHDiscoverTableViewController.h"
#import "XHProfileTableViewController.h"

#import "XHMacro.h"
#import "IQKeyBoardManager.h"
#import "SBJsonParser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Toast+UIView.h"

#import "LoginViewController.h"

#import "BTTopicViewController.h"
#import "BTChatMessageTableViewController.h"

@implementation AppDelegate

@synthesize _rootTabBarController, _ptoken, _server, _http, _viewid, _chatmessage_topicid;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 设置访问协议
    self._http = @"https://";
 
    // 注册推送服务
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    
    
    // Override point for customization after application launch.
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    
    self.window.rootViewController = loginViewController;
    
    [self.window makeKeyAndVisible];
    

    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken {
    
    _ptoken = [NSString stringWithFormat:@"%@",pToken];
    _ptoken = [[_ptoken substringWithRange:NSMakeRange(0, 72)] substringWithRange:NSMakeRange(1, 71)];
    _ptoken = [_ptoken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"regisger success:%@", pToken);
    NSLog(@"_ptoken success:%@", _ptoken);
    
    //注册成功，将deviceToken保存到应用服务器数据库中
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    // 处理推送消息
    
    NSLog(@"%@", userInfo);
    //    NSLog(@"%@",[userInfo objectForKey:@"message"]);
    
    
    if (self._rootTabBarController != nil)
    {
        if ([self._viewid isEqualToString:@"ChatMessage"])
        {
            
            
            NSString *str_message = [userInfo objectForKey:@"message"];
            NSDictionary *message = [[[SBJsonParser alloc]init] objectWithString:str_message];
            
            NSString *str_did = [message objectForKey:@"did"]; // 话题标识
            NSString *str_cid = [message objectForKey:@"cid"]; // 消息标识
            
            if([str_did isEqualToString:self._chatmessage_topicid])
            {
                NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@%@%@%@", self._http,self._server, @"/message/", str_did, @"/", str_cid];
                NSURL *url = [NSURL URLWithString:strURL];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [request setUseCookiePersistence : YES];
                [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
                [request setValidatesSecureCertificate:NO];
                request.delegate = self;
                request.didFinishSelector = @selector(ajaxload_message_finished:);
                request.didFailSelector = @selector(ajaxload_message_failed:);
                [request startAsynchronous];
            }
            
        }
        
    }
    
}


-(void)ajaxload_message_finished:(ASIHTTPRequest *)request
{
    BTChatMessageTableViewController *messageTableViewController = (BTChatMessageTableViewController *) self._viewcontroller;
    
    NSString *message_str = [request responseString];
    NSLog(@"message_str : %@", message_str);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:message_str];
    
    if (!json)
    {
        NSLog(@"cleaned...");
        return;
    }
    
    NSDictionary *chatobj = [json objectForKey:@"chat"];
    NSString *senderid = [(NSDictionary*)[chatobj objectForKey:@"_sender"] objectForKey:@"_id"];
    NSString *sender = [(NSDictionary*)[chatobj objectForKey:@"_sender"] objectForKey:@"name"];
    
    NSString *content = [chatobj objectForKey:@"content"];
    
    XHMessage *textMessage = [[XHMessage alloc] initWithText:content sender:sender timestamp:[NSDate date]];
    
    // 判断消息发送者是否当前用户
    NSLog(@"%@%@%@", self._userid, @":", senderid);
    
    if([self._userid isEqualToString:senderid])
    {
        // 当前用户的消息不需要再展示，否则重复。
        // textMessage.bubbleMessageType = XHBubbleMessageTypeSending;
    }
    else
    {
        textMessage.bubbleMessageType = XHBubbleMessageTypeReceiving;
        [messageTableViewController.messages addObject:textMessage];
        [messageTableViewController.messageTableView reloadData];
        
        NSUInteger rowCount = [messageTableViewController.messageTableView numberOfRowsInSection:0];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowCount-1 inSection:0];
        
        [messageTableViewController.messageTableView scrollToRowAtIndexPath:indexPath
                                                           atScrollPosition:UITableViewScrollPositionBottom animated:NO];//设置滚动到底部
    }
}

-(void)ajaxload_message_failed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error localizedFailureReason]);
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Regist fail%@",error);
}




							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

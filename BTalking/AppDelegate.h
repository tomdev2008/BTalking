//
//  AppDelegate.h
//  BTalking
//
//  Created by admin on 14-8-20.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHBaseTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property NSString *_server; // 应用服务器

@property NSString *_ptoken; // 设备注册令牌

@property NSString *_http; // 访问协议

@property NSString *_loginname; // 当前登录用户

@property NSString *_username; // 当前用户姓名

@property NSString *_userid; // 当前用户标识

@property NSString *_password; // 当前用户密码


@property XHBaseTabBarController *_rootTabBarController; // 引用当前主框架页面；

@property NSString *_viewid; // 记录当前所在应用界面标识;

@property NSString *_chatmessage_topicid; // 记录当前所在主题标识;

@property NSDictionary *_chatmessage_topic; // 记录当前所在主题对象;

@property UIViewController *_viewcontroller; // 记录当前所在应用界面标识;

@property NSMutableArray *_faceArray; // 记录表情数据数组;

@end

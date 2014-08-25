//
//  XHDisplayMediaViewController.h
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-6.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHBaseViewController.h"
#import "XHMessageModel.h"

@interface XHDisplayMediaViewController : XHBaseViewController
{
    NSURLConnection* connection; // 网络链接 蒲剑;
    
    NSMutableData* data; // 网络数据流 蒲剑;
}

@property (nonatomic, strong) id <XHMessageModel> message;

- (void)loadImageFromURL:(NSURL*)url; //异步加载图片 蒲剑

@end

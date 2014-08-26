//
//  XHMessageRootViewController.h
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-26.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHBaseTableViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "BTFriendFindViewController.h"
#import "REMenu.h"

@interface BTTopicViewController : XHBaseTableViewController<EGORefreshTableHeaderDelegate, PassMeetingValueDelegate
>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

#pragma mark EGORefreshTableHeaderDelegate
- (void)reloadTableViewDataSource; //开始重新加载时调用的方法

- (void)doneLoadingTableViewData; //完成加载时调用的方法


#pragma mark 自定义变量

// 查询请求过滤条件参数
@property NSMutableDictionary *_querystring;

// 主题消息数据
@property NSData *m_json_topics;
@property NSString *m_str_topics;

@property (nonatomic, assign) BTRequestId mRequestId; // 请求标识

// 翻页刷新变量
@property int _page_cur; // 记录当前翻页页数
@property int _pages_cur; // 记录当前总页数

// 下拉菜单
@property (strong, nonatomic) REMenu *menu_topic;
@property (strong, nonatomic) REMenu *menu_set;



// 自定义方法
- (void)load_topics: (int) page;

@end

//
//  XHDemoWeChatMessageTableViewController.h
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-27.
//  Copyright (c) 2014年 蒲剑 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessageTableViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "ASINetworkQueue.h"

@interface BTChatMessageTableViewController : XHMessageTableViewController
<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,UIDocumentInteractionControllerDelegate>
{
    BOOL isflage;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property NSString *_topic_id_cur; // 记录当前主题标识

@property int _page_cur; // 记录当前翻页页数

@property int _pages_cur; // 记录当前总页数

// 下载线程队列
@property  ASINetworkQueue *netWorkQueue;

- (void)reloadTableViewDataSource;

- (void)doneLoadingTableViewData;


@end

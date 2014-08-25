//
//  BTChatViewController.h
//  SayAbout
//
//  Created by admin on 14-7-16.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHBaseTableViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface BTChatViewController : XHBaseTableViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
// 主题消息数据
@property NSData *m_json_topics;
@property NSString *m_str_topics;

@property int _page_cur; // 记录当前翻页页数
@property int _pages_cur; // 记录当前总页数

#pragma mark EGORefreshTableHeaderDelegate
- (void)reloadTableViewDataSource;

- (void)doneLoadingTableViewData;
@end
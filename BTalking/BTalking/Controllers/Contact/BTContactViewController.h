//
//  ContactTableViewController.h
//  SayAbout
//
//  Created by admin on 14-8-19.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTFriendFindAddViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface BTContactViewController : UIViewController
 <UITableViewDelegate, UITableViewDataSource,OnResultValueDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btn_select;
- (IBAction)select_contact:(id)sender;


@property int _page_cur; // 记录当前翻页页数
@property int _pages_cur; // 记录当前总页数

@property NSInteger mRequestId;
@property NSInteger mResponseId;

+(int) ReqSelectPeople;

@end



//
//  BTFriendFiindViewController.h
//  SayAbout
//
//  Created by admin on 14-7-23.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSSearchBar.h"
#import "BTApplication.H"

@interface BTFriendFindAddViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

//@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet SSSearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UIButton *btn_save; // 关闭窗口

- (IBAction)save_persons:(id)sender;

@property (nonatomic, unsafe_unretained) id<OnResultValueDelegate> delegate;

@property NSInteger mRequestId;

@property NSInteger mResponseId;

@end

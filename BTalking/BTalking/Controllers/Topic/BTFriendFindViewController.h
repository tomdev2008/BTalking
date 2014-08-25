//
//  BTFriendFiindViewController.h
//  SayAbout
//
//  Created by admin on 14-7-23.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSSearchBar.h"
#import "btApplication.h"

@protocol PassMeetingValueDelegate <NSObject>

-(void)set_admin_value:(NSMutableArray *) users; // 设置负责人

-(void)set_people_value:(NSMutableArray *) users; // 设置参与人

-(void)set_people_values:(NSMutableArray *) users requestId:(NSInteger) requestId; // 设置返回人员信息（后期迁移至此方法）

@property (nonatomic, assign) BTRequestId mRequestId;

@end

@interface BTFriendFindViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

//@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet SSSearchBar *searchBar;


@property (nonatomic, unsafe_unretained) id<PassMeetingValueDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *btn_save;
- (IBAction)save_persons:(id)sender;

@end

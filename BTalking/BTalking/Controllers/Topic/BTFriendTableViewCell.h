//
//  FriendTableViewCell.h
//  SayAbout
//
//  Created by admin on 14-7-25.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTFriendTableViewCell : UITableViewCell
@property (nonatomic,retain) UILabel *lb_username; // 姓名
@property (nonatomic,retain) UILabel *lb_loginname; // 登录名
@property (nonatomic,retain) UIButton *btn_checked; // 选择人员
@property (nonatomic,retain) UIImageView *iv_header; // 人员头像

@end

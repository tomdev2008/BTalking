//
//  BTContactTableViewCell.h
//  SayAbout
//
//  Created by admin on 14-8-19.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTContactTableViewCell : UITableViewCell

@property (nonatomic,retain) UILabel *lb_username; // 姓名
@property (nonatomic,retain) UILabel *lb_loginname; // 登录名
@property (nonatomic,retain) UIImageView *iv_avatar; // 人员头像
@property (nonatomic,retain) UIImageView *iv_phone; // 人员设备

@end

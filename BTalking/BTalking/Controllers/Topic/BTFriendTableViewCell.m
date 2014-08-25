//
//  FriendTableViewCell.m
//  SayAbout
//
//  Created by admin on 14-7-25.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import "BTFriendTableViewCell.h"

@implementation BTFriendTableViewCell

@synthesize lb_username, lb_loginname, btn_checked, iv_header;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        iv_header = [[UIImageView alloc] initWithFrame:CGRectMake(13.0f, 6.0f, 48.0f, 48.0f)];
        
        lb_username =[[UILabel alloc]initWithFrame:CGRectMake(80.0f, 6.0f, 200.0f, 32.0f)];
        lb_loginname =[[UILabel alloc]initWithFrame:CGRectMake(80.0f, 40.0f, 80.0f, 18.0f)];
        btn_checked = [[UIButton alloc]initWithFrame:CGRectMake(280.0f, 30.0f, 20.0f, 20.0f)];
        
        
        NSString *path1 = [[NSBundle mainBundle] pathForResource:@"cb_mono_off" ofType:@"png"];
        UIImage *image1 = [[UIImage alloc]initWithContentsOfFile:path1];
        
        NSString *path2 = [[NSBundle mainBundle] pathForResource:@"cb_mono_on" ofType:@"png"];
        UIImage *image2 = [[UIImage alloc]initWithContentsOfFile:path2];
        
        [btn_checked setBackgroundImage:image1 forState:UIControlStateNormal];
        [btn_checked setBackgroundImage:image2 forState:UIControlStateSelected];
        
 
        [self addSubview:iv_header];
        [self addSubview:lb_username];
        [self addSubview:lb_loginname];
        [self addSubview:btn_checked];
        
    }

    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

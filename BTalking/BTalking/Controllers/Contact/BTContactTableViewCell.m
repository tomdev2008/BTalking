//
//  BTContactTableViewCell.m
//  SayAbout
//
//  Created by admin on 14-8-19.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import "BTContactTableViewCell.h"

@implementation BTContactTableViewCell

@synthesize lb_username,lb_loginname,iv_avatar,iv_phone;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        iv_avatar = [[UIImageView alloc] initWithFrame:CGRectMake(13.0f, 6.0f, 48.0f, 48.0f)];
        iv_phone = [[UIImageView alloc] initWithFrame:CGRectMake(200.0f, 6.0f, 48.0f, 48.0f)];
        
        lb_username =[[UILabel alloc]initWithFrame:CGRectMake(80.0f, 6.0f, 200.0f, 32.0f)];
        lb_loginname =[[UILabel alloc]initWithFrame:CGRectMake(80.0f, 40.0f, 80.0f, 18.0f)];

        
        
        NSString *path1 = [[NSBundle mainBundle] pathForResource:@"cb_mono_off" ofType:@"png"];
        UIImage *image1 = [[UIImage alloc]initWithContentsOfFile:path1];
        
        NSString *path2 = [[NSBundle mainBundle] pathForResource:@"cb_mono_on" ofType:@"png"];
        UIImage *image2 = [[UIImage alloc]initWithContentsOfFile:path2];
        
        [self addSubview:iv_avatar];
        [self addSubview:lb_username];
        [self addSubview:lb_loginname];
        [self addSubview:iv_phone];
        
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

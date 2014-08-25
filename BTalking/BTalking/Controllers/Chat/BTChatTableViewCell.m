//
//  TopicTableCell.m
//  SayAbout
//
//  Created by admin on 14-7-18.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import "BTChatTableViewCell.h"

@implementation BTChatTableViewCell

@synthesize titleLabel,createrLabel,timeLabel,typeImage;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        typeImage = [[UIImageView alloc] initWithFrame:CGRectMake(13.0f, 6.0f, 32.0f, 32.0f)];

        titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(60.0f, 6.0f, 200.0f, 32.0f)];
        createrLabel =[[UILabel alloc]initWithFrame:CGRectMake(60.0f, 40.0f, 80.0f, 18.0f)];
        timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(200.0f, 40.0f, 100.0f, 18.0f)];
        [self addSubview:typeImage];
        [self addSubview:titleLabel];
        [self addSubview:createrLabel];
        [self addSubview:timeLabel];
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

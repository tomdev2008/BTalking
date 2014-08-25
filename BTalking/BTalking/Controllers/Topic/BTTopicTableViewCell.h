//
//  TopicTableCell.h
//  SayAbout
//
//  Created by admin on 14-7-18.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTTopicTableViewCell : UITableViewCell

@property (nonatomic,retain) UIImageView *typeImage; // 主题类型图片
@property (nonatomic,retain) UILabel *titleLabel; // 主题标题
@property (nonatomic,retain) UILabel *createrLabel; // 主题发起人
@property (nonatomic,retain) UILabel *timeLabel; // 主题时间

@end

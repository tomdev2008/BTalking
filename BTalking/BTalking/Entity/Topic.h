//
//  Topic.h
//  SayAbout
//
//  Created by admin on 14-8-15.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Topic : NSObject
{
    NSString *_uid;
    NSString *_subject;
    NSInteger *_ctype;
    NSInteger *_time_samp;
    NSInteger *_time_samp_update;
    NSInteger *_time_samp_remind;
    NSString *_creator;
    NSString *_tag;
    NSString *_meetingid;
    NSString *_taskid;
    NSInteger *_status;
    BOOL *_isnew;
}

@property(nonatomic,copy) NSString *uid;
@property(nonatomic,copy) NSString *subject;
@property(nonatomic) NSInteger *ctype;
@property(nonatomic) NSInteger *time_samp;
@property(nonatomic) NSInteger *time_samp_update;
@property(nonatomic) NSInteger *time_samp_remind;
@property(nonatomic,copy) NSString *creator;
@property(nonatomic,copy) NSString *tag;
@property(nonatomic,copy) NSString *meetingid;
@property(nonatomic,copy) NSString *taskid;
@property(nonatomic) NSInteger *status;
@property(nonatomic) BOOL *isnew;

@end

//
//  BTApplication.h
//  SayAbout
//
//  Created by admin on 14-8-15.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger, BTTopicType) {
    BTTopicTypeMeeting = 0,
    BTTopicTypeTask = 1,
};

// 用户当前交互界面标识
typedef NS_ENUM(NSInteger, BTUI) {
    
    BTUIHome = 1,    //
    BTUITopic = 2,   //
    BTUIChat = 3,    //
    BTUIContact = 4, //
    BTUISet = 5,     // 设置
    
    BTUITopicMessage = 21,
    BTUIChatMessage = 31
};

typedef NS_ENUM(NSInteger, BTRequestId) {
    BTMeetingSelectAdmin = 11,
    BTMettingSelectPeople = 12,
    BTTaskSelectAdmin = 21,
    BTTaskSelectPeople = 22,
    BTChatCreateSelectPeople = 31,
//    BTContactSelectPeople = 41
    
};

@protocol OnResultValueDelegate <NSObject>

-(void)on_result_value:(NSDictionary *) values requestId:(NSInteger) requestId; // 设置数据信息（后期迁移至此方法）

@property NSInteger mRequestId;

@end

@interface BTApplication : NSObject

@end

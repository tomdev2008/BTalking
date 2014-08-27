//
//  MessageTools.h
//  SayAbout
//
//  Created by admin on 14-8-7.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageTools : NSObject

+(NSMutableAttributedString *) getExpressionString: (NSString *) text;

+(NSMutableAttributedString *) exp_record:(NSString *) text;

+(NSMutableAttributedString *) exp_image:(NSString *) text;

+(NSMutableAttributedString *) exp_file:(NSString *) text;

+(NSMutableDictionary *)check_message_type: (NSString *) text;

@end

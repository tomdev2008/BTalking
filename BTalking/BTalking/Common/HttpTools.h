//
//  HttpTool.h
//  BTalking
//
//  Created by admin on 14-8-22.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpTools : NSObject

// 组合GET参数
+(NSString *) method_get_params:(NSMutableDictionary *) data;

@end

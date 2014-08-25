//
//  HttpTool.m
//  BTalking
//
//  Created by admin on 14-8-22.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import "HttpTools.h"
#import "ASIHTTPRequest.h"

@implementation HttpTools

// 组合GET参数
+(NSString *) method_get_params:(NSMutableDictionary *) data
{
    NSString *url = @"";
    
        NSString *key;
        
        NSEnumerator *enums = [data keyEnumerator];
        while(key = (NSString*)[enums nextObject])
        {
            id value;
            value = [data objectForKey:key];

            if (value!=nil)
            {
                if([value isKindOfClass:[NSString class]])
                {
                    NSString *cvalue = (NSString *)value;
                    url = [url stringByAppendingFormat:@"%@%@%@%@",@"&", key, @"=", cvalue];
                }
            }
        }
        
        // 增加随机参数
        url = [url stringByAppendingFormat:@"%@%u",@"&rnd=", arc4random()];
    
    return url;

}

@end

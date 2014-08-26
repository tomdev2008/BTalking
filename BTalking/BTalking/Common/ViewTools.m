//
//  ViewTools.m
//  BTalking
//
//  Created by admin on 14-8-25.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import "ViewTools.h"

@implementation ViewTools

+(void) log_bounds: (NSString *)viewname view:(UIView *)view
{
    NSLog(@"%@%@%f%@%f", viewname, @" x:", view.frame.origin.x,  @"y:", view.frame.origin.y);
    NSLog(@"%@%@%f%@%f", viewname, @" h:", view.frame.size.height,  @"w:", view.frame.size.width);
}


@end

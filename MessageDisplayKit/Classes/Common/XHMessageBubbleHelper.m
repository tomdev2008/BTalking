//
//  XHMessageBubbleHelper.m
//  MessageDisplayExample
//
//  Created by 曾 宪华 on 14-6-2.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//


#import "NSMutableAttributedString+Helper.h"
#import "XHMessageBubbleHelper.h"

@interface XHMessageBubbleHelper () {
    NSCache *_attributedStringCache;
}

@end

@implementation XHMessageBubbleHelper

+ (instancetype)sharedMessageBubbleHelper {
    static XHMessageBubbleHelper *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[XHMessageBubbleHelper alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _attributedStringCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)setDataDetectorsAttributedAttributedString:(NSMutableAttributedString *)attributedString
                                            atText:(NSString *)text
                             withRegularExpression:(NSRegularExpression *)expression
                                        attributes:(NSDictionary *)attributesDict {
    [expression enumerateMatchesInString:text
                                 options:0
                                   range:NSMakeRange(0, [text length])
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                  NSRange matchRange = [result range];
                                  if (attributesDict) {
                                      [attributedString addAttributes:attributesDict range:matchRange];
                                  }
                                  
                                  if ([result resultType] == NSTextCheckingTypeLink) {
                                      NSURL *url = [result URL];
                                      [attributedString addAttribute:NSLinkAttributeName value:url range:matchRange];
                                  } else if ([result resultType] == NSTextCheckingTypePhoneNumber) {
                                      NSString *phoneNumber = [result phoneNumber];
                                      [attributedString addAttribute:NSLinkAttributeName value:phoneNumber range:matchRange];
                                  } else if ([result resultType] == NSTextCheckingTypeDate) {
//                                      NSDate *date = [result date];
                                  }
                              }];
}

- (NSAttributedString *)bubbleAttributtedStringWithText:(NSString *)text {
    if (!text) {
        return [[NSAttributedString alloc] init];
    }
    if ([_attributedStringCache objectForKey:text]) {
        return [_attributedStringCache objectForKey:text];
    }
    
    
    text = @"测试富文本显示";
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:text];
    //为所有文本设置字体
    [attributedString1 addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:24] range:NSMakeRange(0, [attributedString1 length])];
    //将“测试”两字字体颜色设置为蓝色
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, 2)];
    //将“富文本”三个字字体颜色设置为红色
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(2, 3)];
    
    
    
    NSDictionary *textAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0.185 green:0.583 blue:1.000 alpha:1.000]};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber | NSTextCheckingTypeDate
                                                               error:nil];
    
    [self setDataDetectorsAttributedAttributedString:attributedString1 atText:text withRegularExpression:detector attributes:textAttributes];
    
    
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/s(13[0-9]|15[0-35-9]|18[0-9]|14[57])[0-9]{8}"
//                                                                           options:0
//                                                                             error:nil];
//    [self setDataDetectorsAttributedAttributedString:attributedString atText:text withRegularExpression:regex attributes:textAttributes];
    
    [_attributedStringCache setObject:attributedString forKey:text];
    
    return attributedString;
}

@end

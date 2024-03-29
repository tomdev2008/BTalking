//
//  MessageTools.m
//  SayAbout
//
//  Created by admin on 14-8-7.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import "MessageTools.h"
#import "XHMessageBubbleFactory.h"
#import "AppDelegate.h"

@implementation MessageTools


+(NSMutableAttributedString *)getExpressionString: (NSString *) text
{
    
    NSMutableAttributedString *attributed_text = [[NSMutableAttributedString alloc] initWithString:text];
    
    
    NSError *error;
    NSString *pattern = @"\\[\\[(.*?):(.*?)\\]\\]";

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    
    NSArray* matchers = [regex matchesInString:text options:NSMatchingCompleted range:NSMakeRange(0, [text length])];

    if (matchers.count != 0)
    {
        for (NSTextCheckingResult *match in matchers)
        {
            NSRange range = [match range];
            NSLog(@"%lu,%lu,%@",(unsigned long)range.location,(unsigned long)range.length,[text substringWithRange:range]);
            
            NSRange r1 = [match rangeAtIndex:1];
            NSString *ctype = [text substringWithRange:r1];
            NSString *cvalue = [text substringWithRange:[match rangeAtIndex:2]];
            
            NSLog(@"%@%@%@", ctype, @":", cvalue);
            
            if([@"face" isEqualToString:ctype])
            {
                NSMutableAttributedString *attributedString = [MessageTools exp_face:cvalue];
                [attributed_text replaceCharactersInRange:range withAttributedString:attributedString];
            }
            if ([@"record" isEqualToString:ctype])
            {
                NSMutableAttributedString *attributedString = [MessageTools exp_record:cvalue];
                [attributed_text replaceCharactersInRange:range withAttributedString:attributedString];
            }
            if ([@"image" isEqualToString:ctype])
            {
                NSMutableAttributedString *attributedString = [MessageTools exp_image:cvalue];
                [attributed_text replaceCharactersInRange:range withAttributedString:attributedString];
            }
            if ([@"file" isEqualToString:ctype])
            {
                NSMutableAttributedString *attributedString = [MessageTools exp_file:cvalue];
                [attributed_text replaceCharactersInRange:range withAttributedString:attributedString];
            }
        }
    }
    
    NSLog(@"%@", attributed_text);
    
    return attributed_text;
    
}

+(NSMutableAttributedString *) exp_face:(NSString *) text
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:@""];

    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSMutableArray *faceArray = [[NSMutableArray alloc]init];
    faceArray = delegate._faceArray;
    
    int findex = -1;
    
    for(int i=0;i<faceArray.count;i++)
    {
        if( [((NSString *)[faceArray[i] objectForKey:@"cname"]) isEqualToString:text])
        {
            findex = i;
            break;
        }
    }
    
    NSTextAttachment *attachment=[[NSTextAttachment alloc] initWithData:nil ofType:nil];
    NSString *filename = [faceArray[findex] objectForKey:@"filename"];
    UIImage *img=[UIImage imageNamed:filename];
    attachment.image=img;
    [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    return attributedString;
}


+(NSMutableAttributedString *) exp_record:(NSString *) text
{

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:@""];
    
    UIImage *chosenImage = [UIImage imageNamed:@"ReceiverVoiceNodePlaying003@2x.png"];
    
    
    NSTextAttachment* onionatt = [NSTextAttachment new];
    onionatt.image = chosenImage;
    onionatt.bounds = CGRectMake(0,0,40,40);
    NSAttributedString* imageAttributedString = [NSAttributedString attributedStringWithAttachment:onionatt];

    [attributedString insertAttributedString:imageAttributedString atIndex:0];
    return attributedString;
}

+(NSMutableAttributedString *) exp_image:(NSString *) text
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:@""];
    
    UIImage *chosenImage = [UIImage imageNamed:@"app_panel_pic_icon.9.png"];
    
    NSTextAttachment* onionatt = [NSTextAttachment new];
    onionatt.image = chosenImage;
    onionatt.bounds = CGRectMake(0,0,40,40);
    
    NSAttributedString* imageAttributedString = [NSAttributedString attributedStringWithAttachment:onionatt];
    
    [attributedString insertAttributedString:imageAttributedString atIndex:0];
    
    NSLog(@"astring: %@", attributedString);
    
    return attributedString;
}

+(NSMutableAttributedString *) exp_file:(NSString *) text
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:@""];
    
    UIImage *chosenImage = [UIImage imageNamed:@"app_panel_pic_icon.9.png"];
    
    NSTextAttachment* onionatt = [NSTextAttachment new];
    onionatt.image = chosenImage;
    onionatt.bounds = CGRectMake(0,0,40,40);
    
    NSAttributedString* imageAttributedString = [NSAttributedString attributedStringWithAttachment:onionatt];
    
    [attributedString insertAttributedString:imageAttributedString atIndex:0];
    
    NSLog(@"astring: %@", attributedString);
    
    return attributedString;
}


+(NSMutableDictionary *)check_message_type: (NSString *) text
{
    NSMutableDictionary *dictionary =  [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"TEMP",@"",nil];
    
    
    NSMutableAttributedString *attributed_text = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSLog(@"begin:%@",attributed_text);

    
    NSError *error;
    NSString *pattern = @"\\[\\[(.*?):(.*?)\\]\\]";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray* matchers = [regex matchesInString:text options:NSMatchingCompleted range:NSMakeRange(0, [text length])];
    
    if (matchers.count != 0)
    {
        for (NSTextCheckingResult *match in matchers)
        {
            NSRange range = [match range];
            
            NSString *tagString = [text substringWithRange:range];  // 整个匹配串
            NSRange r1 = [match rangeAtIndex:1];
            NSString *ctype = [text substringWithRange:r1];
            NSString *cvalue = [text substringWithRange:[match rangeAtIndex:2]];
            
            NSLog(@"%@%@%@", ctype, @":", cvalue);
            
            if([@"face" isEqualToString:ctype])
            {
                
                
//                NSRange range = NSMakeRange(0,11);
//                NSString *rtext = @"[[face:大笑]]";
//                
//                NSTextAttachment *attachment=[[NSTextAttachment alloc] initWithData:nil ofType:nil];
//                UIImage *img=[UIImage imageNamed:@"f001.gif"];
//                attachment.image=img;
//                attachment.bounds=CGRectMake(0, -10, 20, 20);
//                NSAttributedString *attachmentstr=[NSAttributedString attributedStringWithAttachment:attachment];
//
//                [attributed_text replaceCharactersInRange:range withAttributedString:attachmentstr];
                
                [dictionary setValue:ctype forKey:@"mediatype"];
                break;
            }
            if ([@"record" isEqualToString:ctype])
            {
                [dictionary setValue:ctype forKey:@"mediatype"];
                [dictionary setValue:cvalue forKey:@"fileid"];
                break;
            }
            if ([@"image" isEqualToString:ctype])
            {
                [dictionary setValue:ctype forKey:@"mediatype"];
                [dictionary setValue:cvalue forKey:@"fileid"];
                break;
            }
            if ([@"file" isEqualToString:ctype])
            {
                [dictionary setValue:ctype forKey:@"mediatype"];
                [dictionary setValue:cvalue forKey:@"fileid"];
                break;
            }
        }
    }
    
         NSLog(@"end:%@",attributed_text);
    
    [dictionary setValue:attributed_text forKey:@"attributedtext"];
    
    
    return dictionary;
    
}



@end

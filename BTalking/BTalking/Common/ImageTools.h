//
//  ImageTools.h
//  SayAbout
//
//  Created by admin on 14-8-11.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageTools : NSObject

+ (NSString *)save_image:(UIImage *)tempImage WithName:(NSString *)imageName; // 图片存储为文件

+ (NSString *)documentFolderPath; // 获取沙盒文档目录

+ (UIImage*)compress_image:(UIImage*)image scaledToSize:(CGSize)newSize;
@end

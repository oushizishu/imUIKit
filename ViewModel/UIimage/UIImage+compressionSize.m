//
//  UIImage+limitSizeData.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/29.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "UIImage+compressionSize.h"

const float Compression_Max_Width = 2000;
const float Compression_Max_HEIGHT = 2000;

@implementation UIImage (compressionSize)

//对图片尺寸进行压缩--
-(UIImage*)imageToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

/**
 *  根据传入的size压缩返回一个符合要求的data数据
 *
 *  @param size 最大的大小，单位m
 *
 *  @return jpg格式的data数据
 */
- (NSData *)bj_jpgDataWithCompressionSize:(long long)size
{
    CGSize newSize = self.size;
    BOOL sizeChage = NO;
//    if (self.size.width > Compression_Max_Width) {
//        newSize.height = self.size.height * (Compression_Max_Width / self.size.width);
//        newSize.width = Compression_Max_Width;
//        sizeChage = YES;
//    }
//    if (newSize.height > Compression_Max_HEIGHT) {
//        newSize.width = newSize.width * (Compression_Max_HEIGHT / newSize.height);
//        newSize.height = Compression_Max_HEIGHT;
//        
//        sizeChage = YES;
//    }
    
    UIImage *newImage = self;
    if (sizeChage) {
        newImage = [self imageToSize:newSize];
    }
    
    //JEPG格式
    NSData *data = UIImageJPEGRepresentation(newImage, 1);
    float length = data.length/1024/1024.0;
    if (length>size) {
        CGFloat compressionQuality = size*1024*1024/data.length;
        data = UIImageJPEGRepresentation(newImage, compressionQuality);
    }
    return data;
}

@end

//
//  LocalImageCache.h
//  Pods
//
//  Created by bjhl on 15/8/12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UIKitDefines.h>
#import <UIImageView+Aliyun.h>

#define LocalImageCacheFloder @"Localimagecachefloder"


@interface LoadLocalImageOperation : NSOperation

@property(strong ,nonatomic)NSURL *fileUrl;
@property(nonatomic)CGSize size;
@property(weak,nonatomic)UIImageView *imageView;

@end

@interface LocalImageCache : NSObject

@property(strong ,nonatomic)NSOperationQueue *operationQ;

+ (instancetype)sharedInstance;

-(void)setLocalImage:(NSURL*)url withSize:(CGSize)size withImageView:(UIImageView*)imageView;

@end

//
//  MyFacialView.h
//  BJEducation
//
//  Created by archer on 11/28/14.
//  Copyright (c) 2014 com.bjhl. All rights reserved.
//

@protocol BJFacialViewDelegate

@optional
-(void)selectThenSendImage:(UIImage *)img emoji:(NSString *)emoji;

@end


@interface BJFacialView : UIScrollView

@property(nonatomic,assign) id<BJFacialViewDelegate>  facialDelegate;

@property(strong, nonatomic, readonly) NSArray *faces;
@property(strong, nonatomic, readonly) NSArray *emojiTexts;
@property(strong, nonatomic, readonly) NSArray *emojiTitles;
-(void)loadFacialView:(int)page size:(CGSize)size;

+ (NSString *)imageNamedWithEmoji:(NSString *)emoji;
+ (NSString *)imageUrlWithEmoji:(NSString *)emoji;

@end

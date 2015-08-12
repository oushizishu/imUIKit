//
//  BJImageChatCell.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/27.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJImageChatCell.h"
#import "BJChatCellFactory.h"
#import <BJIMConstants.h>
#import <PureLayout/PureLayout.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIImageView+Aliyun.h>
#import "UIResponder+BJIMChatRouter.h"
#import "BJChatUtilsMacro.h"

const float BJ_MAX_SIZE = 120; //　图片最大显示大小


@interface BJImageChatCell ()
@property (strong, nonatomic) UIImageView *chatImageView;
@end

@implementation BJImageChatCell

+ (void)load
{
    [ChatCellFactoryInstance registerClass:[self class] forMessageType:eMessageType_IMG];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.bubbleContainerView.bounds;
    [self.chatImageView setFrame:frame];
}

#pragma mark - 内部方法
- (CGSize)calculateCellHeight
{
    CGSize retSize = self.message.imageSize;
    NSLog(@"calculateCellHeight,%@",NSStringFromCGSize(retSize));
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = BJ_MAX_SIZE;
        retSize.height = BJ_MAX_SIZE;
    }else if (retSize.width > retSize.height) {
        CGFloat height =  BJ_MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = BJ_MAX_SIZE;
    }else {
        CGFloat width = BJ_MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = BJ_MAX_SIZE;
    }
    return retSize;
}

- (void)bubbleViewPressed:(id)sender
{
    [super bjim_routerEventWithName:kBJRouterEventImageBubbleTapEventName userInfo:@{kBJRouterEventUserInfoObject:self.message}];
}

#pragma mark - Protocol
/**
 *  实现初始化方法，外部只调用此方法
 *
 *  @return
 */
- (instancetype)init;
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BJImageChatCell class])];
    if (self) {
        
    }
    return self;
}

-(void)setCellInfo:(id)info indexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"BJImageChatCell setCellInfo start");
    [super setCellInfo:info indexPath:indexPath];

    //self.chatImageView.image = nil;
    
#if 1
    
    CGRect rect = CGRectZero;
    if ([self.message.imageURL isFileURL]) {
        UIImage *thumbnailImage = [[BJChatCellFactory sharedInstance] getMsgThumbnailImage:[self.message.imageURL relativePath]];
        if (thumbnailImage == nil) {
            thumbnailImage = [self getThumbnailImage];
            [[BJChatCellFactory sharedInstance] setMsgThumbnailImage:thumbnailImage withMsgID:[self.message.imageURL relativePath]];
        }
        
        rect = CGRectMake(0, 0, thumbnailImage.size.width/2, thumbnailImage.size.height/2);
        
        self.chatImageView.frame = rect;
        self.chatImageView.image = thumbnailImage;
    }
    else
    {
        CGSize size = [self calculateCellHeight];
        @IMTODO("设置默认图片");
        [self.chatImageView setAliyunImageWithURL:self.message.imageURL placeholderImage:nil size:size];
        rect = self.chatImageView.frame;
        rect.size = size;
        self.chatImageView.frame = rect;
    }
    
#else
    CGSize size = [self calculateCellHeight];
    @IMTODO("设置默认图片");
    [self.chatImageView setAliyunImageWithURL:self.message.imageURL placeholderImage:nil size:size];
    CGRect rect = self.chatImageView.frame;
    rect.size = size;
    self.chatImageView.frame = rect;
    UIImage *image = [self bubbleImage];
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(self.chatImageView.frame, 2.0f, 2.0f);
    self.chatImageView.layer.mask = imageViewMask.layer;
    
    rect = self.bubbleContainerView.frame;
    rect.size = size;
    self.bubbleContainerView.frame = rect;
#endif
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    NSLog(@"BJImageChatCell setCellInfo end");
}

-(UIImage*)getThumbnailImage
{
    UIImage *image = [UIImage imageWithContentsOfFile:[self.message.imageURL relativePath]];
    CGSize reSize = CGSizeZero;
    
    CGSize size = CGSizeMake(image.size.width, image.size.height);
    CGSize referenceSize = CGSizeMake(200, 200);
    
    CGFloat coefficients = 0.0f;
    
    coefficients = size.width/referenceSize.width;
    
    if (coefficients < (size.height/referenceSize.height)) {
        coefficients = (size.height/referenceSize.height);
    }
    
    if (coefficients != 0) {
        reSize = CGSizeMake(size.width/coefficients, size.height/coefficients);
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width*2, reSize.height*2));
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,reSize.width*2,reSize.height*2)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - set get
- (UIImageView *)chatImageView
{
    if (_chatImageView == nil) {
        _chatImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _chatImageView.userInteractionEnabled = YES;
        _chatImageView.multipleTouchEnabled = YES;
        [self.bubbleContainerView addSubview:_chatImageView];
    }
    return _chatImageView;
}

@end

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
#import "LocalImageCache.h"

const CGFloat BJ_MAX_SIZE = 120; //　图片最大显示大小
const CGFloat BJ_MIN_SIZE = 37; //　图片最大显示大小

@interface BJImageChatCell ()
@property (strong, nonatomic) UIImageView *chatImageView;
@end

@implementation BJImageChatCell

+ (void)load
{
    [ChatCellFactoryInstance registerClass:[self class] forMessageType:eMessageType_IMG];
}

- (UIImage *)bubbleBorderImage
{
    NSString *imageName = !self.message.isMySend ? @"bg_pic_left_n" : @"bg_pic_right_n";
    NSInteger leftCapWidth = !self.message.isMySend?15:5;
    NSInteger topCapHeight =  !self.message.isMySend?35:35;
    return [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
}

- (UIImage *)bubbleImage
{
    NSString *imageName = !self.message.isMySend ? @"bg_card_left_n" : @"bg_card_right_n";
    NSInteger leftCapWidth = !self.message.isMySend?15:5;
    NSInteger topCapHeight =  !self.message.isMySend?35:35;
    return [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
}

-(void)layoutSubviews
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGSize size = [self calculateCellHeight];
 
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
    
    [super layoutSubviews];
    CGRect frame = self.bubbleContainerView.bounds;
    [self.chatImageView setFrame:frame];
    
    [CATransaction commit];
}

#pragma mark - 内部方法
- (CGSize)calculateCellHeight
{
    CGSize retSize = self.message.imageSize;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = BJ_MIN_SIZE*2;
        retSize.height = BJ_MIN_SIZE*2;
    }else {
        CGFloat width = MAX(MIN(BJ_MAX_SIZE, retSize.width),BJ_MIN_SIZE);
        CGFloat height =  MAX(MIN(width/retSize.width*retSize.height,BJ_MAX_SIZE*2),BJ_MIN_SIZE);
        retSize.width = width;
        retSize.height = height;
    }
    return retSize;
}

- (CGSize)calculateImageContentHeight
{
    CGSize retSize = self.message.imageSize;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = BJ_MIN_SIZE*2;
        retSize.height = BJ_MIN_SIZE*2;
    }else if (retSize.width > retSize.height) {
        CGFloat height =  BJ_MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = BJ_MAX_SIZE;
        if (height < BJ_MIN_SIZE) {
            CGFloat width =  BJ_MIN_SIZE / retSize.height  *  retSize.width;
            retSize.width = width;
            retSize.height = BJ_MIN_SIZE;
        }
    }else {
        CGFloat width = BJ_MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = BJ_MAX_SIZE;
        if (width < BJ_MIN_SIZE) {
            CGFloat height =  BJ_MIN_SIZE / retSize.width  *  retSize.height;
            retSize.height = height;
            retSize.width = BJ_MIN_SIZE;
        }
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
    [super setCellInfo:info indexPath:indexPath];

    self.chatImageView.image = nil;
    
    CGSize size = [self calculateImageContentHeight];
    @IMTODO("设置默认图片");
    if ([self.message.imageURL isFileURL]) {
        [[LocalImageCache sharedInstance] setLocalImage:self.message.imageURL withSize:size withImageView:self.chatImageView];
    }else
    {
        [self.chatImageView setAliyunImageWithURL:self.message.imageURL placeholderImage:nil size:size];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - set get
- (UIImageView *)chatImageView
{
    if (_chatImageView == nil) {
        _chatImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _chatImageView.userInteractionEnabled = YES;
        _chatImageView.multipleTouchEnabled = YES;
        
        [_chatImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.bubbleContainerView addSubview:_chatImageView];
    }
    return _chatImageView;
}

@end

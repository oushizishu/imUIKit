//
//  BJAudioChatCell.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/27.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJAudioChatCell.h"
#import "BJChatCellFactory.h"
#import <BJIMConstants.h>
#import <PureLayout/PureLayout.h>
#import <BJAudioPlayer.h>
#import "UIResponder+BJIMChatRouter.h"
#import "BJAudioShowCalculation.h"

#define BJ_ANIMATION_IMAGEVIEW_HEIGHT 17.5 // 小喇叭图片尺寸
#define BJ_ANIMATION_IMAGEVIEW_WIDTH 11
#define BJ_ANIMATION_IMAGEVIEW_SPEED 1 // 小喇叭动画播放速度


#define BJ_BJ_ANIMATION_TIME_LABEL_WIDHT 5 // 时间与动画间距


#define BJ_ANIMATION_TIME_LABEL_WIDHT 40 // 时间宽度
#define BJ_ANIMATION_TIME_LABEL_HEIGHT 15 // 时间高度
#define BJ_ANIMATION_TIME_LABEL_FONT_SIZE 14 // 时间字体

// 发送
#define BJ_SENDER_ANIMATION_IMAGEVIEW_IMAGE_DEFAULT @"ic_volume_li_gary3" // 小喇叭默认图片
#define BJ_SENDER_ANIMATION_IMAGEVIEW_IMAGE_01 @"ic_volume_li_gary1" // 小喇叭动画第一帧
#define BJ_SENDER_ANIMATION_IMAGEVIEW_IMAGE_02 @"ic_volume_li_gary2" // 小喇叭动画第二帧
#define BJ_SENDER_ANIMATION_IMAGEVIEW_IMAGE_03 @"ic_volume_li_gary3" // 小喇叭动画第三帧
#define BJ_SENDER_ANIMATION_IMAGEVIEW_IMAGE_04 @"ic_volume_li_gary3" // 小喇叭动画第四帧


// 接收
#define BJ_RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_DEFAULT @"ic_volume_ri_gre3" // 小喇叭默认图片
#define BJ_RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_01 @"ic_volume_ri_gre1" // 小喇叭动画第一帧
#define BJ_RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_02 @"ic_volume_ri_gre2" // 小喇叭动画第二帧
#define BJ_RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_03 @"ic_volume_ri_gre3" // 小喇叭动画第三帧
#define BJ_RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_04 @"ic_volume_ri_gre3" // 小喇叭动画第四帧

@interface BJAudioChatCell ()
@property (strong, nonatomic) UIImageView *animationImageView; // 动画的ImageView
@property (strong, nonatomic) UILabel *timeLabel; // 时间label


@property (strong, nonatomic) NSMutableArray *senderAnimationImages;
@property (strong, nonatomic) NSMutableArray *recevierAnimationImages;
@property (strong, nonatomic) UIImageView    *isReadView;

@end

@implementation BJAudioChatCell

+ (void)load
{
    [ChatCellFactoryInstance registerClass:[self class] forMessageType:eMessageType_AUDIO];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.animationImageView.frame;
    if (self.message.isMySend) {
        frame.origin.x = self.bubbleContainerView.frame.size.width - BJ_BUBBLE_ARROW_WIDTH - frame.size.width - BJ_BUBBLE_VIEW_PADDING;
        frame.origin.y = self.bubbleContainerView.frame.size.height / 2 - frame.size.height / 2;
        self.animationImageView.frame = frame;
        
        frame = self.timeLabel.frame;
        frame.origin.x = self.animationImageView.frame.origin.x - BJ_BJ_ANIMATION_TIME_LABEL_WIDHT - BJ_ANIMATION_TIME_LABEL_WIDHT;
        frame.origin.y = self.bubbleContainerView.frame.size.height / 2 - frame.size.height / 2;
        self.timeLabel.frame = frame;
        
    }
    else {
        self.animationImageView.image = [UIImage imageNamed:BJ_RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_DEFAULT];
        
        frame.origin.x = BJ_BUBBLE_ARROW_WIDTH + BJ_BUBBLE_VIEW_PADDING;
        frame.origin.y = self.bubbleContainerView.frame.size.height / 2 - frame.size.height / 2;
        self.animationImageView.frame = frame;
        
        frame = self.timeLabel.frame;
        frame.origin.x = BJ_BJ_ANIMATION_TIME_LABEL_WIDHT + BJ_BUBBLE_ARROW_WIDTH + self.animationImageView.frame.size.width + self.animationImageView.frame.origin.x;
        frame.origin.y = self.animationImageView.center.y - frame.size.height / 2;
        self.timeLabel.frame = frame;
        frame.origin.x += frame.size.width - self.isReadView.frame.size.width / 2;
        frame.origin.y = - self.isReadView.frame.size.height / 2;
        frame.size = self.isReadView.frame.size;
        self.isReadView.frame = frame;
    }
    
}

#pragma mark - 方法
-(void)startAudioAnimation
{
    [self.animationImageView startAnimating];
}

-(void)stopAudioAnimation
{
    [self.animationImageView stopAnimating];
}

- (void)bubbleViewPressed:(id)sender
{
    [super bjim_routerEventWithName:kBJRouterEventAudioBubbleTapEventName userInfo:@{kBJRouterEventUserInfoObject:self.message}];
}

#pragma mark - Protocol
/**
 *  实现初始化方法，外部只调用此方法
 *
 *  @return
 */
- (instancetype)init;
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BJAudioChatCell class])];
    if (self) {
        CGFloat width = BJ_BUBBLE_VIEW_PADDING*2 + BJ_BUBBLE_ARROW_WIDTH + BJ_ANIMATION_TIME_LABEL_WIDHT +BJ_BJ_ANIMATION_TIME_LABEL_WIDHT + BJ_ANIMATION_IMAGEVIEW_WIDTH;
        
        CGFloat maxHeight = MAX(BJ_ANIMATION_IMAGEVIEW_HEIGHT, BJ_ANIMATION_TIME_LABEL_HEIGHT);
        CGFloat height = BJ_BUBBLE_VIEW_PADDING*2 + maxHeight;
        CGRect rect = self.bubbleContainerView.frame;
        rect.size.width = width;
        rect.size.height = height;
        self.bubbleContainerView.frame = rect;
    }
    return self;
}

-(void)setCellInfo:(id)info indexPath:(NSIndexPath *)indexPath;
{
    [super setCellInfo:info indexPath:indexPath];
    self.backImageView.image = [self bubbleImage];
    self.timeLabel.text = [NSString stringWithFormat:@"%ld''",(long)self.message.time];
    
    if (self.message.isMySend) {
        [self.isReadView setHidden:YES];
        self.animationImageView.image = [UIImage imageNamed:BJ_SENDER_ANIMATION_IMAGEVIEW_IMAGE_DEFAULT];
        self.animationImageView.animationImages = self.senderAnimationImages;
    }
    else{
        if (self.message.isPlayed) {
            [self.isReadView setHidden:YES];
        }else{
            [self.isReadView setHidden:NO];
        }
        
        self.animationImageView.image = [UIImage imageNamed:BJ_RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_DEFAULT];
        self.animationImageView.animationImages = self.recevierAnimationImages;
    }
    
    CGRect rect = self.bubbleContainerView.frame;
    rect.size.width = [[BJAudioShowCalculation sharedInstance] calculationShowWidth:self.message.time];
    self.bubbleContainerView.frame = rect;
    
    if (self.message.isPlaying)
    {
        [self startAudioAnimation];
    }else {
        [self stopAudioAnimation];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - set get

- (UIImageView *)animationImageView
{
    if (_animationImageView == nil) {
        _animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BJ_ANIMATION_IMAGEVIEW_WIDTH, BJ_ANIMATION_IMAGEVIEW_HEIGHT)];
        _animationImageView.animationDuration = BJ_ANIMATION_IMAGEVIEW_SPEED;
        [self.bubbleContainerView addSubview:_animationImageView];
    }
    return _animationImageView;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BJ_ANIMATION_TIME_LABEL_WIDHT, BJ_ANIMATION_TIME_LABEL_HEIGHT)];
        _timeLabel.font = [UIFont boldSystemFontOfSize:BJ_ANIMATION_TIME_LABEL_FONT_SIZE];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self.bubbleContainerView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UIImageView *)isReadView
{
    if (_isReadView == nil) {
        _isReadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _isReadView.layer.cornerRadius = 5;
        [_isReadView setClipsToBounds:YES];
        [_isReadView setBackgroundColor:[UIColor redColor]];
        [self.bubbleContainerView addSubview:_isReadView];
    }
    return _isReadView;
}

- (NSMutableArray *)senderAnimationImages
{
    if (_senderAnimationImages == nil) {
            _senderAnimationImages = [[NSMutableArray alloc] initWithObjects: [UIImage imageNamed:BJ_SENDER_ANIMATION_IMAGEVIEW_IMAGE_01], [UIImage imageNamed:BJ_SENDER_ANIMATION_IMAGEVIEW_IMAGE_02], [UIImage imageNamed:BJ_SENDER_ANIMATION_IMAGEVIEW_IMAGE_03], [UIImage imageNamed:BJ_SENDER_ANIMATION_IMAGEVIEW_IMAGE_04], nil];
    }
    return _senderAnimationImages;
}

- (NSMutableArray *)recevierAnimationImages
{
    if (_recevierAnimationImages == nil) {
        _recevierAnimationImages = [[NSMutableArray alloc] initWithObjects: [UIImage imageNamed:BJ_RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_01], [UIImage imageNamed:BJ_RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_02], [UIImage imageNamed:BJ_RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_03], [UIImage imageNamed:BJ_RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_04], nil];
    }
    return _recevierAnimationImages;
}

@end

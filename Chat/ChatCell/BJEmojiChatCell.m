//
//  BJEmojiChatCell.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/27.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJEmojiChatCell.h"
#import "BJChatCellFactory.h"
#import <BJIMConstants.h>
#import <PureLayout/PureLayout.h>

#import "YLGIFImage.h"
#import "YLImageView.h"
#import "BJFacialView.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import <SDWebImage/UIImageView+WebCache.h>

const float BJ_EMOJI_MAX_SIZE = 60;


@interface BJEmojiChatCell ()
@property (strong, nonatomic) YLImageView *emojiImageView;
@end

@implementation BJEmojiChatCell

+ (void)load
{
    [ChatCellFactoryInstance registerClass:[self class] forMessageType:eMessageType_EMOJI];
}

-(void)layoutSubviews
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGSize size = [self calculateCellHeight];
    CGRect rect = self.emojiImageView.frame;
    rect.size = size;
    self.emojiImageView.frame = rect;
    
    rect = self.bubbleContainerView.frame;
    rect.size = size;
    self.bubbleContainerView.frame = rect;
    [super layoutSubviews];
    CGRect frame = self.bubbleContainerView.bounds;
    [self.emojiImageView setFrame:frame];
    [CATransaction commit];
}

#pragma mark - 内部方法
- (CGSize)calculateCellHeight
{
    CGSize retSize = self.message.emojiSize;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = BJ_EMOJI_MAX_SIZE;
        retSize.height = BJ_EMOJI_MAX_SIZE;
    }else if (retSize.width > retSize.height) {
        CGFloat height =  BJ_EMOJI_MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = BJ_EMOJI_MAX_SIZE;
    }else {
        CGFloat width = BJ_EMOJI_MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = BJ_EMOJI_MAX_SIZE;
    }
    return retSize;
}

- (void)bubbleViewLongPressed:(id)sender
{
    //[self bjim_routerEventWithName:kBJRouterEventChatCellBubbleLongTapEventName userInfo:@{kBJRouterEventUserInfoObject:self.message}];
        
    if (![UIMenuController sharedMenuController].menuVisible) {
        UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制"action:@selector(scopy:)];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect:CGRectMake(self.frame.origin.x+self.bubbleContainerView.frame.origin.x, self.frame.origin.y+self.bubbleContainerView.frame.origin.y, self.bubbleContainerView.frame.size.width, self.bubbleContainerView.frame.size.height) inView:self.superview];
        [menuController setMenuItems:[NSArray arrayWithObjects:copy, nil]];
        [menuController setMenuVisible:YES animated:YES];
        [self becomeFirstResponder];
    }
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(scopy:)) {
        return YES;
    }
    return NO; //隐藏系统默认的菜单项
}

- (void)scopy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"(*%@*)",[self.message emojiName]]];
}


#pragma mark - Protocol
/**
 *  实现初始化方法，外部只调用此方法
 *
 *  @return
 */
- (instancetype)init;
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BJEmojiChatCell class])];
    if (self) {
        
    }
    return self;
}

-(void)setCellInfo:(id)info indexPath:(NSIndexPath *)indexPath;
{
    [super setCellInfo:info indexPath:indexPath];
    NSString *gifLocal = [BJFacialView imageNamedWithEmoji:[self.message emojiName]];
    self.emojiImageView.image = nil;
    if (gifLocal.length>0) {
        self.emojiImageView.image = [YLGIFImage imageNamed:gifLocal];
    }
    else
    {
        [self.emojiImageView sd_setImageWithURL:[self.message emojiImageURL] placeholderImage:nil];
    }

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - set get
- (YLImageView *)emojiImageView
{
    if (_emojiImageView == nil) {
        _emojiImageView = [[YLImageView alloc] initWithFrame:CGRectMake(0, 0, BJ_EMOJI_MAX_SIZE, BJ_EMOJI_MAX_SIZE)];
        _emojiImageView.runLoopMode = NSDefaultRunLoopMode;
        [self.bubbleContainerView addSubview:_emojiImageView];

    }
    return _emojiImageView;
}

@end

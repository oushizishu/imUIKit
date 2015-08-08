//
//  BJTextChatCell.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/23.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJTextChatCell.h"
#import "BJChatCellFactory.h"
#import <BJIMConstants.h>
#import <PureLayout/PureLayout.h>
#import "BJAttributedHighlightLabel.h"
#import "BJChatUtilsMacro.h"
#import "UIResponder+BJIMChatRouter.h"

const float BUBBLE_PROGRESSVIEW_HEIGHT = 10; // progressView 高度

const float TEXTLABEL_MAX_WIDTH = 200; // textLaebl 最大宽度

@interface BJTextChatCell ()<AMAttributedHighlightLabelDelegate>
@property (nonatomic, strong) BJAttributedHighlightLabel *contentLabel;
@end

@implementation BJTextChatCell

+ (void)load
{
    [ChatCellFactoryInstance registerClass:[self class] forMessageType:eMessageType_TXT];
    [ChatCellFactoryInstance registerClass:[self class] forMessageType:unKownChatMessageType];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bubbleContainerView.bounds;
    frame.size.width -= BJ_BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, BJ_TEXTCHATCELL_PADDING, BJ_TEXTCHATCELL_PADDING);
    if (self.message.isMySend) {
        frame.origin.x = BJ_TEXTCHATCELL_PADDING;
    }else{
        frame.origin.x = BJ_TEXTCHATCELL_PADDING + BJ_BUBBLE_ARROW_WIDTH;
    }
    
    frame.origin.y = BJ_TEXTCHATCELL_PADDING;
    [self.contentLabel setFrame:frame];
}

- (void)bubbleViewLongPressed:(id)sender
{
    //[self bjim_routerEventWithName:kBJRouterEventChatCellBubbleLongTapEventName userInfo:@{kBJRouterEventUserInfoObject:self.message}];
    
    UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制"action:@selector(scopy:)];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:CGRectMake(self.frame.origin.x+self.bubbleContainerView.frame.origin.x, self.frame.origin.y+self.bubbleContainerView.frame.origin.y, self.bubbleContainerView.frame.size.width, self.bubbleContainerView.frame.size.height) inView:self.superview];
    [menuController setMenuItems:[NSArray arrayWithObjects:copy, nil]];
    [menuController setMenuVisible:YES animated:YES];
    [self becomeFirstResponder];
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
    [[UIPasteboard generalPasteboard] setString:self.message.content];
}

#pragma mark - Protocol
/**
 *  实现初始化方法，外部只调用此方法
 *
 *  @return
 */
- (instancetype)init;
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BJTextChatCell class])];
    if (self) {
        
    }
    return self;
}

-(void)setCellInfo:(id)info indexPath:(NSIndexPath *)indexPath;
{
    [super setCellInfo:info indexPath:indexPath];
    
    self.backImageView.image = [self bubbleImage];
  
    [self.contentLabel setString:self.message.msg_t==eMessageType_TXT?(self.message.content?:@""):@"当前版本暂不支持查看此消息,请升级新版本"];
    CGRect contentRect = self.contentLabel.frame;
    contentRect.size.width = TEXTLABEL_MAX_WIDTH;
    self.contentLabel.frame = contentRect;
    [self.contentLabel sizeToFit];
    contentRect = self.contentLabel.frame;
    contentRect.size.width = contentRect.size.width + BJ_TEXTCHATCELL_PADDING*2 + BJ_BUBBLE_ARROW_WIDTH;
    contentRect.size.height = contentRect.size.height + BJ_TEXTCHATCELL_PADDING*2;
    self.bubbleContainerView.frame = contentRect;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - 
- (void)selectedLink:(NSString *)string;
{
    [super bjim_routerEventWithName:kBJRouterEventLinkName userInfo:@{kBJRouterEventUserInfoObject:string}];
}

#pragma mark - set get

- (UILabel *)contentLabel
{
    if (_contentLabel == nil) {
        _contentLabel = [[BJAttributedHighlightLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.linkTextColor = [UIColor blueColor];
        _contentLabel.selectedLinkTextColor = [UIColor grayColor];
        _contentLabel.delegate = self;
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _contentLabel.font = [UIFont systemFontOfSize:BJ_TEXTCHARCELL_FONTSIZE];
        _contentLabel.textColor = [UIColor colorWithHexString:BJ_TEXTCHATCELL_FONTCOLOR];
        _contentLabel.userInteractionEnabled = YES;
        _contentLabel.backgroundColor = [UIColor clearColor];
        [self.bubbleContainerView addSubview:_contentLabel];
    }
    return _contentLabel;
}

@end

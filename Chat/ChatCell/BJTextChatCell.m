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
#import "BJChatUtilsMacro.h"
#import "UIResponder+BJIMChatRouter.h"
#import <BJHL-Common-iOS-SDK/UIColor+Util.h>
#import "SETextView.h"
#import "XHMessageBubbleHelper.h"

const float BUBBLE_PROGRESSVIEW_HEIGHT = 10; // progressView 高度

const float TEXTLABEL_MAX_WIDTH = 200; // textLaebl 最大宽度

@interface BJTextChatCell ()<SETextViewDelegate>
@property (nonatomic, strong) SETextView *displayTextView;

@end

@implementation BJTextChatCell

+ (void)load
{
    [ChatCellFactoryInstance registerClass:[self class] forMessageType:eMessageType_TXT];
    [ChatCellFactoryInstance registerClass:[self class] forMessageType:unKownChatMessageType];
}

-(void)layoutSubviews
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGRect contentRect = self.displayTextView.frame;
    CGFloat width = [UIScreen mainScreen].bounds.size.width - (HEAD_PADDING*2+HEAD_SIZE*2+35);

    self.displayTextView.frame = CGRectMake(0, 0, width, 20);
    [self.displayTextView sizeToFit];
    contentRect = self.displayTextView.frame;
    
    contentRect.size.width = contentRect.size.width + BJ_BUBBLE_VIEW_PADDING*2 + BJ_BUBBLE_ARROW_WIDTH;
    contentRect.size.height = contentRect.size.height + BJ_BUBBLE_VIEW_PADDING*2;
    self.bubbleContainerView.frame = contentRect;
    
    [super layoutSubviews];
    
    CGRect frame = self.bubbleContainerView.bounds;
    frame.size.width -= BJ_BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, BJ_BUBBLE_VIEW_PADDING, BJ_BUBBLE_VIEW_PADDING);
    if (self.message.isMySend) {
        frame.origin.x = BJ_BUBBLE_VIEW_PADDING;
    }else{
        frame.origin.x = BJ_BUBBLE_VIEW_PADDING + BJ_BUBBLE_ARROW_WIDTH;
    }
    
    frame.origin.y = BJ_BUBBLE_VIEW_PADDING;
    [self.displayTextView setFrame:frame];
    [CATransaction commit];
}

- (void)bubbleViewLongPressed:(id)sender
{
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
    if (self.message.content)
    {
        [[UIPasteboard generalPasteboard] setString:self.message.content];
    }
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
        [self.bubbleContainerView removeGestureRecognizer:self.tapGesture];
    }
    return self;
}

-(void)setCellInfo:(id)info indexPath:(NSIndexPath *)indexPath;
{
    [super setCellInfo:info indexPath:indexPath];
    
    self.backImageView.image = [self bubbleImage];
    
    NSString *message = self.message.msg_t==eMessageType_TXT?(self.message.content?:@""):@"当前版本暂不支持查看此消息,请升级新版本";
    
    self.displayTextView.attributedText = [[XHMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:message];

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - SETextViewDelegate
- (BOOL)textView:(SETextView *)textView clickedOnLink:(SELinkText *)link atIndex:(NSUInteger)charIndex
{
    if ([link.text hasPrefix:@"http"]) {
        [super bjim_routerEventWithName:kBJRouterEventLinkName userInfo:@{kBJRouterEventUserInfoObject:link.text}];
    }
    if ([self isPureInt:link.text]) {
        [super bjim_routerEventWithName:kBJRouterEventPhoneCall userInfo:@{kBJRouterEventUserInfoObject:link.text}];
    }
    return YES;
}

//判断书否为纯数字=手机号
- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

#pragma mark - set get
- (SETextView *)displayTextView
{
    // 2、初始化显示文本消息的TextView
    if (!_displayTextView) {
        SETextView *displayTextView = [[SETextView alloc] initWithFrame:CGRectZero];
        displayTextView.backgroundColor = [UIColor clearColor];
        displayTextView.selectable = NO;
        displayTextView.lineSpacing = 3.0;
        displayTextView.lineBreakMode = NSLineBreakByWordWrapping;
        displayTextView.linkHighlightColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        displayTextView.font = [UIFont systemFontOfSize:BJ_TEXTCHARCELL_FONTSIZE];
        displayTextView.showsEditingMenuAutomatically = NO;
        displayTextView.highlighted = YES;
        displayTextView.delegate = self;
        displayTextView.editable = NO;
        _displayTextView = displayTextView;
        [self.bubbleContainerView addSubview:displayTextView];
        
        [XHMessageBubbleHelper sharedMessageBubbleHelper].matchColor = [UIColor colorWithRed:0.185 green:0.583 blue:1.000 alpha:1.000];
        [XHMessageBubbleHelper sharedMessageBubbleHelper].normalColor = [UIColor colorWithHexString:BJ_TEXTCHATCELL_FONTCOLOR];
    }
    return _displayTextView;
}

@end

//
//  BJChatBaseBubbleCell.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/23.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJChatBaseCell.h"
#import <UIImageView+Aliyun.h>
#import "UIResponder+BJIMChatRouter.h"

const float HEAD_SIZE = 37; // 头像大小
const float HEAD_PADDING = 5; // 头像到cell的内间距和头像到bubble的间距


const float NAME_LABEL_WIDTH = 180; // nameLabel宽度
const float NAME_LABEL_HEIGHT = 20; // nameLabel 高度
const float NAME_LABEL_PADDING = 0; // nameLabel间距


const float SEND_STATUS_SIZE = 30; // 发送状态View的Size
const float ACTIVTIYVIEW_BUBBLE_PADDING = 5; // 菊花和bubbleView之间的间距

const float BUBBLE_RIGHT_LEFT_CAP_WIDTH = 5; // 文字在右侧时,bubble用于拉伸点的X坐标
const float BUBBLE_RIGHT_TOP_CAP_HEIGHT = 35; // 文字在右侧时,bubble用于拉伸点的Y坐标

const float BUBBLE_LEFT_LEFT_CAP_WIDTH = 15; // 文字在左侧时,bubble用于拉伸点的X坐标
const float BUBBLE_LEFT_TOP_CAP_HEIGHT = 35; // 文字在左侧时,bubble用于拉伸点的Y坐标

NSString *const BUBBLE_LEFT_IMAGE_NAME = @"bg_speech_nor"; // bubbleView 的背景图片
NSString *const BUBBLE_LEFT_IMAGE_NAME_NEW = @"bg_messages_gray_n"; //
NSString *const BUBBLE_RIGHT_IMAGE_NAME = @"bg_speech_gre_nor";
NSString *const BUBBLE_RIGHT_IMAGE_NAME_NEW = @"bg_messages_blue_n";



@implementation BJChatBaseCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupConfigure];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupConfigure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupConfigure];
    }
    return self;
}

- (void)setupConfigure
{
    UITapGestureRecognizer *headTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headViewPressed:)];
    [self.headImageView addGestureRecognizer:headTap];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
    [self.bubbleContainerView addGestureRecognizer:tap];
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewLongPressed:)];
    [self.bubbleContainerView addGestureRecognizer:recognizer];
    self.backgroundColor = [UIColor clearColor];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)shouldShowName
{
    if (self.message.chat_t == eChatType_GroupChat && !self.message.isMySend) {
        return YES;
    }
    return NO;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.headImageView.frame;
    frame.origin.x = self.message.isMySend ? (self.bounds.size.width - self.headImageView.frame.size.width - HEAD_PADDING) : HEAD_PADDING;
    self.headImageView.frame = frame;
    
//    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headImageView.frame)+5, CGRectGetMinY(self.headImageView.frame), (self.bounds.size.width - (CGRectGetMaxX(self.headImageView.frame)+5)*2), NAME_LABEL_HEIGHT);
    //固定宽度
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headImageView.frame)+5, CGRectGetMinY(self.headImageView.frame), NAME_LABEL_WIDTH, NAME_LABEL_HEIGHT);
    
    CGRect bubbleFrame = self.bubbleContainerView.frame;
    if ([self shouldShowName]) {
        bubbleFrame.origin.y = CGRectGetMaxY(self.nameLabel.frame);
    }
    else
    {
        bubbleFrame.origin.y = CGRectGetMinY(self.headImageView.frame);
    }
    if (self.message.isMySend) {
        // 菊花状态 （因不确定菊花具体位置，要在子类中实现位置的修改）
        switch (self.message.deliveryStatus) {
            case eMessageStatus_Sending:
            {
                [self.activityView setHidden:NO];
                [self.retryButton setHidden:YES];
                [self.activtiy setHidden:NO];
                [self.activtiy startAnimating];
            }
                break;
            case eMessageStatus_Send_Succ:
            {
                [self.activtiy stopAnimating];
                [self.activityView setHidden:YES];
                [self.activtiy setHidden:YES];
                [self.retryButton setHidden:YES];
            }
                break;
            case eMessageStatus_Send_Fail:
            {
                [self.activityView setHidden:NO];
                [self.activtiy stopAnimating];
                [self.activtiy setHidden:YES];
                [self.retryButton setHidden:NO];
            }
                break;
            default:
                break;
        }
        
        bubbleFrame.origin.x = self.headImageView.frame.origin.x - bubbleFrame.size.width - HEAD_PADDING;
        self.bubbleContainerView.frame = bubbleFrame;
        
        CGRect frame = self.activityView.frame;
        frame.origin.x = bubbleFrame.origin.x - frame.size.width - ACTIVTIYVIEW_BUBBLE_PADDING;
        frame.origin.y = self.bubbleContainerView.center.y - frame.size.height / 2;
        self.activityView.frame = frame;
    }
    else{
        bubbleFrame.origin.x = HEAD_PADDING * 2 + HEAD_SIZE;
        self.bubbleContainerView.frame = bubbleFrame;
        [self.activtiy stopAnimating];
        [self.activityView setHidden:YES];
        [self.activtiy setHidden:YES];
        [self.retryButton setHidden:YES];
    }
    self.backImageView.frame = self.bubbleContainerView.bounds;
}

#pragma mark public
- (void)headViewPressed:(id)sender
{
    [self bjim_routerEventWithName:kBJRouterEventChatCellHeadTapEventName userInfo:@{kBJRouterEventUserInfoObject:self.message}];
}

- (void)bubbleViewPressed:(id)sender
{
    [self bjim_routerEventWithName:kBJRouterEventChatCellBubbleTapEventName userInfo:@{kBJRouterEventUserInfoObject:self.message}];
}

- (void)bubbleViewLongPressed:(id)sender
{
    //[self bjim_routerEventWithName:kBJRouterEventChatCellBubbleLongTapEventName userInfo:@{kBJRouterEventUserInfoObject:self.message}];
}

- (UIImage *)bubbleImage
{
    NSString *imageName = !self.message.isMySend ? BUBBLE_LEFT_IMAGE_NAME_NEW : BUBBLE_RIGHT_IMAGE_NAME_NEW;
    NSInteger leftCapWidth = !self.message.isMySend?BUBBLE_LEFT_LEFT_CAP_WIDTH:BUBBLE_RIGHT_LEFT_CAP_WIDTH;
    NSInteger topCapHeight =  !self.message.isMySend?BUBBLE_LEFT_TOP_CAP_HEIGHT:BUBBLE_RIGHT_TOP_CAP_HEIGHT;
    return [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
}

#pragma mark - action
- (void)retryButtonPressed
{
    [super bjim_routerEventWithName:kBJResendButtonTapEventName userInfo:@{kBJRouterEventUserInfoObject:self.message}];
}

#pragma mark - Protocol
/**
 *  实现初始化方法，外部只调用此方法
 *
 *  @return
 */
- (instancetype)init;
{
    NSAssert(0, @"请子类实现此方法");
    return nil;
}
-(void)setCellInfo:(id)info indexPath:(NSIndexPath *)indexPath;
{
    self.message = info;
    self.indexPath = indexPath;
    UIImage *placeholderImage = [UIImage imageNamed:@"img_head_default"];
    [self.headImageView setAliyunImageWithURL:self.message.headImageURL placeholderImage:placeholderImage size:CGSizeMake(HEAD_SIZE, HEAD_SIZE)];
    if ([self shouldShowName]) {
        self.nameLabel.attributedText = self.message.nickNameAttri;
        self.nameLabel.hidden = NO;
    }
    else
    {
        self.nameLabel.attributedText = nil;
        self.nameLabel.hidden = YES;
    }
}

+ (CGFloat)cellHeightWithInfo:(id)dic indexPath:(NSIndexPath *)indexPath;
{
    static NSMutableDictionary *cellDic = nil;
    if (cellDic == nil) {
        cellDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    IMMessage *message = dic;
    BJChatBaseCell *cell = [cellDic objectForKey:@(message.msg_t)];
    if (cell == nil) {
        cell = [[self alloc] init];
        [cellDic setObject:cell forKey:@(message.msg_t)];
    }
    
    [cell setCellInfo:dic indexPath:indexPath];
    CGFloat height = CGRectGetMaxY(cell.bubbleContainerView.frame);
    height -= BJ_CELLPADDING;
    if (height < cell.headImageView.frame.size.height) {
        height = cell.headImageView.frame.size.height;
    }
    return height + BJ_CELLPADDING*2;
}

#pragma mark - set get

- (UIImageView *)backImageView
{
    if (_backImageView == nil) {
        _backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backImageView.userInteractionEnabled = YES;
        _backImageView.multipleTouchEnabled = YES;
        [self.bubbleContainerView addSubview:_backImageView];
        [self.bubbleContainerView sendSubviewToBack:_backImageView];
    }
    return _backImageView;
}

- (UIImageView *)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(HEAD_PADDING, BJ_CELLPADDING, HEAD_SIZE, HEAD_SIZE)];
        [_headImageView.layer setCornerRadius:HEAD_SIZE/2];
        _headImageView.clipsToBounds = YES;
        _headImageView.userInteractionEnabled = YES;
        _headImageView.multipleTouchEnabled = YES;
        _headImageView.backgroundColor = [UIColor grayColor];
        _headImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_headImageView];
    }
    return _headImageView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UIView *)bubbleContainerView
{
    if (_bubbleContainerView == nil) {
        _bubbleContainerView = [[UIView alloc] init];
        [self.contentView addSubview:_bubbleContainerView];
    }
    return _bubbleContainerView;
}

- (UIActivityIndicatorView *)activtiy
{
    if (_activity == nil) {
        // 菊花
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.backgroundColor = [UIColor clearColor];
        [self.activityView addSubview:_activity];
    }
    return _activity;
}

- (UIView *)activityView
{
    if (_activityView == nil) {
        // 发送进度显示view
        _activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE)];
        [_activityView setHidden:YES];
        [self.contentView addSubview:_activityView];
    }
    return _activityView;
}

- (UIButton *)retryButton
{
    if (_retryButton == nil) {
        // 重发按钮
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryButton.frame = CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE);
        [_retryButton addTarget:self action:@selector(retryButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_retryButton setImage:[UIImage imageNamed:@"ic_warn_nor"]  forState:UIControlStateNormal];
        [self.activityView addSubview:_retryButton];
    }
    return _retryButton;
}

@end

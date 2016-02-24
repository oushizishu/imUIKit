//
//  BJCardChatCell.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/27.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJCardChatCell.h"
#import "BJChatCellFactory.h"
#import <BJIMConstants.h>
#import <PureLayout/PureLayout.h>
#import <BJHL-Kit-iOS.h>
#import <BJHL-Foundation-iOS/BJHL-Foundation-iOS.h>
#import "UIResponder+BJIMChatRouter.h"

const float ImageWH = 60;
const float Interval = 10;
//const float CardWidth = 217;
const float CardHeight = 130;
const float IntervalTitleWithImage = 10;
const float IntervalLeftAndRight = 10;
const float IntervalTop = 15;
const float IntervalBottom = 12;
const float IntervalImageWithContent = 7;

@interface BJCardChatCell ()
@property (strong, nonatomic) UIImageView *cardImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@end

@implementation BJCardChatCell

+ (void)load
{
    [ChatCellFactoryInstance registerClass:[self class] forMessageType:eMessageType_CARD];
}

-(void)layoutSubviews
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    BOOL hasCardImage = NO;
    if (self.message.cardThumb.length>0) {
        hasCardImage = YES;
    }
    
    CGFloat CardWidth = self.bubbleContainerView.frame.size.width - IntervalLeftAndRight*2 - BJ_BUBBLE_ARROW_WIDTH;
   
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(CardWidth, self.titleLabel.font.pointSize+1)];
    
    float contentMaxHeight = CardHeight- IntervalTop - IntervalBottom - (self.titleLabel.font.pointSize+1) - IntervalTitleWithImage;
    float contentMaxWidth = CardWidth - IntervalImageWithContent - ImageWH;
    if (hasCardImage) {
        [self.cardImageView setHidden:NO];
    }else
    {
        [self.cardImageView setHidden:YES];
        contentMaxWidth = CardWidth;
    }
    CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(contentMaxWidth, contentMaxHeight)];
    CGRect rect = self.bubbleContainerView.frame;
    rect.size.height = titleSize.height + contentSize.height + IntervalTitleWithImage + IntervalBottom + IntervalTop;
    if (rect.size.height<titleSize.height+ IntervalTitleWithImage + ImageWH + IntervalBottom + IntervalTop && hasCardImage) {
        rect.size.height = titleSize.height+ IntervalTitleWithImage + ImageWH + IntervalBottom + IntervalTop;
    }
    rect.size.height += 2;
    self.bubbleContainerView.frame = rect;
    
    [super layoutSubviews];
    
    CGRect frame = self.titleLabel.frame;
    frame.size = titleSize;
    frame.origin.y = IntervalTop;
    
    self.titleLabel.frame = frame;
    
    frame = self.contentLabel.frame;
    frame.size = contentSize;
    frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + IntervalTitleWithImage;
    self.contentLabel.frame = frame;
    
    CGFloat arrowWidth = 0;
    if (!self.message.isMySend) {
        arrowWidth = BJ_BUBBLE_ARROW_WIDTH;
    }
    
    frame = self.cardImageView.frame;
    frame.origin.y = self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+IntervalTitleWithImage;
    frame.origin.x = IntervalLeftAndRight + arrowWidth;
    self.cardImageView.frame = frame;
    
    frame = self.titleLabel.frame;
    frame.origin.x = IntervalLeftAndRight + arrowWidth;
    self.titleLabel.frame = frame;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    frame = self.contentLabel.frame;
    if (self.cardImageView.hidden) {
        frame.origin.x = arrowWidth + IntervalLeftAndRight;
    }
    else
    {
        frame.origin.x = arrowWidth + IntervalLeftAndRight + ImageWH + IntervalImageWithContent;
    }
    self.contentLabel.frame = frame;

    [CATransaction commit];
}

#pragma mark - Protocol
/**
 *  实现初始化方法，外部只调用此方法
 *
 *  @return
 */
- (instancetype)init;
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BJCardChatCell class])];
    if (self) {
        CGRect rect = self.bubbleContainerView.frame;
        CGFloat width = [UIScreen mainScreen].bounds.size.width - (HEAD_PADDING*2+HEAD_SIZE*2+35);
        rect.size.width = width;
        rect.size.height = CardHeight;
        self.bubbleContainerView.frame = rect;
    }
    return self;
}

- (UIImage *)bubbleImage
{
    NSString *imageName = !self.message.isMySend ? @"bg_card_left_n" : @"bg_card_right_n";
    NSInteger leftCapWidth = !self.message.isMySend?15:5;
    NSInteger topCapHeight =  !self.message.isMySend?35:35;
    return [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
}

-(void)setCellInfo:(id)info indexPath:(NSIndexPath *)indexPath;
{
    [super setCellInfo:info indexPath:indexPath];

    self.cardImageView.image = nil;
    self.titleLabel.text = self.message.cardTitle;
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 1;
    NSMutableAttributedString *mutAtt = [[NSMutableAttributedString alloc] initWithString:self.message.cardContent?:@"" attributes:@{NSFontAttributeName:self.contentLabel.font,NSParagraphStyleAttributeName:paragraph}];
    self.contentLabel.attributedText = mutAtt;
    [self.cardImageView bjck_setAliyunImageWithURL:[NSURL URLWithString:self.message.cardThumb] placeholderImage:nil size:self.cardImageView.frame.size];
    
    self.backImageView.image = [self bubbleImage];

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)bubbleViewPressed:(id)sender
{
    [super bjim_routerEventWithName:kBJRouterEventCardEventName userInfo:@{kBJRouterEventUserInfoObject:self.message}]; 
}

#pragma mark - set get

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(Interval, Interval, 100, 40)];
        [_titleLabel setFont:[UIFont systemFontOfSize:16]];
        _titleLabel.textColor = [UIColor bjck_colorWithHexString:@"#3C3D3D"];
        _titleLabel.numberOfLines = 2;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.bubbleContainerView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(Interval+ImageWH+5, 55, 100, CardHeight-55)];
        _contentLabel.backgroundColor = [UIColor clearColor];;
        [_contentLabel setFont:[UIFont systemFontOfSize:12]];
        _contentLabel.numberOfLines = 4;
        [_contentLabel setTextColor:[UIColor bjck_colorWithHexString:@"#9D9E9E"]];
        [self.bubbleContainerView addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UIImageView *)cardImageView
{
    if (_cardImageView == nil) {
        _cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Interval, Interval, ImageWH, ImageWH)];
        _cardImageView.clipsToBounds = YES;
        [self.bubbleContainerView addSubview:_cardImageView];
    }
    return _cardImageView;
}

@end

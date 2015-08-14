//
//  BJTipTextTableViewCell.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/29.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJGossipTableViewCell.h"
#import "BJChatCellFactory.h"
#import "BJChatBaseCell.h"
#import <BJHL-Common-iOS-SDK/UIColor+Util.h>

const float Gossip_Content_Label_Max_Width = 200;
const float Gossip_Content_Label_Height = 18;

@interface BJGossipTableViewCell ()
@property (strong ,nonatomic) UIView *gossipView;
@property (strong, nonatomic) UILabel *contentLabel;
@end

@implementation BJGossipTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (void)load
{
    [[BJChatCellFactory sharedInstance] registerClass:[self class] forMessageType:eMessageType_CMD];
    [[BJChatCellFactory sharedInstance] registerClass:[self class] forMessageType:eMessageType_NOTIFICATION];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - Protocol
/**
 *  实现初始化方法，外部只调用此方法
 *
 *  @return
 */
- (instancetype)init;
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BJGossipTableViewCell class])];
    if (self) {
    }
    return self;
}
-(void)setCellInfo:(id)info indexPath:(NSIndexPath *)indexPath;
{
    self.message = info;
    self.indexPath = indexPath;
    NSString *showMsg = self.message.gossipText;
    UIFont *font = [UIFont systemFontOfSize:BJ_GOSSIP_FONTSIZE];
    
    NSInteger lineCount = [BJGossipTableViewCell getMsgLineCount:showMsg withFont:font withMaxWid:BJ_GOSSIP_TEXTMAXWIDTH];
    
    CGFloat screenW = [[UIScreen mainScreen] bounds].size.width;
    self.contentView.frame = CGRectMake(0, 0, screenW, self.frame.size.height);
    
    CGFloat textW = 0.0f;
    
    if (lineCount >1) {
        textW = BJ_GOSSIP_TEXTMAXWIDTH;
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.textAlignment = NSTextAlignmentLeft;
    }else
    {
        self.contentLabel.numberOfLines = 1;
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        if (lineCount == 0) {
            showMsg = @"空消息!";
            lineCount = 1;
        }
        CGSize size = [showMsg sizeWithFont:font];
        textW = size.width;
    }
    
    self.contentLabel.text = showMsg;
    
    self.gossipView.frame = CGRectMake((self.contentView.frame.size.width-(textW+BJ_GOSSIP_MARGIN*2))/2, BJ_GOSSIP_LINESPAC, textW+BJ_GOSSIP_MARGIN*2, BJ_GOSSIP_FONTSIZE*lineCount+BJ_GOSSIP_MARGIN*2+BJ_GOSSIP_LINESPAC*(lineCount-1));
    
    self.contentLabel.frame = CGRectMake(BJ_GOSSIP_MARGIN, BJ_GOSSIP_MARGIN, textW , BJ_GOSSIP_FONTSIZE*lineCount+BJ_GOSSIP_LINESPAC*(lineCount-1));
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

+ (CGFloat)cellHeightWithInfo:(id)dic indexPath:(NSIndexPath *)indexPath;
{
    IMMessage *message = dic;
    NSString *showMsg = message.gossipText;
    UIFont *font = [UIFont systemFontOfSize:BJ_GOSSIP_FONTSIZE];
    NSInteger count = [self getMsgLineCount:showMsg withFont:font withMaxWid:BJ_GOSSIP_TEXTMAXWIDTH];
    if (count == 0) {
        count = 1;
    }
    CGFloat height = BJ_GOSSIP_FONTSIZE*count+BJ_GOSSIP_MARGIN*2+10*2+BJ_GOSSIP_LINESPAC*(count-1);
    
    return height;
}

+(NSInteger)getMsgLineCount:(NSString*)showMsg withFont:(UIFont*)font withMaxWid:(CGFloat)width;
{
    NSInteger count = 0;
    if (showMsg != nil) {
        NSMutableString *subStr = [[NSMutableString alloc] init];
        for (int i=0; i<[showMsg length]; i++) {
            CGSize size = [[NSString stringWithFormat:@"%@%@",subStr,[showMsg substringWithRange:NSMakeRange(i, 1)]] sizeWithFont:font];
            if (size.width>width) {
                if ([subStr length]>0) {
                    count++;
                    subStr = [[NSMutableString alloc] init];
                    i--;
                }else
                {
                    break;
                }
            }else
            {
                [subStr appendString:[showMsg substringWithRange:NSMakeRange(i, 1)]];
            }
        }
        
        if ([subStr length]>0) {
            count++;
        }
    }
    
    return count;
}

#pragma mark - set get
- (UILabel *)contentLabel
{
    if (_contentLabel == nil) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.font = [UIFont systemFontOfSize:BJ_GOSSIP_FONTSIZE];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithHexString:BJ_GOSSIP_FONTCOLOR];
            label.clipsToBounds = YES;
            label;
        });
        if (_gossipView == nil) {
            _gossipView = [[UIView alloc] initWithFrame:CGRectZero];
            _gossipView.backgroundColor = [UIColor colorWithHexString:BJ_GOOSIP_BACKCOLOR];
            _gossipView.layer.cornerRadius = 2;
        }
        [self.gossipView addSubview:self.contentLabel];
        [self.contentView addSubview:self.gossipView];
    }
    return _contentLabel;
}

@end

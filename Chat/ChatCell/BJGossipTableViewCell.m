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
    self.contentLabel.text = showMsg;
    UIFont *font = [UIFont systemFontOfSize:BJ_GOSSIP_FONTSIZE];
    CGSize size = [showMsg sizeWithFont:font];
    
    CGFloat textW = BJ_GOSSIP_TEXTMAXWIDTH;
    
    if (textW > size.width) {
        textW = size.width;
    }
    
    CGFloat screenW = [[UIScreen mainScreen] bounds].size.width;
    self.contentView.frame = CGRectMake(0, 0, screenW, self.frame.size.height);
    
    self.contentLabel.frame = CGRectMake(BJ_GOSSIP_MARGIN, BJ_GOSSIP_MARGIN, textW , BJ_GOSSIP_FONTSIZE);
    self.gossipView.frame = CGRectMake((self.contentView.frame.size.width-(textW+BJ_GOSSIP_MARGIN*2))/2, (self.contentView.frame.size.height-(BJ_GOSSIP_FONTSIZE+BJ_GOSSIP_MARGIN*2))/2, textW+BJ_GOSSIP_MARGIN*2, BJ_GOSSIP_FONTSIZE+BJ_GOSSIP_MARGIN*2);
    
    NSLog(@"contentLabel frame x=%f,y=%f,w=%f,h=%f",self.contentLabel.frame.origin.x,self.contentLabel.frame.origin.y,self.contentLabel.frame.size.width,self.contentLabel.frame.size.height);
    
    NSLog(@"gossipView frame x=%f,y=%f,w=%f,h=%f",self.gossipView.frame.origin.x,self.gossipView.frame.origin.y,self.gossipView.frame.size.width,self.gossipView.frame.size.height);
    
    NSLog(@"contentView frame x=%f,y=%f,w=%f,h=%f",self.contentView.frame.origin.x,self.contentView.frame.origin.y,self.contentView.frame.size.width,self.contentView.frame.size.height);
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

+ (CGFloat)cellHeightWithInfo:(id)dic indexPath:(NSIndexPath *)indexPath;
{
    return 44;
    //return BJ_GOSSIP_FONTSIZE+BJ_GOSSIP_MARGIN*2;
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

//
//  BJChatTimeCell.h
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/23.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#define BJChatTime_TOP_PADDING 19.5
#define BJChatTime_Bottom_PADDING 1.5

#import "BJChatTimeCell.h"
#import <BJHL-Common-iOS-SDK/UIColor+Util.h>

@interface BJChatTimeCell ()
@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation BJChatTimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.timeLabel.frame = CGRectMake(10, BJChatTime_TOP_PADDING, self.frame.size.width - 20, self.frame.size.height - BJChatTime_Bottom_PADDING - BJChatTime_TOP_PADDING);
    [self.timeLabel sizeToFit];
    CGRect rect = self.timeLabel.frame;
    rect.size.width = rect.size.width + 18 * 2;
    rect.size.height = rect.size.height + 5*2;
    rect.origin.x = (self.frame.size.width - rect.size.width) / 2.0f;
    self.timeLabel.frame = rect;
}

- (void)updateTime:(NSString *)time;
{
    self.timeLabel.text = time;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - set get
- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
        _timeLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, BJChatTime_TOP_PADDING, self.frame.size.width - 20, self.frame.size.height - BJChatTime_Bottom_PADDING - BJChatTime_TOP_PADDING)];
            label.font = [UIFont systemFontOfSize:10];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor colorWithHexString:@"#dcddde"];
            label.textColor = [UIColor whiteColor];
            label;
        });
        _timeLabel.layer.cornerRadius = 5;
        _timeLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

@end

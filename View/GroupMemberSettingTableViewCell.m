//
//  GroupMemberSettingTableViewCell.m
//  BJEducation
//
//  Created by Mac_ZL on 17/2/14.
//  Copyright © 2017年 com.bjhl. All rights reserved.
//

#import "GroupMemberSettingTableViewCell.h"

@implementation GroupMemberSettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.detailTextLabel.current_x_w = self.accessoryView.current_x-10;
    
    
}
@end

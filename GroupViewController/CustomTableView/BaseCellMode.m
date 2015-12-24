//
//  BaseCellMode.m
//  
//
//  Created by wangziliang on 15/10/8.
//

#import "BaseCellMode.h"

@implementation BaseModeCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setMyCellMode:(BaseCellMode*)cellMode
{
    if (self.cellMode != cellMode) {
        if (self.cellMode.modeCell != nil) {
            [self.cellMode setMyModeCell:nil];
        }
        self.cellMode = cellMode;
        if (self.cellMode != nil) {
            self.cellMode.modeCell = self;
        }
    }
}

@end

@implementation BaseCellMode

-(NSString*)getCellIdentifier
{
    return @"Cell";
}

-(CGFloat)getCellHeight
{
    return 44.0f;
}

-(BaseModeCell*)createModeCell
{
    BaseModeCell *cell = [[BaseModeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getCellIdentifier]];
    return cell;
}

-(void)setMyModeCell:(BaseModeCell*)cell
{
    self.modeCell = cell;
}

@end

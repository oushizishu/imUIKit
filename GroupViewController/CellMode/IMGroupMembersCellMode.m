//
//  IMGroupMembersCellMode.m
//
//  Created by wangziliang 15/12/3.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "IMGroupMembersCellMode.h"
#import <BJHL-IM-iOS-SDK/GroupDetail.h>

@interface IMGroupMembersCell()

@property(strong ,nonatomic)NSMutableArray *imageViewArray;

@end

@implementation IMGroupMembersCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //设置cell没有选中效果
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setMyCellMode:(BaseCellMode*)cellMode
{
    [super setMyCellMode:cellMode];
    
    for (int i = 0; i < [self.imageViewArray count]; i++) {
        UIImageView *itemView = [self.imageViewArray objectAtIndex:i];
        [itemView removeFromSuperview];
    }
    [self.imageViewArray removeAllObjects];
    
    IMGroupMembersCellMode *mode = (IMGroupMembersCellMode*)self.cellMode;
    
    NSInteger memberCount = [self calculationMemberCount];
    
    CGRect sRect = [UIScreen mainScreen].bounds;
    CGFloat maxW = sRect.size.width-30;

    CGFloat interval = 0;
    if (memberCount > 1) {
        interval = (maxW - memberCount*50)/(memberCount-1);
    }
    
    if (mode.memberArray != nil) {
        NSInteger count = [mode.memberArray count];
        if (count > memberCount) {
            count = memberCount;
        }
        for (int i = 0; i < count; i++) {
            UIImageView *itemView = [[UIImageView alloc] initWithFrame:CGRectMake(15+i*(interval+50), 5, 50, 50)];
            itemView.clipsToBounds = YES;
            itemView.backgroundColor = [UIColor grayColor];
            GroupDetailMember *itemMode = [mode.memberArray objectAtIndex:i];
            [itemView setAliyunImageWithURL:[NSURL URLWithString:itemMode.avatar] placeholderImage:nil];
            [self addSubview:itemView];
            [self.imageViewArray addObject:itemView];
        }
    }

}

-(NSInteger)calculationMemberCount
{
     NSInteger memberCount = 0;
    
    if (memberCount == 0) {
        memberCount = 1;
        CGRect sRect = [UIScreen mainScreen].bounds;
        CGFloat maxW = sRect.size.width-30;
        
        while (1) {
            if (memberCount*50+(memberCount-1)*15 > maxW) {
                break;
            }
            memberCount++;
        }

    }

    return memberCount;
}

- (NSMutableArray *)imageViewArray
{
    if(_imageViewArray == nil)
    {
        _imageViewArray = [[NSMutableArray alloc] init];
    }
    return _imageViewArray;
}


@end

@implementation IMGroupMembersCellMode

-(instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(NSString*)getCellIdentifier
{
    return [NSString stringWithFormat:@"IMGroupMembersCellMode"];
}

-(CGFloat)getCellHeight
{
    return 60.0f;
}

-(BaseModeCell*)createModeCell
{
    IMGroupMembersCell *cell = [[IMGroupMembersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getCellIdentifier]];
    return cell;
}

@end

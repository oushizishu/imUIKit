//
//  IMGroupTeachersCellMode.m
//
//  Created by wangziliang on 15/12/4.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "IMGroupTeachersCellMode.h"

@interface GroupTeacherView()

@property(strong ,nonatomic)UIImageView *faceImageView;
@property(strong ,nonatomic)UILabel *teacherNameL;

@end

@implementation GroupTeacherView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 40, 40)];
        self.faceImageView.backgroundColor = [UIColor grayColor];
        [self addSubview:self.faceImageView];
        self.teacherNameL = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 60, 20)];
        self.teacherNameL.font = [UIFont systemFontOfSize:14.0f];
        self.teacherNameL.textColor = [UIColor blackColor];
        self.teacherNameL.textAlignment = NSTextAlignmentCenter;
        self.teacherNameL.backgroundColor = [UIColor clearColor];
        [self addSubview:self.teacherNameL];
    }
    return self;
}

-(void)setGroupTeacher:(GroupTeacher*)teacher
{
    [self.faceImageView setAliyunImageWithURL:[NSURL URLWithString:teacher.avatar] placeholderImage:nil];
    self.teacherNameL.text = teacher.user_name;
}

@end

@interface IMGroupTeachersCell()

@property(strong ,nonatomic)UIScrollView *scrollerView;
@property(strong ,nonatomic)NSMutableArray *teacherViewArray;

@end

@implementation IMGroupTeachersCell

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
    
    for (int i = 0; i < [self.teacherViewArray count]; i++) {
        UIImageView *itemView = [self.teacherViewArray objectAtIndex:i];
        [itemView removeFromSuperview];
    }
    [self.teacherViewArray removeAllObjects];
    
    IMGroupTeachersCellMode *mode = (IMGroupTeachersCellMode*)self.cellMode;
    
    CGRect sRect = [UIScreen mainScreen].bounds;
    
    self.scrollerView.contentSize = CGSizeMake(sRect.size.width, 90);
    self.scrollerView.contentOffset = CGPointMake(0, 0);
    
    if (mode.teacherArray != nil && [mode.teacherArray count]>0) {
        CGFloat needW = 30+60*[mode.teacherArray count]+30*([mode.teacherArray count]-1);
        if (needW > sRect.size.width) {
            self.scrollerView.contentSize = CGSizeMake(needW, 90);
        }
        
        for (int i = 0; i < [mode.teacherArray count]; i++) {
            GroupTeacherView *teacherView = [[GroupTeacherView alloc] initWithFrame:CGRectMake(15+(60+30)*i, 0, 60, 90)];
            [teacherView setGroupTeacher:[mode.teacherArray objectAtIndex:i]];
            [self.scrollerView addSubview:teacherView];
            [self.teacherViewArray addObject:teacherView];
        }
    }
    
}

- (UIScrollView *)scrollerView
{
    if (_scrollerView == nil) {
        CGRect sRect = [UIScreen mainScreen].bounds;
        _scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, sRect.size.width, 90)];
        [self addSubview:_scrollerView];
    }
    return _scrollerView;
}



@end

@implementation IMGroupTeachersCellMode

-(instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(NSString*)getCellIdentifier
{
    return [NSString stringWithFormat:@"IMGroupTeachersCellMode"];
}

-(CGFloat)getCellHeight
{
    return 90.0f;
}

-(BaseModeCell*)createModeCell
{
    IMGroupTeachersCell *cell = [[IMGroupTeachersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getCellIdentifier]];
    return cell;
}

@end

//
//  IMGroupTeachersCellMode.m
//
//  Created by wangziliang on 15/12/4.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "IMGroupTeachersCellMode.h"
#import <BJHL-Common-iOS-SDK/UIImageView+Aliyun.h>
#import "IMLinshiTool.h"
#import <BJHL-Common-iOS-SDK/UIColor+Util.h>
#import <BJHL-Common-iOS-SDK/BJCommonDefines.h>

#define IMGROUPTEACHERSCELLMODEHEIGHT 110.0f

/*
80*80
36*36
19*19
 */





@interface GroupTeacherView()

@property(strong ,nonatomic)UIImageView *faceImageView;
@property(strong ,nonatomic)UILabel *teacherNameL;
@property(strong ,nonatomic)UILabel *teacherPositionL;

@end

@implementation GroupTeacherView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-36)/2, 0, 36, 36)];
        [self.faceImageView setClipsToBounds:YES];
        [self.faceImageView.layer setCornerRadius:2.0f];
        [self.faceImageView.layer setBorderWidth:0.5f];
        [self.faceImageView.layer setBorderColor:[UIColor colorWithHexString:IMCOLOT_GREY100].CGColor];
        self.faceImageView.backgroundColor = [UIColor grayColor];
        [self addSubview:self.faceImageView];
        
        self.teacherNameL = [[UILabel alloc] initWithFrame:CGRectMake(0, 42, frame.size.width, 16)];
        self.teacherNameL.font = [UIFont systemFontOfSize:15.0f];
        self.teacherNameL.textColor = [UIColor colorWithHexString:IMCOLOT_GREY600];
        self.teacherNameL.textAlignment = NSTextAlignmentCenter;
        self.teacherNameL.backgroundColor = [UIColor clearColor];
        [self addSubview:self.teacherNameL];
        
        self.teacherPositionL = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, frame.size.width, 15)];
        self.teacherPositionL.font = [UIFont systemFontOfSize:14.0f];
        self.teacherPositionL.textColor = [UIColor colorWithHexString:IMCOLOT_GREY500];
        self.teacherPositionL.textAlignment = NSTextAlignmentCenter;
        self.teacherPositionL.backgroundColor = [UIColor clearColor];
        self.teacherPositionL.text = @"主讲老师";
        [self addSubview:self.teacherPositionL];
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
        self.contentView.backgroundColor = [UIColor whiteColor];
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
    
    self.scrollerView.contentSize = CGSizeMake(sRect.size.width, IMGROUPTEACHERSCELLMODEHEIGHT);
    self.scrollerView.contentOffset = CGPointMake(0, 0);
    
    if (mode.teacherArray != nil && [mode.teacherArray count]>0) {
        CGFloat needW = [mode.teacherArray count]*80;
        if (needW > sRect.size.width) {
            self.scrollerView.contentSize = CGSizeMake(needW, IMGROUPTEACHERSCELLMODEHEIGHT);
        }
        
        for (int i = 0; i < [mode.teacherArray count]; i++) {
            GroupTeacherView *teacherView = [[GroupTeacherView alloc] initWithFrame:CGRectMake(80*i, 15, 80, 80)];
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
        _scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, sRect.size.width, IMGROUPTEACHERSCELLMODEHEIGHT)];
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
    return IMGROUPTEACHERSCELLMODEHEIGHT;
}

-(BaseModeCell*)createModeCell
{
    IMGroupTeachersCell *cell = [[IMGroupTeachersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getCellIdentifier]];
    return cell;
}

@end

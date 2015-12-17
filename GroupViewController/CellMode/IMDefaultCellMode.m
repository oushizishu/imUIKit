//
//  IMDefaultCellMode.m
//
//  Created by wangziliang on 15/10/8.
//

#import "IMDefaultCellMode.h"
#import <BJHL-Common-iOS-SDK/UIImageView+Aliyun.h>
#import "IMLinshiTool.h"

#define IMDEFAULTCELLMODEHEIGHT 44

@interface IMDefaultCell()

@property(strong ,nonatomic)UIImageView *flagImageView;
@property(strong ,nonatomic)UILabel *titleLable;
@property(strong ,nonatomic)UILabel *valueLable;
@property(strong ,nonatomic)UIImageView *arrowImageView;
@property(strong ,nonatomic)UIView *lineView;

@end

@implementation IMDefaultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //设置cell没有选中效果
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        CGRect sRect = [UIScreen mainScreen].bounds;
        
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(15, IMDEFAULTCELLMODEHEIGHT, sRect.size.width-15, 0.5)];
        self.lineView.backgroundColor = [UIColor colorWithHexString:@"#dcddde"];
        [self addSubview:self.lineView];
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
    
    IMDefaultCellMode *mode = (IMDefaultCellMode*)self.cellMode;
    CGRect sRect = [UIScreen mainScreen].bounds;
    
    CGFloat maxW = sRect.size.width - (15*2+20+10);
    
    CGPoint startPoint = CGPointMake(15, 0);
    
    if (mode.flagImage != nil) {
        self.flagImageView.hidden = NO;
        self.flagImageView.frame = CGRectMake(startPoint.x, (IMDEFAULTCELLMODEHEIGHT-40)/2, 40, 40);
        self.flagImageView.image = mode.flagImage;
        startPoint.x += 40+10;
        maxW = maxW - (40+10);
    }else if(mode.imageUrl != nil)
    {
        self.flagImageView.hidden = NO;
        self.flagImageView.frame = CGRectMake(startPoint.x, (IMDEFAULTCELLMODEHEIGHT-40)/2, 40, 40);
        [self.flagImageView setAliyunImageWithURL:mode.imageUrl placeholderImage:nil size:CGSizeMake(40, 40)];
        startPoint.x += 40+10;
        maxW = maxW - (40+10);
    }else
    {
        self.flagImageView.hidden = YES;
    }
    
    if (mode.title != nil && mode.title.length > 0) {
        self.titleLable.hidden = NO;
        CGSize titleSize = [mode.title sizeWithFont:[UIFont systemFontOfSize:16.0f]];
        if (titleSize.width > maxW) {
            titleSize.width = maxW;
        }
        self.titleLable.frame = CGRectMake(startPoint.x, (IMDEFAULTCELLMODEHEIGHT-20)/2, titleSize.width, 20);
        self.titleLable.text = mode.title;
        startPoint.x += titleSize.width+10;
        maxW = maxW - (titleSize.width+10);
    }else
    {
        self.titleLable.hidden = YES;
    }
    
    if (maxW > 0) {
        if (mode.value != nil && mode.value.length > 0) {
            self.valueLable.hidden = NO;
            self.valueLable.frame = CGRectMake(startPoint.x, (IMDEFAULTCELLMODEHEIGHT-20)/2, maxW, 20);
            self.valueLable.text = mode.value;
        }else
        {
            self.valueLable.hidden = YES;
        }
    }else
    {
        self.valueLable.hidden = YES;
    }
    
    
    if(mode.arrowType == CellArrowType_ToRigth)
    {
        self.arrowImageView.hidden = NO;
        self.arrowImageView.frame = CGRectMake(sRect.size.width-(15+10), (IMDEFAULTCELLMODEHEIGHT-20)/2, 10, 20);
        self.arrowImageView.image = [UIImage imageNamed:@"im_weakblack_rightarrow"];
    }else if(mode.arrowType == CellArrowType_ToUp)
    {
        self.arrowImageView.hidden = NO;
        self.arrowImageView.frame = CGRectMake(sRect.size.width-(15+20), (IMDEFAULTCELLMODEHEIGHT-10)/2, 20, 10);
        self.arrowImageView.image = [UIImage imageNamed:@"im_black_uparrow"];
    }else if(mode.arrowType == CellArrowType_ToBottom)
    {
        self.arrowImageView.hidden = NO;
        self.arrowImageView.frame = CGRectMake(sRect.size.width-(15+20), (IMDEFAULTCELLMODEHEIGHT-10)/2, 20, 10);
        self.arrowImageView.image = [UIImage imageNamed:@"im_black_bottomarrow"];
    }else
    {
        self.arrowImageView.hidden = YES;
    }
    
    if(mode.ifShowLine)
    {
        self.lineView.hidden = NO;
    }else
    {
        self.lineView.hidden = YES;
    }
}

- (void)setCellValue:(NSString*)value
{
    if (value != nil && value.length > 0) {
        self.valueLable.hidden = NO;
        self.valueLable.text = value;
    }else
    {
        self.valueLable.hidden = YES;
    }
}

- (void)setCellArrowType:(CellArrowType)type
{
    CGRect sRect = [UIScreen mainScreen].bounds;
    if(type == CellArrowType_ToRigth)
    {
        self.arrowImageView.hidden = NO;
        self.arrowImageView.frame = CGRectMake(sRect.size.width-(15+10), 20, 10, 20);
        self.arrowImageView.image = [UIImage imageNamed:@"im_weakblack_rightarrow"];
    }else if(type == CellArrowType_ToUp)
    {
        self.arrowImageView.hidden = NO;
        self.arrowImageView.frame = CGRectMake(sRect.size.width-(15+20), 25, 20, 10);
        self.arrowImageView.image = [UIImage imageNamed:@"im_black_uparrow"];
    }else if(type == CellArrowType_ToBottom)
    {
        self.arrowImageView.hidden = NO;
        self.arrowImageView.frame = CGRectMake(sRect.size.width-(15+20), 25, 20, 10);
        self.arrowImageView.image = [UIImage imageNamed:@"im_black_bottomarrow"];
    }else
    {
        self.arrowImageView.hidden = YES;
    }
}

- (UIImageView *)flagImageView
{
    if (_flagImageView == nil) {
        self.flagImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.flagImageView.clipsToBounds = YES;
        [self addSubview:self.flagImageView];
    }
    
    return _flagImageView;
}

- (UILabel *)titleLable
{
    if (_titleLable == nil) {
        _titleLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLable.textAlignment = NSTextAlignmentLeft;
        _titleLable.font = [UIFont systemFontOfSize:IMFONTHEIGHT_BIG];
        _titleLable.textColor = [UIColor blackColor];
        [self addSubview:self.titleLable];
    }
    return _titleLable;
}

- (UILabel *)valueLable
{
    if (_valueLable == nil) {
        _valueLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLable.textAlignment = NSTextAlignmentRight;
        _valueLable.font = [UIFont systemFontOfSize:IMFONTHEIGHT_NORMAL];
        _valueLable.textColor = [UIColor grayColor];
        [self addSubview:_valueLable];
    }
    return _valueLable;
}

- (UIImageView *)arrowImageView
{
    if (_arrowImageView == nil) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

@end

@implementation IMDefaultCellMode

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.arrowType = CellArrowType_None;
        self.ifShowLine = NO;
    }
    return self;
}

-(NSString*)getCellIdentifier
{
    return [NSString stringWithFormat:@"IMDefaultCellMode"];
}

-(CGFloat)getCellHeight
{
    return IMDEFAULTCELLMODEHEIGHT;
}

-(BaseModeCell*)createModeCell
{
    IMDefaultCell *cell = [[IMDefaultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getCellIdentifier]];
    return cell;
}

-(void)setDefaultValue:(NSString *)value
{
    self.value = value;
    IMDefaultCell *cell = (IMDefaultCell*)self.modeCell;
    if (cell != nil) {
        [cell setCellValue:self.value];
    }
}

-(void)setDefaultArrowType:(CellArrowType)type
{
    self.arrowType = type;
    IMDefaultCell *cell = (IMDefaultCell*)self.modeCell;
    if (cell != nil) {
        [cell setCellArrowType:type];
    }
}

@end

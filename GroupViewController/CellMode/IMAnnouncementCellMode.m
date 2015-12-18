//
//  IMAnnouncementCellMode.m
//
//  Created by wangziliang on 15/12/2.
//

#import "IMAnnouncementCellMode.h"
#import <BJHL-IM-iOS-SDK/BJIMManager.h>
#import "IMLinshiTool.h"

@implementation IMUILable


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    if(touch.view == self)
    {
        CGPoint point = [touch locationInView:self];
        if(point.x>=-10&&point.y>=-10&&point.x<=self.frame.size.width+10&&point.y<=self.frame.size.height+10)
        {
            if (self.delegate != nil) {
                [self.delegate userHitLable:self];
            }
        }
    }
}

-(void)touchesEstimatedPropertiesUpdated:(NSSet *)touches
{
    [super touchesEstimatedPropertiesUpdated:touches];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

@end

@interface IMAnnouncementCell()<IMUILableDelegate>

@property(strong ,nonatomic)NSMutableArray<UILabel *> *contentArray;
@property(strong ,nonatomic)UILabel *authorNameLable;
@property(strong ,nonatomic)UILabel *releaseTimeLable;
@property(strong ,nonatomic)IMUILable *deleteL;

@end

@implementation IMAnnouncementCell

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

- (void)setMyCellMode:(BaseCellMode*)cellMode
{
    [super setMyCellMode:cellMode];
    
    IMAnnouncementCellMode *mode = (IMAnnouncementCellMode*)self.cellMode;
    
    CGRect sRect = [UIScreen mainScreen].bounds;
    
    for (int i = 0; i < [self.contentArray count]; i++) {
        UILabel *itemL = [self.contentArray objectAtIndex:i];
        [itemL removeFromSuperview];
    }
    [self.contentArray removeAllObjects];
    
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    UIColor *fontColor = [UIColor colorWithHexString:IMCOLOT_GREY600];
    for (int i = 0; i < [mode.contentArray count]; i++) {
        UILabel *itemL = [[UILabel alloc] initWithFrame:CGRectMake(15, 15+20*i, sRect.size.width-30, 15)];
        itemL.font = font;
        itemL.tintColor = fontColor;
        itemL.text = [mode.contentArray objectAtIndex:i];
        [self addSubview:itemL];
        [self.contentArray addObject:itemL];
    }
    
    CGPoint startP = CGPointMake(sRect.size.width-15, [mode getCellHeight]-30);
    
    if (mode.ifCanDelete) {
        self.deleteL.hidden = NO;
        CGRect deleteLFrame = self.deleteL.frame;
        self.deleteL.frame = CGRectMake(startP.x-deleteLFrame.size.width, startP.y, deleteLFrame.size.width, deleteLFrame.size.height);
        startP = CGPointMake(startP.x-deleteLFrame.size.width, startP.y);
    }else
    {
        self.deleteL.hidden = YES;
    }
    
    if(mode.groupNotice != nil && mode.groupNotice.create_date != nil && mode.groupNotice.create_date.length>0)
    {
        self.releaseTimeLable.hidden = NO;
        
        CGSize create_dateSize = [mode.groupNotice.create_date sizeWithFont:[UIFont systemFontOfSize:13.0f]];
        self.releaseTimeLable.frame = CGRectMake(startP.x-create_dateSize.width, startP.y, create_dateSize.width, 15);
        self.releaseTimeLable.text = mode.groupNotice.create_date;
        startP = CGPointMake(startP.x-create_dateSize.width-15, startP.y);
    }else
    {
        self.releaseTimeLable.hidden = YES;
    }
    
    if(mode.groupNotice != nil && mode.groupNotice.creator != nil && mode.groupNotice.creator.length>0)
    {
        self.authorNameLable.hidden = NO;
        
        CGSize creatorSize = [mode.groupNotice.creator sizeWithFont:[UIFont systemFontOfSize:13.0f]];
        self.authorNameLable.frame = CGRectMake(startP.x-creatorSize.width, startP.y, creatorSize.width, 15);
        self.authorNameLable.text = mode.groupNotice.creator;
    }else
    {
        self.authorNameLable.hidden = YES;
    }
    
}

- (NSMutableArray<UILabel *> *)contentArray
{
    if(_contentArray == nil)
    {
        _contentArray = [[NSMutableArray alloc] init];
    }
    return _contentArray;
}

- (UILabel *)authorNameLable
{
    if (_authorNameLable == nil) {
        _authorNameLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _authorNameLable.textColor = [UIColor colorWithHexString:IMCOLOT_GREY500];
        _authorNameLable.font = [UIFont systemFontOfSize:13.0f];
        _authorNameLable.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_authorNameLable];
    }
    return _authorNameLable;
}

- (UILabel *)releaseTimeLable
{
    if (_releaseTimeLable == nil) {
        _releaseTimeLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _releaseTimeLable.textColor = [UIColor colorWithHexString:IMCOLOT_GREY500];
        _releaseTimeLable.font = [UIFont systemFontOfSize:13.0f];
        _releaseTimeLable.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_releaseTimeLable];
    }
    return _releaseTimeLable;
}

- (UILabel *)deleteL
{
    if (_deleteL == nil) {
        CGSize deleteSize = [@"删除" sizeWithFont:[UIFont systemFontOfSize:13.0f]];
        _deleteL = [[IMUILable alloc] initWithFrame:CGRectMake(0, 0, deleteSize.width+30, 15)];
        _deleteL.textColor = [UIColor colorWithHexString:@"8cc8fd"];
        _deleteL.font = [UIFont systemFontOfSize:13.0f];
        _deleteL.textAlignment = NSTextAlignmentCenter;
        _deleteL.text = @"删除";
        _deleteL.delegate = self;
        _deleteL.userInteractionEnabled = YES;
        
        [self addSubview:_deleteL];
    }
    return _deleteL;
}

- (void)userHitLable:(IMUILable *)lable
{
    if (self.cellMode != nil) {
        IMAnnouncementCellMode *cellMode = (IMAnnouncementCellMode*)self.cellMode;
        [cellMode deleteAnnouncement];
    }
}

- (void)deleteLPressed:(id)sender
{
    if (self.cellMode != nil) {
        IMAnnouncementCellMode *cellMode = (IMAnnouncementCellMode*)self.cellMode;
        [cellMode deleteAnnouncement];
    }
}

@end

@interface IMAnnouncementCellMode()

@end

@implementation IMAnnouncementCellMode

-(instancetype)initWithGroupNotice:(GroupNotice*)groupNotice;
{
    self = [super init];
    if (self) {
        self.groupNotice = groupNotice;
        self.ifCanDelete = NO;
    }
    return self;
}

-(NSString*)getCellIdentifier
{
    return [NSString stringWithFormat:@"IMAnnouncementCellMode"];
}

-(CGFloat)getCellHeight
{
    NSInteger count = [self.contentArray count];
    
    return count*20+30+20;
}

-(BaseModeCell*)createModeCell
{
    IMAnnouncementCell *cell = [[IMAnnouncementCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getCellIdentifier]];
    return cell;
}

- (NSArray*)contentArray
{
    if (_contentArray == nil) {
        if (self.groupNotice != nil && self.groupNotice.content != nil&& self.groupNotice.content.length > 0) {
            CGRect sRect = [UIScreen mainScreen].bounds;
            _contentArray = [self splitMsg:self.groupNotice.content withFont:[UIFont systemFontOfSize:14.0f] withMaxWid:sRect.size.width-30];
        }
    }
    return _contentArray;
}

-(NSArray*)splitMsg:(NSString*)showMsg withFont:(UIFont*)font withMaxWid:(CGFloat)width;
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    if (showMsg != nil) {
        NSMutableString *subStr = [[NSMutableString alloc] init];
        for (int i=0; i<[showMsg length]; i++) {
            CGSize size = [[NSString stringWithFormat:@"%@%@",subStr,[showMsg substringWithRange:NSMakeRange(i, 1)]] sizeWithFont:font];
            if (size.width>width) {
                if ([subStr length]>0) {
                    [retArray addObject:subStr];
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
            [retArray addObject:subStr];
        }
    }
    
    return retArray;
}

-(void)deleteAnnouncement
{
    WS(weakSelf);
    [[BJIMManager shareInstance] removeGroupNotice:self.groupNotice.noticeId group_id:0 callback:^(NSError *error) {
        if (error) {
            
        }else
        {
            [weakSelf.sectionMode.customTableViewController removeSections:[NSArray arrayWithObjects:weakSelf.sectionMode, nil]];
        }
    }];
}

@end

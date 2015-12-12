//
//  IMAnnouncementCellMode.m
//
//  Created by wangziliang on 15/12/2.
//

#import "IMAnnouncementCellMode.h"

@interface IMAnnouncementCell()

@property(strong ,nonatomic)UILabel *contentLable;
@property(strong ,nonatomic)UILabel *authorNameLable;
@property(strong ,nonatomic)UILabel *releaseTimeLable;
@property(strong ,nonatomic)UIButton *deleteBtn;

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
    NSInteger count = 0;
    if (mode.contentArray != nil) {
        count = [mode.contentArray count];
    }
    
    if (count > 0) {
        self.contentLable.hidden = NO;
        self.contentLable.frame = CGRectMake(15, 15, sRect.size.width-30, count*20);
        self.contentLable.numberOfLines = count;
        self.contentLable.text = mode.groupNotice.content;
    }else
    {
        self.contentLable.hidden = YES;
    }
    
    CGPoint startP = CGPointMake(sRect.size.width-15, [mode getCellHeight]-35);
    
    if (mode.ifCanDelete) {
        self.deleteBtn.hidden = NO;
        CGRect deleteBtnFrame = self.deleteBtn.frame;
        self.deleteBtn.frame = CGRectMake(startP.x-deleteBtnFrame.size.width, startP.y, deleteBtnFrame.size.width, deleteBtnFrame.size.height);
        startP = CGPointMake(startP.x-deleteBtnFrame.size.width, startP.y);
    }else
    {
        self.deleteBtn.hidden = YES;
    }
    
    if(mode.groupNotice != nil && mode.groupNotice.create_date != nil && mode.groupNotice.create_date.length>0)
    {
        self.releaseTimeLable.hidden = NO;
        
        CGSize create_dateSize = [mode.groupNotice.create_date sizeWithFont:[UIFont systemFontOfSize:16.0f]];
        self.releaseTimeLable.frame = CGRectMake(startP.x-create_dateSize.width, startP.y, create_dateSize.width, 20);
        self.releaseTimeLable.text = mode.groupNotice.create_date;
        startP = CGPointMake(startP.x-create_dateSize.width-15, startP.y);
    }else
    {
        self.releaseTimeLable.hidden = YES;
    }
    
    if(mode.groupNotice != nil && mode.groupNotice.creator != nil && mode.groupNotice.creator.length>0)
    {
        self.authorNameLable.hidden = NO;
        
        CGSize creatorSize = [mode.groupNotice.creator sizeWithFont:[UIFont systemFontOfSize:16.0f]];
        self.authorNameLable.frame = CGRectMake(startP.x-creatorSize.width, startP.y, creatorSize.width, 20);
        self.authorNameLable.text = mode.groupNotice.creator;
    }else
    {
        self.authorNameLable.hidden = YES;
    }
    
}

- (UILabel *)contentLable
{
    if(_contentLable == nil)
    {
        _contentLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLable.textColor = [UIColor blackColor];
        _contentLable.font = [UIFont systemFontOfSize:16.0f];
        _contentLable.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_contentLable];
    }
    return _contentLable;
}

- (UILabel *)authorNameLable
{
    if (_authorNameLable == nil) {
        _authorNameLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _authorNameLable.textColor = [UIColor grayColor ];
        _authorNameLable.font = [UIFont systemFontOfSize:16.0f];
        _authorNameLable.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_authorNameLable];
    }
    return _authorNameLable;
}

- (UILabel *)releaseTimeLable
{
    if (_releaseTimeLable == nil) {
        _releaseTimeLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _releaseTimeLable.textColor = [UIColor grayColor ];
        _releaseTimeLable.font = [UIFont systemFontOfSize:16.0f];
        _releaseTimeLable.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_releaseTimeLable];
    }
    return _releaseTimeLable;
}

- (UIButton *)deleteBtn
{
    if (_deleteBtn == nil) {
        _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor colorWithHexString:@"#90caf9"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteBtn];
    }
    return _deleteBtn;
}

- (void)deleteAction
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
    
    return count*20+20+30;
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
            _contentArray = [self splitMsg:self.groupNotice.content withFont:[UIFont systemFontOfSize:16.0f] withMaxWid:sRect.size.width-30];
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
    [[BJIMManager shareInstance] removeGroupNotice:self.groupNotice.noticeId callback:^(NSError *error) {
        if (error) {
            
        }else
        {
            [weakSelf.sectionMode.customTableViewController removeSections:[NSArray arrayWithObjects:weakSelf.sectionMode, nil]];
        }
    }];
}

@end

//
//  IMFileCellMode.m
//
//  Created by wangziliang on 15/12/3.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "IMFileCellMode.h"
#import "IMLinshiTool.h"
#import "BJChatFileCacheManager.h"
#import <BJHL-IM-iOS-SDK/BJIMManager.h>

@implementation IMUIView

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
                [self.delegate userHitView:self];
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

@interface IMProgressView()

@property(strong ,nonatomic)UIView *progressView;

@end

@implementation IMProgressView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        self.layer.masksToBounds = YES;
    }
    return self;
}

-(void)setProgressValue:(CGFloat)value
{
    self.progressView.frame = CGRectMake(0, 0, self.frame.size.width*value, self.frame.size.height);
    [self setNeedsDisplay];
}

-(UIView*)progressView
{
    if (_progressView == nil) {
        _progressView = [[UIView alloc] initWithFrame:CGRectZero];
        _progressView.backgroundColor = [UIColor blueColor];
        [self addSubview:_progressView];
    }
    return _progressView;
}

@end

@implementation IMFileUploadInfo

@end

@interface IMFileCell()<IMUIViewDelegate>

@property(strong ,nonatomic)UIView *fileCellView;

@property(strong ,nonatomic)UIView *fileContentView;

@property(strong ,nonatomic)UIImageView *flagImageView;
@property(strong ,nonatomic)UILabel *fileNameLable;
@property(strong ,nonatomic)UILabel *descriptionLable;
@property(strong ,nonatomic)UILabel *creatDateLable;

@property(strong ,nonatomic)IMUIView *operationView;
@property(strong ,nonatomic)UILabel *operationL;

@property(strong ,nonatomic)UILabel *operationTip;
@property(strong ,nonatomic)IMProgressView *progressView;

@property(strong ,nonatomic)UIView *deleteView;
@property(strong ,nonatomic)UIButton *deleteBtn;

@end

@implementation IMFileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //设置cell没有选中效果
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UISwipeGestureRecognizer *lSwipG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [lSwipG setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self addGestureRecognizer:lSwipG];
        
        UISwipeGestureRecognizer *rSwipG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [rSwipG setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self addGestureRecognizer:rSwipG];
        
        CGRect sRect = [UIScreen mainScreen].bounds;
        
        self.fileCellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sRect.size.width+90, 90)];
        self.fileCellView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.fileCellView];
        
        self.fileContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sRect.size.width, 90)];
        self.fileContentView.backgroundColor = [UIColor clearColor];
        [self.fileCellView addSubview:self.fileContentView];
        
        self.flagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 60, 60)];
        self.flagImageView.backgroundColor = [UIColor clearColor];
        [self.fileContentView addSubview:self.flagImageView];
        
        self.fileNameLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 15, sRect.size.width-160, 20)];
        self.fileNameLable.font = [UIFont systemFontOfSize:14.0f];
        self.fileNameLable.textAlignment = NSTextAlignmentLeft;
        self.fileNameLable.textColor = [UIColor colorWithHexString:IMCOLOT_GREY600];
        [self.fileContentView addSubview:self.fileNameLable];
        
        self.descriptionLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 35, sRect.size.width-160, 20)];
        self.descriptionLable.font = [UIFont systemFontOfSize:12.0f];
        self.descriptionLable.textAlignment = NSTextAlignmentLeft;
        self.descriptionLable.textColor = [UIColor colorWithHexString:IMCOLOT_GREY500];
        [self.fileContentView addSubview:self.descriptionLable];
        
        self.creatDateLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 55, sRect.size.width-160, 20)];
        self.creatDateLable.font = [UIFont systemFontOfSize:12.0f];
        self.creatDateLable.textAlignment = NSTextAlignmentLeft;
        self.creatDateLable.textColor = [UIColor colorWithHexString:IMCOLOT_GREY400];
        [self.fileContentView addSubview:self.creatDateLable];
        
        self.operationView = [[IMUIView alloc] initWithFrame:CGRectMake(sRect.size.width-70, 30, 60, 30)];
        self.operationView.delegate = self;
        self.operationView.backgroundColor = [UIColor clearColor];
        [self.operationView.layer setCornerRadius:2.0f];
        [self.operationView.layer setBorderColor:[UIColor colorWithHexString:IMCOLOT_GREY400].CGColor];
        [self.operationView.layer setBorderWidth:0.5f];
        [self.fileContentView addSubview:self.operationView];
        
        self.operationL = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, self.operationView.frame.size.width, 15)];
        self.operationL.backgroundColor = [UIColor clearColor];
        self.operationL.textColor = [UIColor colorWithHexString:IMCOLOT_GREY600];
        self.operationL.font = [UIFont systemFontOfSize:14.0f];
        self.operationL.textAlignment = NSTextAlignmentCenter;
        [self.operationView addSubview:self.operationL];
        
        self.operationTip = [[UILabel alloc] initWithFrame:CGRectMake(sRect.size.width-70, 35, 60, 15)];
        self.operationTip.backgroundColor = [UIColor clearColor];
        self.operationTip.font = [UIFont systemFontOfSize:14.0f];
        self.operationTip.textColor = [UIColor colorWithHexString:IMCOLOT_GREY500];
        self.operationTip.textAlignment = NSTextAlignmentCenter;
        [self.fileContentView addSubview:self.operationTip];
        
        self.progressView = [[IMProgressView alloc] initWithFrame:CGRectMake(sRect.size.width-70, 58, 60, 2)];
        [self.fileContentView addSubview:self.progressView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 89, sRect.size.width-15, 0.5)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"#dcddde"];
        [self.fileContentView addSubview:lineView];
        
        self.deleteView = [[UIView alloc] initWithFrame:CGRectMake(sRect.size.width, 0, 90, 90)];
        self.deleteView.backgroundColor = [UIColor colorWithHexString:@"#f95e5e"];
        [self.fileCellView addSubview:self.deleteView];
        
        self.deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, (90-30)/2, 80, 30)];
        [self.deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        self.deleteBtn.backgroundColor = [UIColor clearColor];
        [self.deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteView addSubview:self.deleteBtn];
    }
    return self;
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    IMFileCellMode *mode = (IMFileCellMode*)self.cellMode;
    if (mode != nil && [mode ifCanEidtmenu]) {
        if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
            [UIView beginAnimations:@"move" context:nil];
            [UIView setAnimationDuration:0.2];
            CGRect frame = self.fileCellView.frame;
            self.fileCellView.frame=CGRectMake(-90,frame.origin.y, frame.size.width,frame.size.height);
            [UIView commitAnimations];
            mode.ifShowMenu = YES;
        }else if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
            [UIView beginAnimations:@"move" context:nil];
            [UIView setAnimationDuration:0.2];
            CGRect frame = self.fileCellView.frame;
            self.fileCellView.frame=CGRectMake(0,frame.origin.y, frame.size.width,frame.size.height);
            [UIView commitAnimations];
            mode.ifShowMenu = NO;
        }
    }
}

- (void)userHitView:(UIView *)view
{
    if (self.cellMode != nil) {
        IMFileCellMode *cellMode = (IMFileCellMode*)self.cellMode;
        [cellMode userCilckOperationBtn];
    }
}

- (void)operationAction
{
    if (self.cellMode != nil) {
        IMFileCellMode *cellMode = (IMFileCellMode*)self.cellMode;
        [cellMode userCilckOperationBtn];
    }
}

- (void)deleteAction
{
    if (self.cellMode != nil) {
        IMFileCellMode *cellMode = (IMFileCellMode*)self.cellMode;
        [cellMode userCilckDeleteBtn];
    }
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
    
    IMFileCellMode *mode = (IMFileCellMode*)self.cellMode;
    
    CGRect frame = self.fileCellView.frame;
    if ([mode ifCanEidtmenu] && mode.ifShowMenu) {
        self.fileCellView.frame=CGRectMake(-160,frame.origin.y, frame.size.width,frame.size.height);
    }else
    {
        self.fileCellView.frame=CGRectMake(0,frame.origin.y, frame.size.width,frame.size.height);
    }
    
    IMFileCellModeType modeType = [mode getModeType];
    
    if (modeType == IMFileCellModeType_Initialization) {
        self.fileContentView.hidden = YES;
    }else if(modeType == IMFileCellModeType_Upload)
    {
        self.fileContentView.hidden = NO;
        [self.flagImageView setImage:[self getFlagImage]];
        self.fileNameLable.text = mode.info.fileName;
        self.descriptionLable.text = mode.info.info;
        self.creatDateLable.text = mode.info.createDate;
        self.operationView.hidden = NO;
        self.operationL.text = @"上传";
        self.operationTip.hidden = YES;
        self.progressView.hidden = YES;
    }else if(modeType == IMFileCellModeType_UploadWait)
    {
        self.fileContentView.hidden = NO;
        [self.flagImageView setImage:[self getFlagImage]];
        self.fileNameLable.text = mode.info.fileName;
        self.descriptionLable.text = mode.info.info;
        self.creatDateLable.text = mode.info.createDate;
        self.operationView.hidden = YES;
        self.operationTip.hidden = NO;
        self.operationTip.text = @"等待";
        self.progressView.hidden = YES;
    }else if(modeType == IMFileCellModeType_Uploading)
    {
        self.fileContentView.hidden = NO;
        [self.flagImageView setImage:[self getFlagImage]];
        self.fileNameLable.text = mode.info.fileName;
        self.descriptionLable.text = mode.info.info;
        self.creatDateLable.text = mode.info.createDate;
        self.operationView.hidden = YES;
        self.operationTip.hidden = NO;
        self.operationTip.text = @"上传中";
        self.progressView.hidden = NO;
        [self.progressView setProgressValue:0];
    }else if(modeType == IMFileCellModeType_UploadRetry)
    {
        self.fileContentView.hidden = NO;
        [self.flagImageView setImage:[self getFlagImage]];
        self.fileNameLable.text = mode.info.fileName;
        self.descriptionLable.text = mode.info.info;
        self.creatDateLable.text = mode.info.createDate;
        self.operationView.hidden = NO;
        self.operationL.text = @"上传";
        self.operationTip.hidden = YES;
        self.progressView.hidden = YES;
    }else if(modeType == IMFileCellModeType_AddFile)
    {
        self.fileContentView.hidden = NO;
        [self.flagImageView setImage:[self getFlagImage]];
        self.fileNameLable.text = mode.info.fileName;
        self.descriptionLable.text = mode.info.info;
        self.creatDateLable.text = mode.info.createDate;
        self.operationView.hidden = YES;
        self.operationTip.hidden = NO;
        self.operationTip.text = @"添加中";
        self.progressView.hidden = YES;
    }else if(modeType == IMFileCellModeType_Download)
    {
        self.fileContentView.hidden = NO;
        [self.flagImageView setImage:[self getFlagImage]];
        self.fileNameLable.text = mode.groupFile.filename;
        self.descriptionLable.text = mode.groupFile.info;
        self.creatDateLable.text = mode.groupFile.create_time;
        self.operationView.hidden = NO;
        self.operationL.text = @"下载";
        self.operationTip.hidden = YES;
        self.progressView.hidden = YES;
    }else if(modeType == IMFileCellModeType_DownloadWait)
    {
        self.fileContentView.hidden = NO;
        [self.flagImageView setImage:[self getFlagImage]];
        self.fileNameLable.text = mode.groupFile.filename;
        self.descriptionLable.text = mode.groupFile.info;
        self.creatDateLable.text = mode.groupFile.create_time;
        self.operationView.hidden = YES;
        self.operationTip.hidden = NO;
        self.operationTip.text = @"等待";
        self.progressView.hidden = YES;
    }else if(modeType == IMFileCellModeType_Downloading)
    {
        self.fileContentView.hidden = NO;
        [self.flagImageView setImage:[self getFlagImage]];
        self.fileNameLable.text = mode.groupFile.filename;
        self.descriptionLable.text = mode.groupFile.info;
        self.creatDateLable.text = mode.groupFile.create_time;
        self.operationView.hidden = YES;
        self.operationTip.hidden = NO;
        self.operationTip.text = @"下载中";
        self.progressView.hidden = NO;
        [self.progressView setProgressValue:0];
    }else if(modeType == IMFileCellModeType_DownloadRetry)
    {
        self.fileContentView.hidden = NO;
        [self.flagImageView setImage:[self getFlagImage]];
        self.fileNameLable.text = mode.groupFile.filename;
        self.descriptionLable.text = mode.groupFile.info;
        self.creatDateLable.text = mode.groupFile.create_time;
        self.operationView.hidden = NO;
        self.operationL.text = @"下载";
        self.operationTip.hidden = YES;
        self.progressView.hidden = YES;
    }else if(modeType == IMFileCellModeType_Preview)
    {
        self.fileContentView.hidden = NO;
        [self.flagImageView setImage:[self getFlagImage]];
        self.fileNameLable.text = mode.groupFile.filename;
        self.descriptionLable.text = mode.groupFile.info;
        self.creatDateLable.text = mode.groupFile.create_time;
        self.operationView.hidden = NO;
        self.operationL.text = @"查看";
        self.operationTip.hidden = YES;
        self.progressView.hidden = YES;
    }else if(modeType == IMFileCellModeType_Deleteing)
    {
        if(mode.groupFile != nil)
        {
            self.fileContentView.hidden = NO;
            [self.flagImageView setImage:[self getFlagImage]];
            self.fileNameLable.text = mode.groupFile.filename;
            self.descriptionLable.text = mode.groupFile.info;
            self.creatDateLable.text = mode.groupFile.create_time;
            self.operationView.hidden = YES;
            self.operationTip.hidden = NO;
            self.operationTip.text = @"删除中";
            self.progressView.hidden = YES;
        }else if(mode.info != nil)
        {
            self.fileContentView.hidden = NO;
            [self.flagImageView setImage:[self getFlagImage]];
            self.fileNameLable.text = mode.info.fileName;
            self.descriptionLable.text = mode.info.info;
            self.creatDateLable.text = mode.info.createDate;
            self.operationView.hidden = YES;
            self.operationTip.hidden = NO;
            self.operationTip.text = @"删除中";
            self.progressView.hidden = YES;
        }else
        {
            self.fileContentView.hidden = YES;
        }
    }else if(modeType == IMFileCellModeType_Error)
    {
        self.fileContentView.hidden = YES;
    }
}

- (void)setProgressViewValue:(CGFloat)value
{
    [self.progressView setProgressValue:value];
}

- (UIImage*)getFlagImage
{
    UIImage *reImage = reImage = [UIImage imageNamed:@"ic_file_unknow"];
    if (self.cellMode != nil) {
        IMFileCellMode *cellMode = (IMFileCellMode*)self.cellMode;
        if (cellMode.groupFile != nil) {
            if ([[cellMode.groupFile.file_type lowercaseString] isEqualToString:@"jpg"]
                || [[cellMode.groupFile.file_type lowercaseString] isEqualToString:@"jpeg"]
                || [[cellMode.groupFile.file_type lowercaseString] isEqualToString:@"png"]
                ) {
                reImage = [UIImage imageNamed:@"ic_file_img"];
            }else if([[cellMode.groupFile.file_type lowercaseString] isEqualToString:@"excel"])
            {
                reImage = [UIImage imageNamed:@"ic_file_excel"];
            }else if([[cellMode.groupFile.file_type lowercaseString] isEqualToString:@"pdf"])
            {
                reImage = [UIImage imageNamed:@"ic_file_pdf"];
            }
            else if([[cellMode.groupFile.file_type lowercaseString] isEqualToString:@"txt"])
            {
                reImage = [UIImage imageNamed:@"ic_file_txt"];
            }
            else if([[cellMode.groupFile.file_type lowercaseString] isEqualToString:@"doc"]
                    || [[cellMode.groupFile.file_type lowercaseString] isEqualToString:@"pptx"]
                    || [[cellMode.groupFile.file_type lowercaseString] isEqualToString:@"ppt"]
                    || [[cellMode.groupFile.file_type lowercaseString] isEqualToString:@"xls"]
                    || [[cellMode.groupFile.file_type lowercaseString] isEqualToString:@"xlsx"]
                    || [[cellMode.groupFile.file_type lowercaseString] isEqualToString:@"docx"])
            {
                reImage = [UIImage imageNamed:@"ic_file_word"];
            }

        }else if(cellMode.info != nil)
        {
            if ([[cellMode.info.attachment lowercaseString] isEqualToString:@"jpg"]
                || [[cellMode.info.attachment lowercaseString] isEqualToString:@"jpeg"]
                || [[cellMode.info.attachment lowercaseString] isEqualToString:@"png"]) {
                reImage = [UIImage imageNamed:@"ic_file_img"];
            }else if ([[cellMode.info.attachment lowercaseString] isEqualToString:@"excel"])
            {
                reImage = [UIImage imageNamed:@"ic_file_excel"];
            }else if ([[cellMode.info.attachment lowercaseString] isEqualToString:@"pdf"])
            {
                reImage = [UIImage imageNamed:@"ic_file_pdf"];
            }else if ([[cellMode.info.attachment lowercaseString] isEqualToString:@"txt"])
            {
                reImage = [UIImage imageNamed:@"ic_file_txt"];
            }else if ([[cellMode.info.attachment lowercaseString] isEqualToString:@"doc"]
                      || [[cellMode.info.attachment lowercaseString] isEqualToString:@"pptx"]
                      || [[cellMode.info.attachment lowercaseString] isEqualToString:@"ppt"]
                      || [[cellMode.info.attachment lowercaseString] isEqualToString:@"xls"]
                      || [[cellMode.info.attachment lowercaseString] isEqualToString:@"xlsx"]
                      || [[cellMode.info.attachment lowercaseString] isEqualToString:@"docx"])
            {
                reImage = [UIImage imageNamed:@"ic_file_word"];
            }
        }
    }
    return reImage;
}

@end

@interface IMFileCellMode()

@property(strong ,nonatomic)BJNetRequestOperation *uploadOperation;
@property(strong ,nonatomic)BJNetRequestOperation *downloadOperation;

@end

@implementation IMFileCellMode

- (void)dealloc
{
    if (self.type == IMFileCellModeType_Uploading) {
        if (self.uploadOperation != nil) {
            [self.uploadOperation cancel];
            self.uploadOperation = nil;
        }
    }else if(self.type == IMFileCellModeType_Downloading)
    {
        if (self.downloadOperation != nil) {
            [self.downloadOperation cancel];
            self.downloadOperation = nil;
        }
    }
}

- (instancetype)initWithFileUploadInfo:(IMFileUploadInfo*)info
{
    self = [super init];
    if (self) {
        self.info = info;
        self.type = IMFileCellModeType_Initialization;
        self.ifShowMenu = NO;
    }
    return self;
}

- (instancetype)initWithGroupFile:(GroupFile*)groupFile
{
    self = [super init];
    if (self) {
        self.groupFile = groupFile;
        self.type = IMFileCellModeType_Initialization;
        self.ifShowMenu = NO;
    }
    return self;
}

-(NSString*)getCellIdentifier
{
    return [NSString stringWithFormat:@"IMFileCellMode"];
}

-(CGFloat)getCellHeight
{
    return 90.0f;
}

-(BaseModeCell*)createModeCell
{
    IMFileCell *cell = [[IMFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getCellIdentifier]];
    return cell;
}

-(void)setModeType:(IMFileCellModeType)modeType
{
    if(self.type != modeType)
    {
        self.type = modeType;
        if (self.modeCell != nil) {
            IMFileCell *cell = (IMFileCell*)self.modeCell;
            [cell setMyCellMode:self];
        }
    }
}

-(IMFileCellModeType)getModeType
{
    if (self.type == IMFileCellModeType_Initialization) {
        if (self.groupFile != nil) {
            if ([IMLinshiTool ifExistFile:[BJChatFileCacheManager groupFileCachePathWithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:self.groupFile.file_url],self.groupFile.file_type]]]) {
                self.type = IMFileCellModeType_Preview;
            }else
            {
                self.type = IMFileCellModeType_Download;
            }
        }else if(self.info != nil)
        {
            if ([IMLinshiTool ifExistFile:[BJChatFileCacheManager uploadFileCachePathwithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:self.info.filePath],self.info.attachment]]]) {
                self.type = IMFileCellModeType_UploadWait;
                [self startUploadFile];
            }else
            {
                self.type = IMFileCellModeType_Error;
            }
        }
    }
    return self.type;
}

-(BOOL)ifCanEidtmenu
{
    if (self.type == IMFileCellModeType_Download
        ||self.type == IMFileCellModeType_DownloadWait
        ||self.type == IMFileCellModeType_Downloading
        ||self.type == IMFileCellModeType_Preview) {
        return self.groupFile.show_delete;
    }else
    {
        return YES;
    }
}

- (void)userCilckOperationBtn
{
    if (self.type == IMFileCellModeType_Preview) {
        if (self.fileDelegate != nil) {
            [self.fileDelegate userPreviewGroupFile:self];
        }
    }else if (self.type == IMFileCellModeType_Download || self.type == IMFileCellModeType_DownloadRetry)
    {
        [self setModeType:IMFileCellModeType_DownloadWait];
        [self startDownloadFile];
    }else if (self.type == IMFileCellModeType_Upload || self.type == IMFileCellModeType_UploadRetry)
    {
        [self setModeType:IMFileCellModeType_UploadWait];
        [self startUploadFile];
    }
}

- (void)userCilckDeleteBtn
{
    if (self.fileDelegate != nil) {
        [self.fileDelegate userDeleteGroupFile:self];
    }
}

- (void)startUploadFile
{
    WS(weakself);
    self.uploadOperation = [[BJIMManager shareInstance] uploadGroupFile:self.info.attachment filePath:[BJChatFileCacheManager uploadFileCachePathwithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:self.info.filePath],self.info.attachment]] fileName:self.info.fileName callback:^(NSError *error,int64_t storage_id,NSString *storage_url) {
        if (error) {
            [weakself setModeType:IMFileCellModeType_UploadRetry];
        }else
        {
            weakself.info.storage_id = storage_id;
            [weakself setModeType:IMFileCellModeType_AddFile];
            [weakself startAddFile];
        }
    } progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpected) {
        weakself.progress = totalBytesWritten/totalBytesExpected;
        [weakself setModeType:IMFileCellModeType_Uploading];
        if (self.modeCell != nil) {
            IMFileCell *cell = (IMFileCell*)self.modeCell;
            [cell setProgressViewValue:weakself.progress];
        }
    }];
}

- (void)startAddFile
{
    WS(weakself);
    [[BJIMManager shareInstance] addGroupFile:self.info.group_id storage_id:self.info.storage_id fileName:self.info.fileName callback:^(NSError *error, GroupFile *groupFile) {
        if (error) {
            [weakself setModeType:IMFileCellModeType_UploadRetry];
        }else{
            weakself.groupFile = groupFile;
            
            NSData *fileData = [NSData dataWithContentsOfFile:[BJChatFileCacheManager uploadFileCachePathwithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:weakself.info.filePath],weakself.info.attachment]]];
            
            if (![IMLinshiTool ifExistDircory:[BJChatFileCacheManager chatGroupFilePath]]) {
                [IMLinshiTool createDirectory:[BJChatFileCacheManager chatGroupFilePath]];
            }
            
            [fileData writeToFile:[BJChatFileCacheManager groupFileCachePathWithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:weakself.groupFile.file_url],weakself.groupFile.file_type]] atomically:YES];
            
            [weakself setModeType:IMFileCellModeType_Preview];
        }
    }];
}

- (void)startDownloadFile
{
    WS(weakself);
    if (![IMLinshiTool ifExistDircory:[BJChatFileCacheManager chatDownloadFilePath]]) {
        [IMLinshiTool createDirectory:[BJChatFileCacheManager chatDownloadFilePath]];
    }
    self.downloadOperation = [[BJIMManager shareInstance] downloadGroupFile:self.groupFile.file_url filePath:[BJChatFileCacheManager downloadFileCacherPathWithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:self.groupFile.file_url],self.groupFile.file_type]] callback:^(NSError *error) {
        if (error) {
            [weakself setModeType:IMFileCellModeType_DownloadRetry];
        }else
        {
            NSData *fileData = [NSData dataWithContentsOfFile:[BJChatFileCacheManager downloadFileCacherPathWithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:weakself.groupFile.file_url],weakself.groupFile.file_type]]];
            
            if (![IMLinshiTool ifExistDircory:[BJChatFileCacheManager chatGroupFilePath]]) {
                [IMLinshiTool createDirectory:[BJChatFileCacheManager chatGroupFilePath]];
            }
            
            [fileData writeToFile:[BJChatFileCacheManager groupFileCachePathWithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:weakself.groupFile.file_url],weakself.groupFile.file_type]] atomically:YES];
            
            [weakself setModeType:IMFileCellModeType_Preview];
        }
    } progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpected) {
        weakself.progress = totalBytesWritten/totalBytesExpected;
        [weakself setModeType:IMFileCellModeType_Downloading];
        if (self.modeCell != nil) {
            IMFileCell *cell = (IMFileCell*)self.modeCell;
            [cell setProgressViewValue:weakself.progress];
        }
    }];
}

@end

//
//  GroupFileViewController.m
//
//  Created by wangziliang on 15/12/3.
//

#import "GroupFileViewController.h"
#import "IMFileCellMode.h"
#import "CustomTableView.h"
#import "MyImagePickerViewController.h"
#import "BJChatFileCacheManager.h"
#import "IMLinshiTool.h"
#import "IMFilePreviewViewController.h"
#import <BJHL-IM-iOS-SDK/BJIMManager.h>
#import <BJHL-Common-iOS-SDK/NSDateFormatter+Category.h>
#import "MBProgressHUD+IMKit.h"
#import "IMInputDialog.h"
#import "IMActionSheet.h"

@interface GroupFileViewController()<CustomTableViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,MyImagePickerViewControllerDelegate,IMFileCellModeDelegate>

@property (strong, nonatomic) NSString *im_group_id;
@property (strong, nonatomic) CustomTableViewController *customTableViewController;
@property (strong, nonatomic) NSMutableArray<IMFileCellMode *> *fileModeArray;
@property (nonatomic) BOOL ifCanLoadMore;

@property (strong, nonatomic) UIView *noHaveNoticeView;
@property (strong, nonatomic) UIImageView *noNoticeImageView;
@property (strong, nonatomic) UILabel *noNoticeTip;
@property (strong, nonatomic) UIButton *releaseBtn;

@property (weak ,nonatomic)UIView *curView;


@end

@implementation GroupFileViewController

-(instancetype)initWithGroudId:(NSString*)groudId
{
    self = [super init];
    if (self) {
        self.im_group_id = groudId;
        self.ifCanLoadMore = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ebeced"];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 14, 22)];
    [backBtn setImage:[UIImage imageNamed:@"im_black_leftarrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemBar = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = itemBar;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上传文件" style:UIBarButtonItemStyleDone target:self action:@selector(uploadFile)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.title = @"群文件";
    
    [self requestGroupFiles];
    
}

- (void)backAction:(id)aciton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)uploadFile
{
    //MyImagePickerViewController *imagePicker = [[MyImagePickerViewController alloc] init];
    //imagePicker.delegate = self;
    //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imagePicker];
    //[self presentViewController:nav animated:YES completion:nil];
    
    IMActionSheet *actionSheet = [[IMActionSheet alloc] init];
    NSArray *array = [NSArray arrayWithObjects:@"从相册选择",@"打开相机拍照", nil];
    [actionSheet showWithTitle:@"请选择上传方式" withArray:array withCurIndex:-1 withSelectBlock:^(NSInteger index) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        if (index == 0) {
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            NSArray *mediaArray = [NSArray arrayWithObjects:(NSString*)kUTTypeImage,( NSString *)kUTTypeMovie, nil];
            [imagePicker setMediaTypes:mediaArray];
        }else if(index == 1)
        {
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            NSArray *mediaArray = [NSArray arrayWithObjects:(NSString*)kUTTypeImage, nil];
            [imagePicker setMediaTypes:mediaArray];
        }
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    } withCancelBlock:^{
        
    }];
}

- (void)requestGroupFiles
{
    WS(weakself);
    int64_t last_file_id = 0;
    if (self.fileModeArray != nil && [self.fileModeArray count]>0) {
        IMFileCellMode *lastFileMode = [self.fileModeArray lastObject];
        if (lastFileMode.groupFile != nil) {
            last_file_id = lastFileMode.groupFile.fileId;
        }
    }
    [[BJIMManager shareInstance] getGroupFiles:[self.im_group_id longLongValue] last_file_id:last_file_id callback:^(NSError *error, NSArray<GroupFile *> *list) {
        if (error) {
            
        }else
        {
            [weakself addGroupFiles:list];
        }
    }];
}

-(void)addGroupFiles:(NSArray<GroupFile *> *)list
{
    if (list != nil && [list count] > 0) {
        NSMutableArray *rowArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[list count]; i++) {
            IMFileCellMode *fileMode = [[IMFileCellMode alloc] initWithGroupFile:[list objectAtIndex:i]];
            fileMode.fileDelegate = self;
            [rowArray addObject:fileMode];
        }
        
        IMFileCellMode *firstFileMode = [self.fileModeArray firstObject];
        if (firstFileMode != nil) {
            [firstFileMode.sectionMode addRows:rowArray];
        }else
        {
            SectionMode *sMode = [[SectionMode alloc] init];
            [sMode setRows:rowArray];
            [self.customTableViewController setSections:[NSArray arrayWithObjects:sMode, nil]];
        }
        
        [self.fileModeArray addObjectsFromArray:rowArray];
        self.ifCanLoadMore = YES;
    }else
    {
        self.ifCanLoadMore = NO;
    }
    
    if ([self.fileModeArray count]>0) {
        [self switchCurView:self.customTableViewController.view];
    }else
    {
        [self switchCurView:self.noHaveNoticeView];
    }
}

- (void)userHitCellMode:(BaseCellMode *)cellMode
{
    
}

- (void)userScrollBottom
{
    if (self.ifCanLoadMore) {
        [self requestGroupFiles];
    }
}

- (void)MyimagePickerController:(MyImagePickerViewController *)picker withCellMode:(CollectionItemCellMode *)cellMode
{
    ALAssetRepresentation* assetRepresentation = [cellMode.asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage] scale:1.0f orientation:(UIImageOrientation)[assetRepresentation orientation]];
    NSData *jpgData = UIImageJPEGRepresentation(image, 0.75);
    NSString *filePath = [[assetRepresentation url] absoluteString];
    
    if (![IMLinshiTool ifExistDircory:[BJChatFileCacheManager chatUploadFilePath]]) {
        [IMLinshiTool createDirectory:[BJChatFileCacheManager chatUploadFilePath]];
    }
    
    [jpgData writeToFile:[BJChatFileCacheManager uploadFileCachePathwithName:[NSString stringWithFormat:@"%@.jpg",[IMLinshiTool getStringWithStringByMD5:filePath]]] atomically:YES];
    
    IMFileUploadInfo *info = [[IMFileUploadInfo alloc] init];
    info.group_id = [self.im_group_id longLongValue];
    info.attachment = @"jpg";
    info.filePath = filePath;
    info.fileName = [assetRepresentation filename];
    info.info = @"来自自己";
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
    info.createDate = [formatter stringFromDate:date];
    
    IMFileCellMode *mode = [[IMFileCellMode alloc] initWithFileUploadInfo:info];
    mode.fileDelegate = self;
    
    IMFileCellMode *firstFileMode = [self.fileModeArray firstObject];
    if (firstFileMode != nil) {
        [firstFileMode.sectionMode insertRows:[NSArray arrayWithObjects:mode, nil] withInsertCellMode:firstFileMode withInsertType:ArrayInsertPosition_Before];
    }else
    {
        SectionMode *sMode = [[SectionMode alloc] init];
        [sMode setRows:[NSArray arrayWithObjects:mode, nil]];
        [self.customTableViewController setSections:[NSArray arrayWithObjects:sMode, nil]];
    }
    
    [self.fileModeArray insertObject:mode atIndex:0];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)addNewUploadFileMode:(NSData*)data withattachment:(NSString*)attachment
{
    if([data length] > 1024*1024*20)
    {
        [MBProgressHUD imShowError:@"文件大小不能超过20M" toView:self.view];
    }else
    {
        WS(weakSelf);
        IMInputDialog *inputD = [[IMInputDialog alloc] init];
        NSString *defaultContent = [NSString stringWithFormat:@"gsx_%.0f",[[NSDate date] timeIntervalSince1970]*100];
        [inputD showWithDefaultContent:defaultContent withInputComplete:^(NSString *content) {
            NSString *filePath = defaultContent;
            
            if (![IMLinshiTool ifExistDircory:[BJChatFileCacheManager chatUploadFilePath]]) {
                [IMLinshiTool createDirectory:[BJChatFileCacheManager chatUploadFilePath]];
            }
            
            [data writeToFile:[BJChatFileCacheManager uploadFileCachePathwithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:filePath],attachment]] atomically:YES];
            
            IMFileUploadInfo *info = [[IMFileUploadInfo alloc] init];
            info.group_id = [self.im_group_id longLongValue];
            info.attachment = attachment;
            info.filePath = filePath;
            info.fileName = content;
            
            info.info = [NSString stringWithFormat:@"%@ 来自自己",[IMLinshiTool getSizeStrWithFileSize:[data length]]];
            
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
            info.createDate = [formatter stringFromDate:date];
            
            IMFileCellMode *mode = [[IMFileCellMode alloc] initWithFileUploadInfo:info];
            mode.fileDelegate = weakSelf;
            
            [self switchCurView:self.customTableViewController.view];
            
            IMFileCellMode *firstFileMode = [weakSelf.fileModeArray firstObject];
            if (firstFileMode != nil) {
                [firstFileMode.sectionMode insertRows:[NSArray arrayWithObjects:mode, nil] withInsertCellMode:firstFileMode withInsertType:ArrayInsertPosition_Before];
            }else
            {
                SectionMode *sMode = [[SectionMode alloc] init];
                [sMode setRows:[NSArray arrayWithObjects:mode, nil]];
                [weakSelf.customTableViewController setSections:[NSArray arrayWithObjects:sMode, nil]];
            }
            
            [weakSelf.fileModeArray insertObject:mode atIndex:0];
        } withInputCancel:^{
            
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断获取类型：图片
    if ([mediaType isEqualToString:( NSString *)kUTTypeImage]){
        UIImage *theImage = nil;
        // 判断，图片是否允许修改
        if ([picker allowsEditing]){
            //获取用户编辑之后的图像
            theImage = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            // 照片的元数据参数
            theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            
        }
        
        NSData *jpgData = UIImageJPEGRepresentation(theImage, 0.75);
        
        [self addNewUploadFileMode:jpgData withattachment:@"jpg"];
        // 保存图片到相册中
        //SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        //UIImageWriteToSavedPhotosAlbum(theImage, self,selectorToCall, NULL);
        
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        // 判断获取类型：视频
        //获取视频文件的url
        NSURL* mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
        //创建ALAssetsLibrary对象并将视频保存到媒体库
        // Assets Library 框架包是提供了在应用程序中操作图片和视频的相关功能。相当于一个桥梁，链接了应用程序和多媒体文件。
        
        NSData *videoData = [NSData dataWithContentsOfURL:mediaURL];
        
        [self addNewUploadFileMode:videoData withattachment:@"mov"];
        
        //ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // 将视频保存到相册中
        /*
        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:mediaURL
                                          completionBlock:^(NSURL *assetURL, NSError *error) {
                                              if (!error) {
                                                  NSLog(@"captured video saved with no error.");
                                              }else{
                                                  NSLog(@"error occured while saving the video:%@", error);
                                              }
                                          }];
         */
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIView*)noHaveNoticeView
{
    if (_noHaveNoticeView == nil) {
        CGRect rectScreen = [UIScreen mainScreen].bounds;
        CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        CGRect rectNav = self.navigationController.navigationBar.frame;
        _noHaveNoticeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, rectScreen.size.height-rectStatus.size.height-rectNav.size.height)];
        _noHaveNoticeView.backgroundColor = [UIColor clearColor];
        
        _noNoticeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_noHaveNoticeView.frame.size.width-80)/2, (_noHaveNoticeView.frame.size.height-175)/2, 75, 80)];
        [_noNoticeImageView setImage:[UIImage imageNamed:@"hermes_ic_emotion_default"]];
        [_noHaveNoticeView addSubview:_noNoticeImageView];
        
        _noNoticeTip = [[UILabel alloc] initWithFrame:CGRectMake(15,(_noHaveNoticeView.frame.size.height-175)/2+90 , _noHaveNoticeView.frame.size.width-30, 15)];
        _noNoticeTip.backgroundColor= [UIColor clearColor];
        _noNoticeTip.font = [UIFont systemFontOfSize:13.0f];
        _noNoticeTip.text = @"还没添加任何群文件";
        _noNoticeTip.textColor = [UIColor colorWithHexString:IMCOLOT_GREY500];
        _noNoticeTip.textAlignment = NSTextAlignmentCenter;
        [_noHaveNoticeView addSubview:_noNoticeTip];
        
        _releaseBtn = [[UIButton alloc] initWithFrame:CGRectMake((_noHaveNoticeView.frame.size.width-120)/2, (_noHaveNoticeView.frame.size.height-175)/2+90+15+30, 120, 40)];
        _releaseBtn.backgroundColor = [UIColor colorWithHexString:@"#ff9100"];
        [_releaseBtn.layer setCornerRadius:2.0f];
        [_releaseBtn setTitle:@"上传文件" forState:UIControlStateNormal];
        [_releaseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_releaseBtn addTarget:self action:@selector(hitReleaseBtn) forControlEvents:UIControlEventTouchUpInside];
        [_noHaveNoticeView addSubview:_releaseBtn];
    }
    return _noHaveNoticeView;
}

- (void)hitReleaseBtn
{
    [self uploadFile];
}

- (CustomTableViewController *)customTableViewController
{
    if (_customTableViewController == nil) {
        CGRect rectScreen = [UIScreen mainScreen].bounds;
        CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        CGRect rectNav = self.navigationController.navigationBar.frame;
        _customTableViewController = [[CustomTableViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, rectScreen.size.height-rectStatus.size.height-rectNav.size.height)];
        _customTableViewController.delegate = self;
        [self.view addSubview:self.customTableViewController.view];
    }
    return _customTableViewController;
}

- (NSMutableArray<IMFileCellMode *> *)fileModeArray
{
    if (_fileModeArray == nil) {
        _fileModeArray = [[NSMutableArray alloc] init];
    }
    return _fileModeArray;
}

- (void)switchCurView:(UIView*)toView
{
    if (self.curView != toView) {
        if (self.curView != nil) {
            [self.curView removeFromSuperview];
        }
        self.curView = toView;
        [self.view addSubview:self.curView];
    }
}

- (void)userPreviewGroupFile:(IMFileCellMode *)cellMode
{
    IMFilePreviewViewController *preview = [[IMFilePreviewViewController alloc] initWithGroupFile:self.im_group_id withGroupFile:cellMode.groupFile];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:preview];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)userDeleteGroupFile:(IMFileCellMode *)cellMode
{
    if ([self.fileModeArray containsObject:cellMode] && cellMode.sectionMode != nil) {
        if (cellMode.groupFile != nil) {
            WS(weakSelf);
            [[BJIMManager shareInstance] deleteGroupFile:[self.im_group_id longLongValue] file_id:cellMode.groupFile.fileId callback:^(NSError *error) {
                if (error) {
                    [MBProgressHUD imShowError:@"删除失败" toView:weakSelf.view];
                }else
                {
                    [cellMode.sectionMode removeRows:[NSArray arrayWithObjects:cellMode, nil]];
                }
            }];
        }else
        {
            [cellMode.sectionMode removeRows:[NSArray arrayWithObjects:cellMode, nil]];
        }
    }
}

@end

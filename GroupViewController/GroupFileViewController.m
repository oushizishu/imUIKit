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

@interface GroupFileViewController()<CustomTableViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,MyImagePickerViewControllerDelegate,IMFileCellModeDelegate>

@property (strong, nonatomic) NSString *im_group_id;
@property (strong, nonatomic) CustomTableViewController *customTableViewController;
@property (strong, nonatomic) NSMutableArray<IMFileCellMode *> *fileModeArray;
@property (nonatomic) BOOL ifCanLoadMore;


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
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ebeced"];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 14, 22)];
    [backBtn setImage:[UIImage imageNamed:@"im_black_leftarrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemBar = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = itemBar;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上传文件" style:UIBarButtonItemStylePlain target:self action:@selector(uploadFile)];
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
    MyImagePickerViewController *imagePicker = [[MyImagePickerViewController alloc] init];
    imagePicker.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imagePicker];
    [self presentViewController:nav animated:YES completion:nil];
    //UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    //imagePicker.delegate = self;
    //[self presentViewController:imagePicker animated:YES completion:nil];
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
    info.createDate = @"上传时间";
    
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerEditedImage];
    NSURL* url = [info objectForKey:UIImagePickerControllerMediaURL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
}

- (CustomTableViewController *)customTableViewController
{
    if (_customTableViewController == nil) {
        CGRect rectScreen = [UIScreen mainScreen].bounds;
        CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        CGRect rectNav = self.navigationController.navigationBar.frame;
        _customTableViewController = [[CustomTableViewController alloc] initWithFrame:CGRectMake(0, rectStatus.size.height+rectNav.size.height, self.view.frame.size.width, rectScreen.size.height-rectStatus.size.height-rectNav.size.height)];
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
                    [MBProgressHUD showError:@"删除失败" toView:weakSelf.view];
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

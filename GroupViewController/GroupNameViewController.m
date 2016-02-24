//
//  GroupNameViewController.m
//
//  Created by wangziliang on 15/12/4.
//

#import "GroupNameViewController.h"

#import <BJHL-IM-iOS-SDK/BJIMManager.h>
#import "IMLinshiTool.h"
#import "IMActionSheet.h"
#import "BJChatFileCacheManager.h"
#import "MBProgressHUD+IMKit.h"

#import <BJHL-Foundation-iOS/BJHL-Foundation-iOS.h>
#import <BJHL-Kit-iOS/BJHL-Kit-iOS.h>

#import <MobileCoreServices/MobileCoreServices.h>

@interface GroupNameViewController()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSString *im_group_id;
@property (strong, nonatomic) GroupDetail *groupDetail;
@property (strong, nonatomic) UIImageView *faceImageView;
@property (strong, nonatomic) UILabel *tipLable;
@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UIButton *saveBtn;

@property (assign, nonatomic) int64_t storage_id;

@property (strong ,nonatomic) IMActionSheet *actionSheet;

@end

@implementation GroupNameViewController

-(instancetype)initWithGroudId:(NSString*)groudId withGroupDetail:(GroupDetail*)groupDetail
{
    self = [super init];
    if (self) {
        self.groupDetail = groupDetail;
        self.im_group_id = groudId;
        
        self.storage_id = 0;
    }
    return self;
}


- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor bjck_colorWithHexString:@"#ebeced"];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 14, 22)];
    [backBtn setImage:[UIImage imageNamed:@"im_black_leftarrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemBar = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = itemBar;
    
    //self.title = @"群名称";
    
    CGRect sRect = [UIScreen mainScreen].bounds;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sRect.size.width-160, 30)];
    label.font = [UIFont systemFontOfSize:18.0f];
    label.text = @"群名称";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    self.navigationItem.titleView = label;
    
    self.faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake((sRect.size.width-70)/2, 40, 70, 70)];
    [self.faceImageView.layer setCornerRadius:3.0f];
    self.faceImageView.layer.masksToBounds = YES;
    self.faceImageView.backgroundColor = [UIColor grayColor];
    [self.faceImageView bjck_setAliyunImageWithURL:[NSURL URLWithString:self.groupDetail.avatar] placeholderImage:nil];
    [self.view addSubview:self.faceImageView];
    
    self.tipLable = [[UILabel alloc] initWithFrame:CGRectMake((sRect.size.width-100)/2, 120, 100, 20)];
    self.tipLable.backgroundColor = [UIColor clearColor];
    self.tipLable.font = [UIFont systemFontOfSize:13.0f];
    self.tipLable.text = @"点击换头像";
    self.tipLable.textColor = [UIColor bjck_colorWithHexString:IMCOLOT_GREY500];
    self.tipLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.tipLable];
    
    UIView *textfieldBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 160, sRect.size.width, 44)];
    textfieldBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textfieldBackView];
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, textfieldBackView.frame.size.width-30, textfieldBackView.frame.size.height)];
    self.nameTextField.backgroundColor = [UIColor clearColor];
    self.nameTextField.text = self.groupDetail.group_name;
    self.nameTextField.font = [UIFont systemFontOfSize:13.0f];
    
    [self.nameTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [textfieldBackView addSubview:self.nameTextField];
    
    User *owner = [IMEnvironment shareInstance].owner;
    if (owner.userId != self.groupDetail.user_number || owner.userRole != self.groupDetail.user_role) {
        self.nameTextField.userInteractionEnabled = NO;
        self.tipLable.hidden = YES;
    }else
    {
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceImagePressed:)];
        self.faceImageView.userInteractionEnabled = YES;
        [self.faceImageView addGestureRecognizer:tapG];
        
        self.saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 25)];
        [self.saveBtn setTitleColor:[UIColor bjck_colorWithHexString:IMCOLOT_GREY400] forState:UIControlStateNormal];
        [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [self.saveBtn addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.saveBtn];
        
        //UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        
        self.saveBtn.userInteractionEnabled = NO;
        
    }
    
}

- (void)textFieldChanged:(id)sender{
    
    if (self.storage_id == 0) {
        if ([self.nameTextField.text isEqualToString:self.groupDetail.group_name]) {
            self.saveBtn.userInteractionEnabled = NO;
            [self.saveBtn setTitleColor:[UIColor bjck_colorWithHexString:IMCOLOT_GREY400] forState:UIControlStateNormal];
        }else
        {
            if (self.nameTextField.text.length > 0) {
                self.saveBtn.userInteractionEnabled = YES;
                [self.saveBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            }else
            {
                self.saveBtn.userInteractionEnabled = NO;
                [self.saveBtn setTitleColor:[UIColor bjck_colorWithHexString:IMCOLOT_GREY400] forState:UIControlStateNormal];
            }
        }
    }
    
}

- (void)faceImagePressed:(id)sender
{
    [self.view endEditing:YES];
    self.actionSheet = [[IMActionSheet alloc] init];
    NSArray *array = [NSArray arrayWithObjects:@"从相册选择",@"打开相机拍照", nil];
    [self.actionSheet showWithTitle:@"请选择上传方式" withArray:array withCurIndex:-1 withSelectBlock:^(NSInteger index) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        if (index == 0) {
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            NSArray *mediaArray = [NSArray arrayWithObjects:(NSString*)kUTTypeImage, nil];
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

- (void)uploadFile:(NSData*)data withattachment:(NSString*)attachment
{
    WS(weakself);
    NSString *filePath = [NSString stringWithFormat:@"group_%@_faceimage_%f",self.im_group_id,[[NSDate date] timeIntervalSince1970]];
    
    if (![IMLinshiTool ifExistDircory:[BJChatFileCacheManager chatUploadFilePath]]) {
        [IMLinshiTool createDirectory:[BJChatFileCacheManager chatUploadFilePath]];
    }
    
    [data writeToFile:[BJChatFileCacheManager uploadFileCachePathwithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:filePath],attachment]] atomically:YES];
    
    NSString *fileName = [NSString stringWithFormat:@"faceimage.%@",attachment];
    
    /*
    [[BJIMManager shareInstance] uploadGroupFile:attachment filePath:[BJChatFileCacheManager uploadFileCachePathwithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:filePath],attachment]] fileName:fileName callback:^(NSError *error,int64_t storage_id,NSString *storage_url) {
        if (error) {
            [MBProgressHUD imShowError:@"图片上传失败" toView:weakself.view];
        }else
        {
            weakself.storage_id = storage_id;
            [weakself setGRoupFaceImageUrl:[UIImage imageWithData:data]];
        }
    } progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpected) {
    }];
    */
    
    [[BJIMManager shareInstance] uploadImageFile:fileName filePath:[BJChatFileCacheManager uploadFileCachePathwithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:filePath],attachment]] callback:^(NSError *error,int64_t storage_id,NSString *storage_url) {
        if (error) {
            [MBProgressHUD imShowError:@"图片上传失败" toView:weakself.view];
        }else
        {
            weakself.storage_id = storage_id;
            [weakself setGRoupFaceImageUrl:[UIImage imageWithData:data]];
        }
    }];
}

- (void)setGRoupFaceImageUrl:(UIImage*)image
{
    self.saveBtn.userInteractionEnabled = YES;
    [self.saveBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.faceImageView setImage:image];
}

- (void)saveAction
{
    WS(weakSelf);
    [self.view endEditing:YES];
    [[BJIMManager shareInstance] setGroupNameAvatar:[self.im_group_id longLongValue]
                                          groupName:self.nameTextField.text
                                             avatar:self.storage_id
                                           callback:^(NSError *error){
                                               if (error) {
                                                   [MBProgressHUD imShowError:@"保存失败" toView:weakSelf.view];
                                               }else
                                               {
                                                   [weakSelf backAction:nil];
                                                   /*
                                                   weakSelf.storage_id = 0;
                                                   weakSelf.groupDetail.group_name = weakSelf.nameTextField.text;
                                                   weakSelf.saveBtn.userInteractionEnabled = NO;
                                                   [weakSelf.saveBtn setTitleColor:[UIColor bjck_colorWithHexString:IMCOLOT_GREY400] forState:UIControlStateNormal];
                                                    */
                                               }
                                           }];
}

- (void)backAction:(id)aciton
{
    [self.navigationController popViewControllerAnimated:YES];
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
        
        //NSData *pngData = UIImagePNGRepresentation(theImage);
        
        [self uploadFile:jpgData withattachment:@"jpg"];
        // 保存图片到相册中
        //SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        //UIImageWriteToSavedPhotosAlbum(theImage, self,selectorToCall, NULL);
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end

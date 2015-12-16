//
//  IMFilePreviewViewController.m
//
//  Created by wangziliang on 15/12/10.
//

#import "IMFilePreviewViewController.h"
#import "BJChatFileCacheManager.h"
#import "IMLinshiTool.h"
#import <BJHL-IM-iOS-SDK/BJIMManager.h>

@interface IMFilePreviewViewController()

@property (strong, nonatomic) NSString *im_group_id;
@property (strong ,nonatomic)GroupFile *groupFile;

@property (strong ,nonatomic)UIImageView *imageView;
@property (strong ,nonatomic)UIWebView *webView;
@property (strong ,nonatomic)UIView *operationView;
@property (strong ,nonatomic)UIButton *operationBtn;

@end

@implementation IMFilePreviewViewController

- (instancetype)initWithGroupFile:(NSString*)groudId withGroupFile:(GroupFile*)groupFile
{
    self = [super init];
    if (self) {
        self.im_group_id = groudId;
        self.groupFile = groupFile;
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
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ebeced"];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 14, 22)];
    [backBtn setImage:[UIImage imageNamed:@"im_black_leftarrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemBar = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = itemBar;
    
    self.title = @"文件预览";
    
    CGRect sRect = [UIScreen mainScreen].bounds;
    
    self.operationView = [[UIView alloc] initWithFrame:CGRectMake(0, sRect.size.height-50, sRect.size.width, 50)];
    self.operationView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.operationView];
    self.operationBtn = [[UIButton alloc] initWithFrame:CGRectMake((sRect.size.width-200)/2, 10, 200, 25)];
    [self.operationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.operationBtn setTitle:@"用其他应用打开" forState:UIControlStateNormal];
    [self.operationView addSubview:self.operationBtn];
    
    [self previewGroupFile];
}

- (void)previewGroupFile
{
    if ([self.groupFile.file_type isEqualToString:@"jpg"]
        || [self.groupFile.file_type isEqualToString:@"jpeg"]
        || [self.groupFile.file_type isEqualToString:@"png"]) {
        
        UIImage *preImage = [UIImage imageWithContentsOfFile:[BJChatFileCacheManager groupFileCachePathWithName:[NSString stringWithFormat:@"%@.%@",[IMLinshiTool getStringWithStringByMD5:self.groupFile.file_url],self.groupFile.file_type]]];
        
        CGSize imageSize = preImage.size;
        
        CGRect rectScreen = [UIScreen mainScreen].bounds;
        CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        CGRect rectNav = self.navigationController.navigationBar.frame;
        
        CGSize frameSize = CGSizeMake(rectScreen.size.width, rectScreen.size.height-rectStatus.size.height-rectNav.size.height-50);
        
        CGFloat scl = 0;
        CGSize imageViewSize = CGSizeZero;
        if(imageSize.width/frameSize.width > imageSize.height/frameSize.height)
        {
            scl = imageSize.width/frameSize.width;
            imageViewSize = CGSizeMake(frameSize.width, imageSize.height/scl);
        }else
        {
            scl = imageSize.height/frameSize.height;
            imageViewSize = CGSizeMake(imageSize.width/scl, frameSize.height);
        }
        
        self.imageView.frame = CGRectMake((frameSize.width-imageViewSize.width)/2, (frameSize.height-imageViewSize.height)/2,imageViewSize.width,imageViewSize.height);
        [self.imageView setImage:preImage];
        
    }else if (self.groupFile.support_preview)
    {
        [self requestPerivewURl];
    }else{
        
    }
}

- (void)requestPerivewURl
{
    WS(weakself);
    [[BJIMManager shareInstance] previewGroupFile:[self.im_group_id longLongValue] file_id:self.groupFile.fileId callback:^(NSError *error, NSString *url) {
        if (error) {
            
        }else
        {
            CGRect rectScreen = [UIScreen mainScreen].bounds;
            CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
            CGRect rectNav = self.navigationController.navigationBar.frame;
            weakself.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, rectNav.size.height+rectStatus.size.height, rectScreen.size.width, rectScreen.size.height-rectNav.size.height-rectStatus.size.height-50)];
            [weakself.view addSubview:weakself.webView];
            NSURL *requestUrl =[NSURL URLWithString:url];
            NSURLRequest *request =[NSURLRequest requestWithURL:requestUrl];
            [weakself.webView loadRequest:request];
        }
    }];
}

- (void)backAction:(id)aciton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImageView*)imageView
{
    if (_imageView == nil) {
        CGRect sRect = [UIScreen mainScreen].bounds;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

@end

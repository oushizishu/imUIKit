//
//  ReleaseAnnouncementViewController.m
//
//  Created by wangziliang on 15/12/1.
//

#import "ReleaseAnnouncementViewController.h"
#import "UIColor+Util.h"
#import <BJHL-IM-iOS-SDK/BJIMManager.h>

@interface ReleaseAnnouncementViewController()<UITextViewDelegate>

@property(strong ,nonatomic)NSString *im_group_Id;
@property(strong ,nonatomic)UIView *editView;
@property(strong ,nonatomic)UITextView *textView;
@property(strong ,nonatomic)UILabel *tipLable;

@end

@implementation ReleaseAnnouncementViewController

-(instancetype)initWithGroupId:(NSString *)groupId
{
    self = [super init];
    if (self) {
        self.im_group_Id = groupId;
    }
    return self;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ebeced"];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 14, 22)];
    [backBtn setImage:[UIImage imageNamed:@"im_black_leftarrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemBar = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = itemBar;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(releaseAnnouncement)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.title = @"发布群公告";
    
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    CGRect rectNav = self.navigationController.navigationBar.frame;
    self.editView = [[UIView alloc] initWithFrame:CGRectMake(0, rectStatus.size.height+rectNav.size.height, self.view.frame.size.width, 200)];
    self.editView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.editView];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 15, self.editView.frame.size.width-30, 140)];
    self.textView.font = [UIFont systemFontOfSize:16.0f];
    self.textView.delegate = self;
    [self.editView addSubview:self.textView];
    
    self.tipLable = [[UILabel alloc] initWithFrame:CGRectMake(15, self.editView.frame.size.height-35, self.editView.frame.size.width-30, 20)];
    self.tipLable.textAlignment = NSTextAlignmentRight;
    self.tipLable.textColor = [UIColor grayColor];
    self.tipLable.text = @"剩余500字";
    self.tipLable.font = [UIFont systemFontOfSize:16.0f];
    [self.editView addSubview:self.tipLable];
    
}

- (void)releaseAnnouncement
{
    WS(weakSelf);
    [[BJIMManager shareInstance] createGroupNotice:[self.im_group_Id longLongValue] content:self.textView.text callback:^(NSError *error) {
        if (error) {
            
        }else
        {
            [weakSelf backAction:nil];
        }
    }];
}

- (void)backAction:(id)aciton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length>500) {
        textView.text = [textView.text substringWithRange:NSMakeRange(0, 500)];
    }
    self.tipLable.text = [NSString stringWithFormat:@"剩余%ld字",500-textView.text.length];
}

@end

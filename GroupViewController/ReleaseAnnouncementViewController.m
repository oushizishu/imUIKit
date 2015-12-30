//
//  ReleaseAnnouncementViewController.m
//
//  Created by wangziliang on 15/12/1.
//

#import "ReleaseAnnouncementViewController.h"
#import "UIColor+Util.h"
#import <BJHL-IM-iOS-SDK/BJIMManager.h>
#import "MBProgressHUD+IMKit.h"

@interface ReleaseAnnouncementViewController()<UITextViewDelegate>

@property(strong ,nonatomic)NSString *im_group_Id;
@property(strong ,nonatomic)UIView *editView;
@property(strong ,nonatomic)UITextView *textView;
@property(strong ,nonatomic)UILabel *tipLable;
@property(assign ,nonatomic)BOOL ifCanRrelease;

@end

@implementation ReleaseAnnouncementViewController

-(instancetype)initWithGroupId:(NSString *)groupId
{
    self = [super init];
    if (self) {
        self.im_group_Id = groupId;
        self.ifCanRrelease = YES;
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ebeced"];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 14, 22)];
    [backBtn setImage:[UIImage imageNamed:@"im_black_leftarrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemBar = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = itemBar;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(releaseAnnouncement)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    //self.title = @"发布群公告";
    
    CGRect sRect = [UIScreen mainScreen].bounds;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sRect.size.width-160, 30)];
    label.font = [UIFont systemFontOfSize:18.0f];
    label.text = @"发布群公告";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    self.navigationItem.titleView = label;
    
    self.editView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
    self.editView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.editView];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 15, self.editView.frame.size.width-30, 130)];
    self.textView.font = [UIFont systemFontOfSize:16.0f];
    self.textView.delegate = self;
    [self.editView addSubview:self.textView];
    
    self.tipLable = [[UILabel alloc] initWithFrame:CGRectMake(15, self.editView.frame.size.height-35, self.editView.frame.size.width-30, 20)];
    self.tipLable.textAlignment = NSTextAlignmentRight;
    self.tipLable.textColor = [UIColor grayColor];
    self.tipLable.text = @"剩余250字";
    self.tipLable.font = [UIFont systemFontOfSize:16.0f];
    [self.editView addSubview:self.tipLable];
    
    [self.textView becomeFirstResponder];
    
}

- (void)releaseAnnouncement
{
    if (self.ifCanRrelease) {
        
        if (self.textView.text == nil || [self.textView.text length] == 0) {
            [MBProgressHUD imShowError:@"请输入公告内容" toView:self.view];
            return;
        }
        
        WS(weakSelf);
        self.ifCanRrelease = NO;
        [[BJIMManager shareInstance] createGroupNotice:[self.im_group_Id longLongValue] content:self.textView.text callback:^(NSError *error) {
            if (error) {
                weakSelf.ifCanRrelease = YES;
                [MBProgressHUD imShowError:@"公告发布失败" toView:weakSelf.view];
            }else
            {
                [weakSelf backAction:nil];
            }
        }];
    }
}

- (void)backAction:(id)aciton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidChange:(UITextView *)textView
{
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (textView.text.length>250) {
        textView.text = [textView.text substringWithRange:NSMakeRange(0, 250)];
    }
    self.tipLable.text = [NSString stringWithFormat:@"剩余%ld字",250-textView.text.length];
}

@end

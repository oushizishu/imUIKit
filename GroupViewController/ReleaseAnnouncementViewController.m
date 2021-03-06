//
//  ReleaseAnnouncementViewController.m
//
//  Created by wangziliang on 15/12/1.
//

#import "ReleaseAnnouncementViewController.h"

#import <BJHL-IM-iOS-SDK/BJIMManager.h>
#import "MBProgressHUD+IMKit.h"
#import "IMLinshiTool.h"

#import <BJHL-Foundation-iOS/BJHL-Foundation-iOS.h>
#import <BJHL-Kit-iOS/BJHL-Kit-iOS.h>

#define MAXCHARACTERCOUNT 250

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
    self.view.backgroundColor = [UIColor bjck_colorWithHexString:@"#ebeced"];
    
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
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 15, self.editView.frame.size.width-30, 100)];
    self.textView.font = [UIFont systemFontOfSize:16.0f];
    self.textView.delegate = self;
    [self.editView addSubview:self.textView];
    
    self.tipLable = [[UILabel alloc] initWithFrame:CGRectMake(15, self.editView.frame.size.height-35, self.editView.frame.size.width-30, 20)];
    self.tipLable.textAlignment = NSTextAlignmentRight;
    self.tipLable.textColor = [UIColor grayColor];
    self.tipLable.text = [NSString stringWithFormat:@"剩余%d字",MAXCHARACTERCOUNT];
    self.tipLable.font = [UIFont systemFontOfSize:16.0f];
    [self.editView addSubview:self.tipLable];
    
    [self.textView becomeFirstResponder];
    
}

- (void)releaseAnnouncement
{
    if (self.ifCanRrelease) {
        if (self.textView.text == nil || [self.textView.text length] == 0) {
            [MBProgressHUD imShowError:@"请输入公告内容" toView:self.textView];
            //[MBProgressHUD imShowError:@"请输入公告内容"];
            return;
        }
        
        /*
        CGRect sRect = [UIScreen mainScreen].bounds;
        NSArray *spA = [IMLinshiTool splitMsg:self.textView.text withFont:[UIFont systemFontOfSize:16.0f] withMaxWid:sRect.size.width-30];
        if (spA == nil || [spA count] == 0) {
            [MBProgressHUD imShowError:@"未输入有效内容" toView:self.textView];
            //[MBProgressHUD imShowError:@"未输入有效内容"];
            return;
        }
        
        NSMutableString *content = [[NSMutableString alloc] init];
        
        
        for (int i = 0; i < [spA count]; i++) {
            [content appendString:[spA objectAtIndex:i]];
        }
        */
        
        WS(weakSelf);
        self.ifCanRrelease = NO;
        [[BJIMManager shareInstance] createGroupNotice:[self.im_group_Id longLongValue] content:self.textView.text callback:^(NSError *error) {
            if (error) {
                weakSelf.ifCanRrelease = YES;
                [MBProgressHUD imShowError:@"公告发布失败" toView:weakSelf.textView];
                //[MBProgressHUD imShowError:@"公告发布失败"];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length >= MAXCHARACTERCOUNT && text.length > range.length) {
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger surplusCount = 0;
    if (MAXCHARACTERCOUNT>textView.text.length) {
        surplusCount = MAXCHARACTERCOUNT-textView.text.length;
    }
    self.tipLable.text = [NSString stringWithFormat:@"剩余%d字",surplusCount];
    
}

@end

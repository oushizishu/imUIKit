//
//  GroupNameViewController.m
//
//  Created by wangziliang on 15/12/4.
//

#import "GroupNameViewController.h"

@interface GroupNameViewController()

@property (strong, nonatomic) NSString *im_group_id;
@property (strong, nonatomic) GroupDetail *groupDetail;
@property (strong, nonatomic) UIImageView *faceImageView;
@property (strong, nonatomic) UILabel *tipLable;
@property (strong, nonatomic) UITextField *nameTextField;

@end

@implementation GroupNameViewController

-(instancetype)initWithGroudId:(NSString*)groudId withGroupDetail:(GroupDetail*)groupDetail
{
    self = [super init];
    if (self) {
        self.groupDetail = groupDetail;
        self.im_group_id = groudId;
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
    
    self.title = @"群名称";
    
    CGRect sRect = [UIScreen mainScreen].bounds;
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    CGRect rectNav = self.navigationController.navigationBar.frame;
    
    self.faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake((sRect.size.width-100)/2, rectStatus.size.height+rectNav.size.height+40, 100, 100)];
    self.faceImageView.layer.masksToBounds = YES;
    self.faceImageView.backgroundColor = [UIColor grayColor];
    [self.faceImageView setAliyunImageWithURL:[NSURL URLWithString:self.groupDetail.avatar] placeholderImage:nil];
    [self.view addSubview:self.faceImageView];
    
    self.tipLable = [[UILabel alloc] initWithFrame:CGRectMake((sRect.size.width-100)/2, rectStatus.size.height+rectNav.size.height+150, 100, 20)];
    self.tipLable.backgroundColor = [UIColor clearColor];
    self.tipLable.font = [UIFont systemFontOfSize:14.0f];
    self.tipLable.text = @"点击换头像";
    self.tipLable.textColor = [UIColor grayColor];
    self.tipLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.tipLable];
    
    UIView *textfieldBackView = [[UIView alloc] initWithFrame:CGRectMake(0, rectStatus.size.height+rectNav.size.height+200, sRect.size.width, 60)];
    textfieldBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textfieldBackView];
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, textfieldBackView.frame.size.width-30, textfieldBackView.frame.size.height)];
    self.nameTextField.backgroundColor = [UIColor clearColor];
    self.nameTextField.text = self.groupDetail.group_name;
    [textfieldBackView addSubview:self.nameTextField];
    
    User *owner = [IMEnvironment shareInstance].owner;
    if (owner.userId != self.groupDetail.user_id || owner.userRole != self.groupDetail.user_role) {
        self.nameTextField.userInteractionEnabled = NO;
    }else
    {
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    
}

- (void)saveAction
{
    
}

- (void)backAction:(id)aciton
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

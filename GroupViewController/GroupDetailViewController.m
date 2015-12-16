//
//  GroupDetailViewController.m
//
//  Created by wangziliang on 15/11/27.
//

#import "GroupDetailViewController.h"
#import "CustomTableView.h"
#import "Group+ViewModel.h"
#import "MBProgressHUD+IMKit.h"
#import "IMDefaultCellMode.h"
#import "GroupAnnouncementViewController.h"
#import "UIColor+Util.h"
#import "GroupFileViewController.h"
#import "IMAnnouncementCellMode.h"
#import "IMGroupMembersCellMode.h"
#import "IMGroupTeachersCellMode.h"
#import "GroupMemberListViewController.h"
#import "GroupNameViewController.h"
#import "IMActionSheet.h"
#import "MBProgressHUD+IMKit.h"
#import <BJHL-IM-iOS-SDK/BJIMManager.h>

@interface GroupDetailViewController()<IMGroupManagerResultDelegate,IMGroupProfileChangedDelegate,CustomTableViewControllerDelegate>

@property (strong, nonatomic) NSString *im_group_id;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) GroupDetail *groupDetail;
@property (strong, nonatomic) CustomTableViewController *customTableViewController;

@property (strong, nonatomic) IMDefaultCellMode *groupAnnouncementMode;
@property (strong, nonatomic) IMAnnouncementCellMode *announcementMode;
@property (strong, nonatomic) IMDefaultCellMode *groupFileMode;
@property (strong, nonatomic) IMGroupMembersCellMode *groupMembersMode;
@property (strong, nonatomic) IMDefaultCellMode *groupNameMode;

@property (strong, nonatomic) IMDefaultCellMode *groupSourceCourse;
@property (strong, nonatomic) IMDefaultCellMode *groupSourceCourse_arrange;
@property (strong, nonatomic) IMDefaultCellMode *groupSourceMajor_teacher;
@property (strong, nonatomic) IMGroupTeachersCellMode *groupSourceTeachers;

@property (strong, nonatomic) IMDefaultCellMode *groupSettingMode;

@property (strong, nonatomic) UIButton *exitBtn;

@end

@implementation GroupDetailViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

-(instancetype)initWithGroudId:(NSString*)groudId
{
    self =[self init];
    if (self) {
        self.im_group_id = groudId;
    }
    return self;
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
    
    [[BJIMManager shareInstance] addGroupManagerDelegate:self];
    [[BJIMManager shareInstance] getGroupProfile:[_im_group_id longLongValue]];
    self.group = [[BJIMManager shareInstance] getGroup:[_im_group_id longLongValue]];
    if (self.group) {
        self.title = self.group.getContactName;
    }
    
    [self requestGroupDetails];
}

- (void)backAction:(id)aciton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)requestGroupDetails
{
    WS(weakself);
    [MBProgressHUD imShowLoading:@"正在获取群组详情..." toView:self.view];
    [[BJIMManager shareInstance] getGroupDetail:[self.im_group_id longLongValue] callback:^(NSError *error, GroupDetail *groupDetail) {
        if (error) {
            [MBProgressHUD imShowMessageThenHide:@"获取失败" toView:self.view];
        }else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            weakself.groupDetail = groupDetail;
            [weakself refreshGroupDetails];
        }
    }];
}

- (void)refreshGroupDetails
{
    
    NSMutableArray *sectionModeArray = [[NSMutableArray alloc] init];
    
    //群公告
    SectionMode *sMode = [[SectionMode alloc] init];
    sMode.headerHeight = 15;
    self.groupAnnouncementMode = [[IMDefaultCellMode alloc] init];
    self.groupAnnouncementMode.title = @"群公告";
    if (self.groupDetail.notice == nil) {
        self.groupAnnouncementMode.value = @"未设置";
    }
    self.groupAnnouncementMode.arrowType = CellArrowType_ToRigth;
    [sMode addRows:[NSArray arrayWithObjects:self.groupAnnouncementMode, nil]];
    
    if (self.groupDetail.notice != nil) {
        self.announcementMode = [[IMAnnouncementCellMode alloc] init];
        self.announcementMode.groupNotice = self.groupDetail.notice;
        [sMode addRows:[NSArray arrayWithObjects:self.announcementMode, nil]];
    }
    [sectionModeArray addObject:sMode];
    
    //群名称
    sMode = [[SectionMode alloc] init];
    sMode.headerHeight = 15;
    self.groupFileMode = [[IMDefaultCellMode alloc] init];
    self.groupFileMode.title = @"群文件";
    self.groupFileMode.arrowType = CellArrowType_ToRigth;
    [sMode setRows:[NSArray arrayWithObjects:self.groupFileMode, nil]];
    [sectionModeArray addObject:sMode];
    
    //群成员
    sMode = [[SectionMode alloc] init];
    sMode.headerHeight = 45;
    sMode.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
    sMode.headerView.backgroundColor = [UIColor colorWithHexString:@"#ebeced"];
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, sMode.headerView.frame.size.width, 30)];
    hView.backgroundColor = [UIColor whiteColor];
    [sMode.headerView addSubview:hView];
    UILabel *groupL = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 100, 20)];
    groupL.text = @"群成员";
    groupL.textColor = [UIColor grayColor];
    groupL.font = [UIFont systemFontOfSize:14.0f];
    groupL.textAlignment = NSTextAlignmentLeft;
    [hView addSubview:groupL];
    self.groupMembersMode = [[IMGroupMembersCellMode alloc] init];
    self.groupMembersMode.memberArray = self.groupDetail.member_list;
    [sMode setRows:[NSArray arrayWithObjects:self.groupMembersMode, nil]];
    [sectionModeArray addObject:sMode];
    
    //群名称
    sMode = [[SectionMode alloc] init];
    sMode.headerHeight = 45;
    sMode.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
    sMode.headerView.backgroundColor = [UIColor colorWithHexString:@"#ebeced"];
    hView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, sMode.headerView.frame.size.width, 30)];
    hView.backgroundColor = [UIColor whiteColor];
    [sMode.headerView addSubview:hView];
    groupL = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 100, 20)];
    groupL.text = @"群名称";
    groupL.textColor = [UIColor grayColor];
    groupL.font = [UIFont systemFontOfSize:14.0f];
    groupL.textAlignment = NSTextAlignmentLeft;
    [hView addSubview:groupL];
    self.groupNameMode = [[IMDefaultCellMode alloc] init];
    self.groupNameMode.imageUrl = [NSURL URLWithString:self.groupDetail.avatar];
    self.groupNameMode.title = self.groupDetail.group_name;
    self.groupNameMode.arrowType = CellArrowType_ToRigth;
    [sMode setRows:[NSArray arrayWithObjects:self.groupNameMode, nil]];
    [sectionModeArray addObject:sMode];
    
    //群来源
    if (self.groupDetail.group_source != nil) {
        sMode = [[SectionMode alloc] init];
        sMode.headerHeight = 45;
        sMode.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
        sMode.headerView.backgroundColor = [UIColor colorWithHexString:@"#ebeced"];
        hView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, sMode.headerView.frame.size.width, 30)];
        hView.backgroundColor = [UIColor whiteColor];
        [sMode.headerView addSubview:hView];
        groupL = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 100, 20)];
        groupL.text = @"群来源";
        groupL.textColor = [UIColor grayColor];
        groupL.font = [UIFont systemFontOfSize:14.0f];
        groupL.textAlignment = NSTextAlignmentLeft;
        [hView addSubview:groupL];
        
        self.groupSourceCourse = [[IMDefaultCellMode alloc] init];
        self.groupSourceCourse.title = @"课程";
        self.groupSourceCourse.value = self.groupDetail.group_source.course;
        self.groupSourceCourse.ifShowLine = YES;
        self.groupSourceCourse.arrowType = CellArrowType_ToRigth;
        
        self.groupSourceCourse_arrange = [[IMDefaultCellMode alloc] init];
        self.groupSourceCourse_arrange.title = @"课程安排";
        self.groupSourceCourse_arrange.value = self.groupDetail.group_source.course_arrange;
        self.groupSourceCourse_arrange.ifShowLine = YES;
        self.groupSourceCourse_arrange.arrowType = CellArrowType_ToRigth;
        
        [sMode setRows:[NSArray arrayWithObjects:self.groupSourceCourse,self.groupSourceCourse_arrange, nil]];
        
        if (self.groupDetail.group_source.major_teacher_list != nil && [self.groupDetail.group_source.major_teacher_list count] > 0) {
            self.groupSourceMajor_teacher = [[IMDefaultCellMode alloc] init];
            self.groupSourceMajor_teacher.title = @"主讲老师";
            NSMutableString *teacherName = [[NSMutableString alloc] init];
            for (int i = 0; i < [self.groupDetail.group_source.major_teacher_list count]; i++) {
                GroupTeacher *teacher = [self.groupDetail.group_source.major_teacher_list objectAtIndex:i];
                [teacherName appendString:teacher.user_name];
                [teacherName appendString:@" "];
            }
            self.groupSourceMajor_teacher.value = teacherName;
            self.groupSourceMajor_teacher.ifShowLine = YES;
            self.groupSourceMajor_teacher.arrowType = CellArrowType_ToBottom;
            
            [sMode addRows:[NSArray arrayWithObjects:self.groupSourceMajor_teacher, nil]];
        }
        
        [sectionModeArray addObject:sMode];

    }
    
    
    //小心接收设置
    sMode = [[SectionMode alloc] init];
    sMode.headerHeight = 15;
    self.groupSettingMode = [[IMDefaultCellMode alloc] init];
    self.groupSettingMode.title = @"消息接收设置";
    self.groupSettingMode.arrowType = CellArrowType_ToRigth;
    [sMode setRows:[NSArray arrayWithObjects:self.groupSettingMode, nil]];
    [sectionModeArray addObject:sMode];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    footerView.backgroundColor = [UIColor clearColor];
    
    self.exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width-30, 50)];
    User *owner = [IMEnvironment shareInstance].owner;
    if (owner.userId == self.groupDetail.user_id && owner.userRole == self.groupDetail.user_role) {
        [self.exitBtn setTitle:@"退出并解散群组" forState:UIControlStateNormal];
    }else
    {
        [self.exitBtn setTitle:@"退出群组" forState:UIControlStateNormal];
    }
    [self.exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.exitBtn setBackgroundColor:[UIColor colorWithHexString:@"#f95e5e"]];
    [self.exitBtn addTarget:self action:@selector(hitExitBtn) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:self.exitBtn];
    
    self.customTableViewController.tableFooterView = footerView;
    
    [self.customTableViewController setSections:sectionModeArray];
}

- (void)hitExitBtn
{
    //WS(weakSelf);
    User *owner = [IMEnvironment shareInstance].owner;
    if (owner.userId == self.groupDetail.user_id && owner.userRole == self.groupDetail.user_role) {
        
        [[BJIMManager shareInstance] disbandGroupWithGroupId:[self.im_group_id longLongValue]];
        [self backAction:nil];
        /*
        [[BJIMManager shareInstance] postDisBandGroup:[self.im_group_id longLongValue] callback:^(NSError *err) {
            if (err) {
                [MBProgressHUD imShowError:@"解散失败" toView:weakSelf.view];
            }else
            {
                [weakSelf backAction:nil];
            }
        }];
         */
    }else
    {
        [[BJIMManager shareInstance] leaveGroupWithGroupId:[self.im_group_id longLongValue]];
        [self backAction:nil];
        /*
        [[BJIMManager shareInstance] postLeaveGroup:[self.im_group_id longLongValue] callback:^(NSError *err) {
            if (err) {
                [MBProgressHUD imShowError:@"退出失败" toView:weakSelf.view];
            }else
            {
                [weakSelf backAction:nil];
            }
        }];
         */
    }
}


- (void)didGroupProfileChanged:(Group *)group
{
    
}

- (void)userHitCellMode:(BaseCellMode *)cellMode
{
    if (cellMode == self.groupAnnouncementMode || cellMode == self.announcementMode) {
        GroupAnnouncementViewController *groupAnnouncement = [[GroupAnnouncementViewController alloc] initWithGroudId:self.im_group_id];
        [self.navigationController pushViewController:groupAnnouncement animated:YES];
    }else if (cellMode == self.groupFileMode)
    {
        GroupFileViewController *groupFile = [[GroupFileViewController alloc] initWithGroudId:self.im_group_id];
        
        [self.navigationController pushViewController:groupFile animated:YES];
    }else if (cellMode == self.groupMembersMode)
    {
        GroupMemberListViewController *memberListViewController = [[GroupMemberListViewController alloc] initWithGroudId:self.im_group_id];
        [self.navigationController pushViewController:memberListViewController animated:YES];
    }else if (cellMode == self.groupNameMode)
    {
        GroupNameViewController *groupName = [[GroupNameViewController alloc] initWithGroudId:self.im_group_id withGroupDetail:self.groupDetail];
        [self.navigationController pushViewController:groupName animated:YES];
        
    }else if (cellMode == self.groupSourceCourse)
    {
        
    }else if (cellMode == self.groupSourceCourse_arrange)
    {
        
    }else if (cellMode == self.groupSourceMajor_teacher)
    {
        if (self.groupSourceMajor_teacher.arrowType == CellArrowType_ToUp) {
            [self.groupSourceMajor_teacher setDefaultArrowType:CellArrowType_ToBottom];
            NSMutableString *teacherName = [[NSMutableString alloc] init];
            for (int i = 0; i < [self.groupDetail.group_source.major_teacher_list count]; i++) {
                GroupTeacher *teacher = [self.groupDetail.group_source.major_teacher_list objectAtIndex:i];
                [teacherName appendString:teacher.user_name];
                [teacherName appendString:@" "];
            }
            [self.groupSourceMajor_teacher setDefaultValue:teacherName];
            if (self.groupSourceTeachers != nil) {
                SectionMode *sMode = self.groupSourceMajor_teacher.sectionMode;
                [sMode removeRows:[NSArray arrayWithObjects:self.groupSourceTeachers, nil]];
            }
            
        }else if(self.groupSourceMajor_teacher.arrowType == CellArrowType_ToBottom)
        {
            [self.groupSourceMajor_teacher setDefaultArrowType:CellArrowType_ToUp];
            [self.groupSourceMajor_teacher setDefaultValue:nil];
            SectionMode *sMode = self.groupSourceMajor_teacher.sectionMode;
            if (self.groupSourceTeachers == nil) {
                self.groupSourceTeachers = [[IMGroupTeachersCellMode alloc] init];
                self.groupSourceTeachers.teacherArray = self.groupDetail.group_source.major_teacher_list;
            }
            [sMode addRows:[NSArray arrayWithObjects:self.groupSourceTeachers, nil]];
        }
        
    }else if (cellMode == self.groupSettingMode)
    {
        WS(weakSelf);
        IMActionSheet  *actionSheet = [[IMActionSheet alloc] init];
        NSArray *array = [NSArray arrayWithObjects:@"接收所有消息并提醒",@"只接收老师消息",@"接收所有消息并不提醒",@"不接收此群消息", nil];
        NSInteger curIndex = (int)self.groupDetail.msg_status;
        [actionSheet showWithTitle:@"请选择消息接收方式" withArray:array withCurIndex:curIndex withSelectBlock:^(NSInteger index){
            if (index >= 0 && index <= 3 && curIndex != index) {
                [weakSelf setGroupMsgStatus:index];
            }
        } withCancelBlock:^{
            
        }];
    }
}

- (void)userScrollBottom
{
    
}

- (void)setGroupMsgStatus:(NSInteger)index
{
    WS(weakSelf);
    [[BJIMManager shareInstance] setGroupMsgStatus:index groupId:[self.im_group_id longLongValue] callback:^(NSError *error) {
        if (error) {
            [MBProgressHUD imShowError:@"设置失败" toView:weakSelf.view];
        }else
        {
            weakSelf.groupDetail.msg_status = index;
        }
    }];
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

@end

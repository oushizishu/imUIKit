//
//  GroupMemberListViewController.m
//
//  Created by wangziliang on 15/12/4.
//

#import "GroupMemberListViewController.h"
#import "CustomTableView.h"
#import "MBProgressHUD+IMKit.h"
#import "IMGroupUserCellMode.h"
#import "IMLinshiTool.h"
#import <BJHL-IM-iOS-SDK/BJIMManager.h>
#import "IMDialog.h"

@interface GroupMemberListViewController()<CustomTableViewControllerDelegate,IMGroupUserCellModeDelegate>

@property (strong, nonatomic) NSString *im_group_id;
@property (strong ,nonatomic) CustomTableViewController *customTableViewController;

@property (strong ,nonatomic) NSMutableArray<IMGroupUserCellMode *> *groupUserArray;

@property (assign ,nonatomic)NSInteger pageIndex;
@property (nonatomic) BOOL ifGroup;

@property (strong ,nonatomic) NSArray<SectionMode *> *sectionModeArray;
@property (strong ,nonatomic) NSArray<NSString *> *sectionTitleArray;
@property (nonatomic) NSInteger offset;
@property (nonatomic) BOOL hasMore;
@property (nonatomic) BOOL isAdmin;
@property (nonatomic) BOOL isMajor;

@end

@implementation GroupMemberListViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

-(instancetype)initWithGroudId:(NSString*)groudId
{
    self =[self init];
    if (self) {
        self.im_group_id = groudId;
        self.pageIndex = 1;
        self.offset = 0;
        self.ifGroup = NO;
        self.hasMore = NO;
        self.isAdmin = NO;
        self.isMajor = NO;
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
    
    self.title = @"群成员";
    
    [self requestGroupMembers];
    
}

- (void)requestGroupMembers
{
    WS(weakself);
    [MBProgressHUD imShowLoading:@"正在获取群组详情..." toView:self.view];
    [[BJIMManager shareInstance] getGroupMembers:[self.im_group_id longLongValue] page:self.pageIndex pageSize:100 callback:^(NSError *error, NSArray *members, BOOL hasMore,BOOL is_admin,BOOL is_major) {
        if (error) {
            [MBProgressHUD imShowMessageThenHide:@"获取失败" toView:weakself.view];
        }else
        {
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            weakself.pageIndex++;
            weakself.isAdmin = is_admin;
            weakself.isMajor = is_major;
            weakself.hasMore = hasMore;
            
            if (hasMore) {
                weakself.ifGroup = NO;
            }else
            {
                weakself.ifGroup = YES;
            }
            
            [weakself appendMoreMembers:members];
        }
    }];

}

- (void)refreshGroupMembers
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 处理耗时操作的代码块...
        NSArray *tmpTeacherArray = self.groupUserArray;
        
        NSMutableArray *sectionTitles = [NSMutableArray array];
        //建立索引的核心, 返回27，是a－z和＃
        UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
        [sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
        
        NSInteger highSection = [sectionTitles count];
        NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
        for (int i = 0; i < highSection; i++) {
            NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
            [sortedArray addObject:sectionArray];
        }
        
        NSMutableArray *managerArray = [[NSMutableArray alloc] init];
        //按首字母分组
        for (IMGroupUserCellMode *model in tmpTeacherArray) {
            if (model.GroupDetailMember.is_major == 1) {
                [managerArray insertObject:model atIndex:0];
                continue;
            }else if(model.GroupDetailMember.is_admin == 1)
            {
                [managerArray addObject:model];
                continue;
            }
            NSString *firstLetter = [IMLinshiTool pinyinFromChineseString:model.GroupDetailMember.user_name];
            if (firstLetter && firstLetter.length > 1)
            {
                NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
                
                NSMutableArray *array = [sortedArray objectAtIndex:section];
                [array addObject:model];
            }
        }
        
        //每个section内的数组排序
        for (int i = 0; i < [sortedArray count]; i++) {
            NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(IMGroupUserCellMode *obj1, IMGroupUserCellMode *obj2) {
                NSString *firstLetter1 = [IMLinshiTool pinyinFromChineseString:obj1.GroupDetailMember.user_name];
                firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
                
                NSString *firstLetter2 = [IMLinshiTool pinyinFromChineseString:obj2.GroupDetailMember.user_name];
                firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
                
                return [firstLetter1 caseInsensitiveCompare:firstLetter2];
            }];
            
            
            [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
        }
        
        //去掉空的section
        for (NSInteger i = [sortedArray count] - 1; i >= 0; i--) {
            NSArray *array = [sortedArray objectAtIndex:i];
            if ([array count] == 0) {
                [sortedArray removeObjectAtIndex:i];
                [sectionTitles removeObjectAtIndex:i];
            }
        }
        
        NSMutableArray *sectionTitleArray = [[NSMutableArray alloc] init];
        NSMutableArray *sectionModeArray = [[NSMutableArray alloc] init];
        if ([managerArray count] > 0) {
            SectionMode *sMode = [[SectionMode alloc] init];
            sMode.headerHeight = 0.0f;
            [sMode setRows:managerArray];
            [sectionModeArray addObject:sMode];
            [sectionTitleArray addObject:@"☆"];
        }
        
        for (int i = 0; i < [sortedArray count]; i++) {
            NSArray *array = [sortedArray objectAtIndex:i];
            NSString *title = [sectionTitles objectAtIndex:i];
            SectionMode *sMode = [[SectionMode alloc] init];
            
            sMode.headerHeight = 33.0f;
            sMode.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
            sMode.headerView.backgroundColor = [UIColor colorWithHexString:@"#ebeced"];
            UILabel *showTitleL = [[UILabel alloc] initWithFrame:CGRectMake(15, 9, 100, 15)];
            showTitleL.backgroundColor = [UIColor clearColor];
            showTitleL.textAlignment = NSTextAlignmentLeft;
            showTitleL.font = [UIFont systemFontOfSize:12.0f];
            showTitleL.tintColor = [UIColor grayColor];
            showTitleL.text = title;
            [sMode.headerView addSubview:showTitleL];
            
            [sMode setRows:array];
            [sectionModeArray addObject:sMode];
        }
        
        [sectionTitleArray addObjectsFromArray:sectionTitles];
        
        self.sectionTitleArray = sectionTitleArray;
        self.sectionModeArray = sectionModeArray;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.customTableViewController.sectionTitles = self.sectionTitleArray;
            [self.customTableViewController setSections:self.sectionModeArray];
        });
    });
}

- (void)appendMoreMembers:(NSArray<GroupDetailMember *> *)array
{
    if (self.groupUserArray == nil) {
        self.groupUserArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [array count];  i++) {
        IMGroupUserCellMode *cellMode = [[IMGroupUserCellMode alloc] initWithGroupDetailMember:[array objectAtIndex:i]];
        cellMode.groupUserDelegate = self;
        cellMode.operaterIsAdmin = self.isAdmin;
        cellMode.operaterIsMajor = self.isMajor;
        [self.groupUserArray addObject:cellMode];
    }
    if (self.hasMore) {
        NSMutableArray<SectionMode *> *sectionModeArray = [[NSMutableArray alloc] init];
        for (int i = 0; [self.groupUserArray count]; i++) {
            SectionMode *sMode = [[SectionMode alloc] init];
            sMode.headerHeight = 15.0f;
            [sectionModeArray addObject:sMode];
        }
        [self.customTableViewController addSections:sectionModeArray];
    }else
    {
        [self refreshGroupMembers];
    }
}

- (void)backAction:(id)aciton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userHitCellMode:(BaseCellMode *)cellMode
{
    
}

- (void)userScrollBottom
{
    if (self.hasMore) {
        [self requestGroupMembers];
    }
}

- (void)setGroupUserAdmin:(IMGroupUserCellMode *)cellMode
{
    WS(weakSelf);
    [[BJIMManager shareInstance] setGroupAdmin:[self.im_group_id longLongValue] user_number:cellMode.GroupDetailMember.user_number user_role:cellMode.GroupDetailMember.user_role status:1 callback:^(NSError *error) {
        if (error) {
            [MBProgressHUD imShowError:@"设置失败" toView:weakSelf.view];
        }else
        {
            weakSelf.pageIndex = 1;
            [weakSelf.groupUserArray removeAllObjects];
            [weakSelf requestGroupMembers];
        }
    }];
}

- (void)cancelGroupUserAmin:(IMGroupUserCellMode *)cellMode
{
    WS(weakSelf);
    [[BJIMManager shareInstance] setGroupAdmin:[self.im_group_id longLongValue] user_number:cellMode.GroupDetailMember.user_number user_role:cellMode.GroupDetailMember.user_role status:0 callback:^(NSError *error) {
        if (error) {
            [MBProgressHUD imShowError:@"设置失败" toView:self.view];
        }else
        {
            weakSelf.pageIndex = 1;
            [weakSelf.groupUserArray removeAllObjects];
            [weakSelf requestGroupMembers];
        }
    }];
}

- (void)tranferGroupUser:(IMGroupUserCellMode *)cellMode
{
    WS(weakSelf);
    [[BJIMManager shareInstance] transferGroup:[self.im_group_id longLongValue] transfer_id:cellMode.GroupDetailMember.user_number transfer_role:cellMode.GroupDetailMember.user_role callback:^(NSError *error) {
        if (error) {
            [MBProgressHUD imShowError:@"移交失败" toView:self.view];
        }else
        {
            weakSelf.pageIndex = 1;
            [weakSelf.groupUserArray removeAllObjects];
            [weakSelf requestGroupMembers];
        }
    }];
}

- (void)removeGroupUser:(IMGroupUserCellMode *)cellMode
{
    IMDialog *dialog = [[IMDialog alloc] init];
    
    WS(weakSelf);
    
    [dialog showWithContent:@"是否移除该成员" withSelectBlock:^{
        [[BJIMManager shareInstance] removeGroupMember:[self.im_group_id longLongValue] user_number:cellMode.GroupDetailMember.user_number user_role:cellMode.GroupDetailMember.user_role callback:^(NSError *error) {
            if (error) {
                [MBProgressHUD imShowError:@"移除失败" toView:self.view];
            }else
            {
                weakSelf.pageIndex = 1;
                [weakSelf.groupUserArray removeAllObjects];
                [weakSelf requestGroupMembers];

            }
        }];
    } withCancelBlock:^{
        
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

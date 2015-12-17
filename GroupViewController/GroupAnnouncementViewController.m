//
//  GroupAnnouncementViewController.m
//
//  Created by wangziliang on 15/12/1.
//

#import "GroupAnnouncementViewController.h"
#import "CustomTableView.h"
#import "IMAnnouncementCellMode.h"
#import "ReleaseAnnouncementViewController.h"
#import "UIColor+Util.h"
#import <BJHL-IM-iOS-SDK/BJIMManager.h>
#import "MBProgressHUD+IMKit.h"
#import "IMLinshiTool.h"

@interface GroupAnnouncementViewController()<CustomTableViewControllerDelegate>

@property (strong, nonatomic) CustomTableViewController *customTableViewController;

@property (strong, nonatomic) UIView *noHaveNoticeView;
@property (strong, nonatomic) UIImageView *noNoticeImageView;
@property (strong, nonatomic) UILabel *noNoticeTip;
@property (strong, nonatomic) UIButton *releaseBtn;
@property (strong, nonatomic) UIBarButtonItem *rightBarButtonItem;

@property (strong, nonatomic) NSString *im_group_id;
@property (nonatomic) BOOL isAdmin;
@property (strong, nonatomic) NSMutableArray<IMAnnouncementCellMode *> *announcementArray;
@property (nonatomic) BOOL ifCanLoadMore;
@end

@implementation GroupAnnouncementViewController

-(instancetype)initWithGroudId:(NSString*)groudId
{
    self = [super init];
    if (self) {
        self.im_group_id = groudId;
        self.isAdmin = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.customTableViewController setSections:nil];
    [self.announcementArray removeAllObjects];
    [self requestGroupAnnouncements];
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
    
    self.title = @"群公告";
}

- (void)creatAnnouncement
{
    ReleaseAnnouncementViewController *releaseAnn = [[ReleaseAnnouncementViewController alloc] initWithGroupId:self.im_group_id];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:releaseAnn];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)requestGroupAnnouncements
{
    WS(weakself);
    
    int64_t last_id = 0;
    if (self.announcementArray != nil && [self.announcementArray count]>0) {
        IMAnnouncementCellMode *lastAnnounecmentMode = [self.announcementArray lastObject];
        if (lastAnnounecmentMode.groupNotice != nil) {
            last_id = lastAnnounecmentMode.groupNotice.noticeId;
        }
    }
    
    [[BJIMManager shareInstance] getGroupNotice:[self.im_group_id longLongValue] last_id:last_id page_size:10 callback:^(NSError *error, BOOL isAdmin, NSArray<GroupNotice *> *list, BOOL hasMore) {
        if (error) {
            [MBProgressHUD imShowError:@"获取失败" toView:weakself.view];
        }else
        {
            weakself.isAdmin = isAdmin;
            weakself.ifCanLoadMore = hasMore;
            [weakself addGroupNotice:list];
        }
    }];
}

- (void)addGroupNotice:(NSArray<GroupNotice *> *)list
{
    if(list != nil && [list count] > 0)
    {
        NSMutableArray *sectionModeArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[list count]; i++) {
            SectionMode *seMode = [[SectionMode alloc] init];
            seMode.headerHeight = 15.0f;
            IMAnnouncementCellMode *announcementMode = [[IMAnnouncementCellMode alloc] initWithGroupNotice:[list objectAtIndex:i]];
            if (self.isAdmin) {
                announcementMode.ifCanDelete = YES;
            }
            [seMode addRows:[NSArray arrayWithObjects:announcementMode, nil]];
            [sectionModeArray addObject:seMode];
            [self.announcementArray addObject:announcementMode];
        }
        
        [self.customTableViewController addSections:sectionModeArray];
        
    }
    
    if ([self.announcementArray count]>0) {
        [self.noHaveNoticeView removeFromSuperview];
        [self.view addSubview:self.customTableViewController.view];
    }else
    {
        [self.customTableViewController.view removeFromSuperview];
        [self.view addSubview:self.noHaveNoticeView];
        if (self.isAdmin) {
            self.releaseBtn.hidden = NO;
        }else
        {
            self.releaseBtn.hidden = YES;
        }
    }
    
    if (self.isAdmin) {
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    }else
    {
        self.navigationItem.rightBarButtonItem = nil;
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
    if (self.ifCanLoadMore) {
        [self requestGroupAnnouncements];
    }
}


- (CustomTableViewController *)customTableViewController
{
    if (_customTableViewController == nil) {
        CGRect rectScreen = [UIScreen mainScreen].bounds;
        CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        CGRect rectNav = self.navigationController.navigationBar.frame;
        _customTableViewController = [[CustomTableViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, rectScreen.size.height-rectStatus.size.height-rectNav.size.height)];
        _customTableViewController.delegate = self;
    }
    return _customTableViewController;
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
        _noNoticeTip.text = @"还没发布任何群公告";
        _noNoticeTip.textColor = [UIColor colorWithHexString:IMCOLOT_GREY500];
        _noNoticeTip.textAlignment = NSTextAlignmentCenter;
        [_noHaveNoticeView addSubview:_noNoticeTip];
        
        _releaseBtn = [[UIButton alloc] initWithFrame:CGRectMake((_noHaveNoticeView.frame.size.width-120)/2, (_noHaveNoticeView.frame.size.height-175)/2+90+15+30, 120, 40)];
        _releaseBtn.backgroundColor = [UIColor colorWithHexString:@"#ff9100"];
        [_releaseBtn.layer setCornerRadius:2.0f];
        [_releaseBtn setTitle:@"发布公告" forState:UIControlStateNormal];
        [_releaseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_releaseBtn addTarget:self action:@selector(hitReleaseBtn) forControlEvents:UIControlEventTouchUpInside];
        [_noHaveNoticeView addSubview:_releaseBtn];
    }
    return _noHaveNoticeView;
}

- (void)hitReleaseBtn
{
    ReleaseAnnouncementViewController *releaseAnn = [[ReleaseAnnouncementViewController alloc] initWithGroupId:self.im_group_id];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:releaseAnn];
    [self presentViewController:nav animated:YES completion:nil];
}

-(UIBarButtonItem*)rightBarButtonItem
{
    if (_rightBarButtonItem == nil) {
        _rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_nav_edit"] style:UIBarButtonItemStylePlain target:self action:@selector(creatAnnouncement)];
    }
    return _rightBarButtonItem;
}

- (NSMutableArray<IMAnnouncementCellMode *> *)announcementArray
{
    if (_announcementArray == nil) {
        _announcementArray = [[NSMutableArray alloc] init];
    }
    return _announcementArray;
}

@end

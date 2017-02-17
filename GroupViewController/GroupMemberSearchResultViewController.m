//
//  GroupMemberSearchResultViewController.m
//  BJEducation
//
//  Created by Mac_ZL on 17/2/16.
//  Copyright © 2017年 com.bjhl. All rights reserved.
//

#import "GroupMemberSearchResultViewController.h"
#import "CustomTableViewController.h"
#import "IMGroupUserCellMode.h"


@interface GroupMemberSearchResultViewController ()<UISearchBarDelegate,CustomTableViewControllerDelegate,UIScrollViewDelegate>

@property (nonatomic,strong)UISearchBar *searchBar;
@property (nonatomic,strong)CustomTableViewController *customTableViewController;
@property (nonatomic,strong)NSMutableArray<IMGroupUserCellMode *> *groupUserArray;
@property (strong ,nonatomic) NSArray<SectionMode *> *sectionModeArray;

@end

@implementation GroupMemberSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.current_w, 64)];
    [self.view addSubview:bar];
    
    UIView *bgView = [[UIView alloc] init];
    [bgView setBackgroundColor:[UIColor colorWithWhite:0 alpha:.39]];
    [self.view addSubview:bgView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(8, 20, self.view.current_w-16, 44)];
    [_searchBar setPlaceholder:@"搜索"];
    [_searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor bj_gray_100]]];
    [_searchBar setDelegate:self];
    [_searchBar setTintColor:[UIColor bj_blue]];
    [_searchBar setShowsCancelButton:YES animated:NO];
    [bar addSubview:_searchBar];
//    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.and.right.and.bottom.equalTo(bar);
//    }];
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(self.view);
        make.top.equalTo(bar.mas_bottom);
    }];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.searchBar becomeFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)requestGroupMembers
{
//    WS(weakself);
//    [MBProgressHUD imShowLoading:@"正在获取群组详情..." toView:self.view];
    
    NSNumber *groupId = [NSNumber numberWithInt:79368];
    
    [[BJIMManager shareInstance] getGroupMembers:[groupId longLongValue] page:1 pageSize:100 callback:^(NSError *error, NSArray *members, BOOL hasMore,BOOL is_admin,BOOL is_major) {
        if (error) {
//            [MBProgressHUD imShowMessageThenHide:@"获取失败" toView:weakself.view];
        }else
        {
            
//            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
//            weakself.pageIndex++;
//
//            weakself.hasMore = hasMore;
            [self appendMoreMembers:members];
        }
    }];
    
}
- (void)appendMoreMembers:(NSArray<GroupDetailMember *> *)array
{
    if (self.groupUserArray == nil) {
        self.groupUserArray = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [array count];  i++) {
        IMGroupUserCellMode *cellMode = [[IMGroupUserCellMode alloc] initWithGroupDetailMember:[array objectAtIndex:i]];
        cellMode.groupUserDelegate = self;
        [self.groupUserArray addObject:cellMode];
    }
//    [self refreshGroupMembers];
    
    SectionMode *model = [[SectionMode alloc] init];
    [model setRows:self.groupUserArray];
    self.sectionModeArray = @[model];
    
    [self.customTableViewController setSections:self.sectionModeArray];

}
#pragma mark - Setter
- (CustomTableViewController *)customTableViewController
{
    if (_customTableViewController == nil)
    {
        _customTableViewController = [[CustomTableViewController alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.current_h-64)];
        _customTableViewController.delegate = self;
        
        [_customTableViewController.tableView setShowsVerticalScrollIndicator:YES];
        [self.view addSubview:self.customTableViewController.view];
    }
    return _customTableViewController;
}
#pragma mark UITableView Delegate
- (void)tableViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Search Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self requestGroupMembers];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if (_searchBarCancelBlock)
    {
        _searchBarCancelBlock();
    }
    [self.view removeFromSuperview];
    [self performSelector:@selector(navbarHiddenAnimate) withObject:nil afterDelay:0.01];
}
- (void)navbarHiddenAnimate
{
    [self.parentViewController.navigationController setNavigationBarHidden:NO animated:YES];

}
@end

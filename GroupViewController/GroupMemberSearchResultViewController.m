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
@property (nonatomic,strong) NSArray<SectionMode *> *sectionModeArray;
@property (nonatomic,assign) BOOL isHideKeyboard;


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
- (void)requestGroupMembers:(NSString *)query
{
    [[BJIMManager shareInstance] getSearchMemberList:self.groupId query:query callback:^(NSError *error, NSArray<GroupDetailMember *> *memberList) {
        if (!error)
        {
            [self appendMoreMembers:memberList];

        }
    }];
    
}
- (void)appendMoreMembers:(NSArray<GroupDetailMember *> *)array
{
    if (array.count == 0)
    {
        //
        [self.customTableViewController.view setHidden:YES];
    }
    else
    {
        [self.customTableViewController.view setHidden:NO];
        
        if (self.groupUserArray == nil) {
            self.groupUserArray = [[NSMutableArray alloc] init];
        }
        else
        {
            [self.groupUserArray removeAllObjects];
        }
        for (int i = 0; i < [array count];  i++) {
            IMGroupUserCellMode *cellMode = [[IMGroupUserCellMode alloc] initWithGroupDetailMember:[array objectAtIndex:i]];
            cellMode.groupUserDelegate = self;
            [self.groupUserArray addObject:cellMode];
        }
        
        SectionMode *model = [[SectionMode alloc] init];
        [model setRows:self.groupUserArray];
        self.sectionModeArray = @[model];
        
        [self.customTableViewController setSections:self.sectionModeArray];
    }
    [_customTableViewController.tableView setBackgroundColor:[UIColor whiteColor]];
    [_customTableViewController.tableView setShowsVerticalScrollIndicator:YES];

}
#pragma mark - Setter
- (CustomTableViewController *)customTableViewController
{
    if (_customTableViewController == nil)
    {
        _customTableViewController = [[CustomTableViewController alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.current_h-64)];
        _customTableViewController.delegate = self;
         [self.view addSubview:self.customTableViewController.view];
    }
    return _customTableViewController;
}
#pragma mark UITableView Delegate

- (void)tableViewDidScroll:(UIScrollView *)scrollView
{
    
//    [self.searchBar resignFirstResponder];
    [self resignFirstResponder];
}

#pragma mark - Search Delegate
- (BOOL)resignFirstResponder
{
    if (!_isHideKeyboard)
    {
        for (UIView *v in self.searchBar.subviews) {
            // Force the cancel button to stay enabled
            for (UIView *tmp in v.subviews)
            {
                // Dismiss the keyboard
                if ([tmp isKindOfClass:[UITextField class]]) {
                    [(UITextField *)tmp resignFirstResponder];
                }
                if ([tmp isKindOfClass:[UIControl class]]) {
                    ((UIControl *)tmp).enabled = YES;
                    
                }
                
            }
        }
        _isHideKeyboard = YES;
    }
    
    return YES;
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _isHideKeyboard = NO;
    return YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self requestGroupMembers:searchBar.text];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if (_searchBarCancelBlock)
    {
        _searchBarCancelBlock();
    }
    [self.view removeFromSuperview];
    
    //清空数据
    [self.groupUserArray removeAllObjects];
    SectionMode *model = [[SectionMode alloc] init];
    [model setRows:self.groupUserArray];
    self.sectionModeArray = @[model];
    [self.customTableViewController setSections:self.sectionModeArray];
    
    [self performSelector:@selector(navbarHiddenAnimate) withObject:nil afterDelay:0.01];
}
- (void)navbarHiddenAnimate
{
    [self.parentViewController.navigationController setNavigationBarHidden:NO animated:YES];

}
@end

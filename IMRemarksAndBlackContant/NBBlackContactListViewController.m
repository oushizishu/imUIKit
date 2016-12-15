//
//  NBBlackContactListViewController.m
//  BJEducation
//
//  Created by liujiaming on 16/12/10.
//  Copyright © 2016年 com.bjhl. All rights reserved.
//

#import "NBBlackContactListViewController.h"
#import "UIScrollView+BJTMJRefresh.h"
#import "ContanctorBlackListTableViewCell.h"
#import "MyChatViewController.h"
#import "SWTableViewCell.h"
#import "NoRecordView.h"

@interface NBBlackContactListViewController ()<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate>

@property (nonatomic,strong)NSArray * listArray;
@property (nonatomic,strong)UITableView * tableView;

@end

@implementation NBBlackContactListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的黑名单";
    self.listArray = [[NSArray alloc]init];
    [self setupBackBarButtonItem];
    [self setUpView];
}
- (void)setUpView
{
    [self.view addSubview:self.tableView];
}
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.current_w, self.view.current_h) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundView = nil;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        weakdef(self)
        [_tableView addHeaderWithCallback:^{
            strongdef(self)
            [self requestServer];
        }];
    }
    return _tableView;
}

- (void)requestServer
{
    weakifyself
    [[BJIMManager shareInstance] getBlackList:^(NSArray<User *> *blacklist) {
        strongifyself
        self.listArray = [NSArray arrayWithArray:blacklist];
        [self.tableView headerEndRefreshing];
        if (self.listArray.count == 0)
        {
            [NBErrorView showErrorViewInView:self.view inset:UIEdgeInsetsMake(64, 0, 0, 0)
                                       image:[UIImage imageNamed:@"ic_blankpage_wodeshengyuan"]
                                     message:@"暂无拉黑记录"
                                    callback:^(NBErrorView *errorView) {
                                        [self requestServer];
                                    }];
        }
        else
        {
            [self.tableView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContanctorBlackListTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"listCell"];
    if (!cell) {
        cell = [[ContanctorBlackListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"listCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    [cell setData:[self.listArray objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    long long userid = [(User *)_listArray[indexPath.row] userId];
    IMUserRole userRole = [(User *)_listArray[indexPath.row] userRole];
    MyChatViewController *chatVC = [[MyChatViewController alloc]initWithUserId:userid userRole:userRole];
    [self.navigationController pushViewController:chatVC animated:YES];
}
#pragma mark swtableviewcell delegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    ContanctorBlackListTableViewCell *currentCell = (ContanctorBlackListTableViewCell *)cell;
    User *user = currentCell.data;
    [self showLoading];
    [[BJIMManager shareInstance] removeBlackContactId:user.userId
                                          contactRole:user.userRole
                                             callback:^(BaseResponse *reponse) {
                                                 [self hideLoading];
                                                 if (reponse.code==0) {
                                                     [self showHUDWithText:@"移除黑名单成功" animated:YES];
                                                     [self requestServer];
                                                 }else{
                                                     [self showHUDWithText:reponse.msg animated:YES];
                                                 }
                                             }];
}

@end

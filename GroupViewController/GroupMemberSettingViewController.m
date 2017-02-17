//
//  GroupMemberSettingViewController.m
//  BJEducation
//
//  Created by Mac_ZL on 17/2/14.
//  Copyright © 2017年 com.bjhl. All rights reserved.
//

#import "GroupMemberSettingViewController.h"
#import <BJHL-IM-iOS-SDK/BJIMManager.h>
#import <BJHL-Foundation-iOS/BJHL-Foundation-iOS.h>
#import <BJHL-Kit-iOS/BJHL-Kit-iOS.h>
#import "GroupMemberSettingTableViewCell.h"
#import "MBProgressHUD+IMKit.h"


typedef enum : NSUInteger {
    ChatSection,//禁言信息
    AdminSection,//设为管理员
    SectionCount,
} TableViewSection;




@interface GroupMemberSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView * tableView;
@property (nonatomic,strong)NSMutableArray * dataArray;
@property (nonatomic,strong)UIView * headerView;
@property (nonatomic,strong)UIView * footerView;
@property (nonatomic,strong)UIButton * avtarBtn;
@property (nonatomic,strong)UIButton * sendMessageBtn;
@property (nonatomic,strong)UILabel * nameLabel;
@property (nonatomic,strong)UILabel * idLabel;
@property (nonatomic,strong)UILabel * nickNameLabel;
@property (nonatomic,strong)NSString *tagString;
@property (nonatomic,assign)BOOL isForbid;//设置禁言
@property (nonatomic,assign)BOOL isAdmin;//设置管理员
@property (nonatomic,strong)MemberProfile *memberProfile;



@end

@implementation GroupMemberSettingViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor bjck_colorWithHexString:@"#ebeced"];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 14, 22)];
    [backBtn setImage:[UIImage imageNamed:@"im_black_leftarrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemBar = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = itemBar;
    
    CGRect sRect = [UIScreen mainScreen].bounds;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sRect.size.width-160, 30)];
    label.font = [UIFont systemFontOfSize:18.0f];
    label.text = self.user.remarkName?:self.user.name;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    self.navigationItem.titleView = label;
    
    [self setUpView];
    
}

- (void)backAction:(id)aciton
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)setUpData
{
    [self dataArray];
}
- (void)setUpView
{
    [self setupBackBarButtonItem];
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.footerView];
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(-20);
    }];
    
    [[BJIMManager shareInstance] getGroupMemberProfile:self.groupId user_number:self.user.userId userRole:self.user.userRole callback:^(NSError *error, MemberProfile *memberProfile) {
        if (memberProfile)
        {
            self.memberProfile = memberProfile;
            [self.tableView reloadData];
        }
    }];
}
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.current_w, self.view.current_h) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundView = nil;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        
        [_tableView setTableHeaderView:self.headerView];
        
    }
    return _tableView;
}
- (UIView *)headerView
{
    if (!_headerView)
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.current_w,88)];
        [_headerView setBackgroundColor:[UIColor whiteColor]];
        UIImage *placeholderImage = [UIImage imageNamed:@"img_head_default"];
        
        _avtarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_avtarBtn.layer setCornerRadius:2];
        [_avtarBtn setClipsToBounds:YES];
        [_avtarBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:self.user.avatar] forState:UIControlStateNormal placeholderImage:placeholderImage];
        [_headerView addSubview:_avtarBtn];
        weakifyself;
        [_avtarBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^{
            strongifyself;
            NSString *string = [NSString stringWithFormat:@"%@/x/%lld",[BJDeployEnv sharedInstance].baseMAPIURLStr,self.user.userId];
            [[BJActionManager sharedManager] sendTotarget:self handleWithUrl:string];
        }];
        [_avtarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(15);
            make.width.mas_offset(60);
            make.height.mas_offset(60);
            make.top.mas_offset(19);
        }];
        
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:[UIFont systemFontOfSize:16]];
        
        [_nameLabel setTextColor:[UIColor bj_gray_600]];
        [_headerView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avtarBtn.mas_right).offset(15);
            
        }];
        NSString *remarkName = self.user.remarkName;
        [_nameLabel setText:remarkName.length>0?remarkName:self.user.name];
        
        _idLabel = [[UILabel alloc] init];
        [_idLabel setFont:[UIFont systemFontOfSize:13]];
        [_idLabel setTextColor:[UIColor bj_gray_500]];
        [_headerView addSubview:_idLabel];
        [_idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avtarBtn.mas_right).offset(15);
        }];
        [_idLabel setText:[NSString stringWithFormat:@"ID:%lld",self.user.userId]];
        
        _nickNameLabel = [[UILabel alloc] init];
        [_nickNameLabel setFont:[UIFont systemFontOfSize:13]];
        [_nickNameLabel setTextColor:[UIColor bj_gray_500]];
        [_headerView addSubview:_nickNameLabel];
        [_nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avtarBtn.mas_right).offset(15);
        }];
        [_nickNameLabel setText:[NSString stringWithFormat:@"昵称：%@",self.user.name]];
        
        NSArray *array = @[_nameLabel,_idLabel,_nickNameLabel];
        //        [array mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedItemLength:1 leadSpacing:20 tailSpacing:9];
        [array mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:5 leadSpacing:20 tailSpacing:9];
    }
    return _headerView;
}
- (UIView *)footerView
{
    if (!_footerView)
    {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.current_w,44)];
        
        _sendMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendMessageBtn setBackgroundImage:[UIImage imageWithColor:[UIColor bj_blue]] forState:UIControlStateNormal];
        [_sendMessageBtn setTitle:@"移除群聊" forState:UIControlStateNormal];
        [_sendMessageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendMessageBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [_sendMessageBtn addTarget:self action:@selector(removeGroup:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:_sendMessageBtn];
        [_sendMessageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(144);
            make.centerX.equalTo(_footerView);
            make.top.and.height.equalTo(_footerView);
        }];
        
    }
    return _footerView;
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        _dataArray = [[NSMutableArray alloc]initWithObjects:@{@"title":@[@"禁言"]},
                      @{@"title":@[@"设为管理员"]}, nil];
    }
    return _dataArray;
}

#pragma mark  - private


- (void)showAlertViewMessage:(NSString *)message CallBack:(void(^)(BOOL sure))callBack{
    TKAlertViewController * alert = [[TKAlertViewController alloc]initWithTitle:@"" message:message textAlignment:NSTextAlignmentLeft];
    [alert addCancelButtonWithTitle:@"取消" block:^(NSUInteger index) {
        !callBack?:callBack(NO);
    }];
    [alert addButtonWithTitle:@"确定" block:^(NSUInteger index) {
        !callBack?:callBack(YES);
        
    }];
    [alert setTitleColor:[UIColor colorWithHexString:@"37a4f5"] forButton:TKAlertViewButtonTypeDefault];
    [alert show];
}
#pragma mark  tableview delegate /datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionCount;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    switch (section)
    {
        case ChatSection:
            num = 1;
            break;
        case AdminSection:
            num = _isOwner?1:0;
            break;
        default:
            break;
    }
    return num;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupMemberSettingTableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"ContactorsCell"];
    if (!cell) {
        cell = [[GroupMemberSettingTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ContactorsCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor bj_gray_600];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.textColor = [UIColor bj_gray_400];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setClipsToBounds:YES];
        
        //line
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.view.current_w, 0.5)];
        lineView.backgroundColor = [UIColor bj_gray_200];
        lineView.tag = 100;
        [cell.contentView addSubview:lineView];
        lineView.hidden = YES;
    }
    UIView *view = [cell.contentView viewWithTag:100];
    if (indexPath.section==0&&indexPath.row==0) {
        view.hidden = NO;
    }else{
        view.hidden = YES;
    }
    [self customCell:cell ForIndexpath:indexPath];
    
    return cell;
}
- (void)customCell:(UITableViewCell *)cell ForIndexpath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case ChatSection:
        {
            cell.textLabel.text = @"禁言";
            
            UISwitch *switchControl =  [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
            switchControl.onTintColor = [UIColor colorWithHexString:@"#44db5e"];
            [switchControl addTarget:self action:@selector(setChat:) forControlEvents:UIControlEventValueChanged];
            
            
            
            cell.accessoryView = switchControl;
        }
            break;
        case AdminSection:
        {
            cell.textLabel.text = @"设为管理员";

            UISwitch *switchControl =  [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
            switchControl.onTintColor = [UIColor colorWithHexString:@"#44db5e"];
            [switchControl addTarget:self action:@selector(setAdmin:) forControlEvents:UIControlEventValueChanged];
            
            cell.accessoryView = switchControl;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Inter

#pragma mark - Fun
- (void)setChat:(UISwitch *)control
{
    GroupMemberSettingTableViewCell *cell = (GroupMemberSettingTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ChatSection]];
    if (cell)
    {
        [cell.detailTextLabel setText:control.isOn?@"已禁言":nil];
    }
    if (control.isOn != _isForbid) {
        _isForbid = control.isOn;
        [[BJIMManager shareInstance] setGroupMemberForbid:self.groupId user_number:self.user.userId user_role:self.user.userRole status:control.isOn?1:0 callback:^(NSError *error) {
            if (error) {
                [MBProgressHUD imShowError:@"设置失败" toView:self.view];
                _isForbid = !control.isOn;
                control.on = !control.isOn;
                [cell.detailTextLabel setText:control.isOn?@"已禁言":nil];
            }
        }];
    }
}

//设置管理员权限
- (void)setAdmin:(UISwitch *)control
{
    if (!control.isOn)
    {
        TKAlertViewController *alertVC = [[TKAlertViewController alloc] initWithTitle:@"取消管理员" message:@"确定取消该成员的管理权限吗？"];
        [alertVC addCancelButtonWithTitle:@"取消" block:^(NSUInteger index) {
            [control setOn:YES];
        }];
        [alertVC addButtonWithTitle:@"确定" block:^(NSUInteger index) {
            if (control.isOn != _isAdmin) {
                _isAdmin = control.isOn;
                [[BJIMManager shareInstance] setGroupAdmin:self.groupId user_number:self.user.userId user_role:self.user.userRole status:0 callback:^(NSError *error) {
                    if (error) {
                        [MBProgressHUD imShowError:@"设置失败" toView:self.view];
                        _isAdmin = !control.isOn;
                        control.on = !control.isOn;
                    }
                }];
            }

        }];
        [alertVC setTitleColor:[UIColor bj_blue] forButton:TKAlertViewButtonTypeDefault];
        [alertVC show];
    }
    else
    {
        //设置管理员
        if (control.isOn != _isAdmin) {
            _isAdmin = control.isOn;
            [[BJIMManager shareInstance] setGroupAdmin:self.groupId user_number:self.user.userId user_role:self.user.userRole status:1 callback:^(NSError *error) {
                if (error) {
                    [MBProgressHUD imShowError:@"设置失败" toView:self.view];
                    _isAdmin = !control.isOn;
                    control.on = !control.isOn;
                }
            }];
        }

    }
}
- (void)removeGroup:(UIButton *)sender
{
    TKAlertViewController *alertVC = [[TKAlertViewController alloc] initWithTitle:nil message:@"确定将该用户移出？"];
    [alertVC addCancelButtonWithTitle:@"取消" block:nil];
    [alertVC addButtonWithTitle:@"确定" block:^(NSUInteger index) {
        [[BJIMManager shareInstance] removeGroupMember:self.groupId user_number:self.user.userId user_role:self.user.userRole callback:^(NSError *error) {
            if (error) {
                [MBProgressHUD imShowError:@"移除失败" toView:self.view];
            }else
            {
                
            }
        }];
    }];
    [alertVC setTitleColor:[UIColor bj_blue] forButton:TKAlertViewButtonTypeDefault];
    [alertVC show];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

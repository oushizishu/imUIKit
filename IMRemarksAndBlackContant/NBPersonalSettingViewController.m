//
//  NBPersonalSettingViewController.m
//  BJEducation
//
//  Created by liujiaming on 16/11/22.
//  Copyright © 2016年 com.bjhl. All rights reserved.
//
NSString *const NBContactBlacklistNotification = @"NBContactBlacklistNotification";

#import "NBPersonalSettingViewController.h"
#import "NSString+utils.h"
#import "NBRemarkNameViewController.h"

typedef enum : NSUInteger {
    BaseInfoSection,//基础信息
    BlackSection,//加入黑名单
    SectionCount,
} TableViewSection;

typedef enum : NSUInteger {
    RemarkCell,//备注
    TagCell,//标签
    CategoryCell,//老师-主营科目
    BaseInfoSectionCellCount,
} BaseInfoSectionCell;

@interface NBPersonalSettingViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView * tableView;
@property (nonatomic,strong)NSMutableArray * dataArray;
@property (nonatomic,strong)UISwitch  * switchBtn;
@property (nonatomic,strong)UIView * headerView;
@property (nonatomic,strong)UIView * footerView;
@property (nonatomic,strong)UIButton * avtarBtn;
@property (nonatomic,strong)UIButton * sendMessageBtn;
@property (nonatomic,strong)UILabel * nameLabel;
@property (nonatomic,strong)UILabel * idLabel;
@property (nonatomic,strong)UILabel * nickNameLabel;
@property (nonatomic,strong)NSString *tagString;

@end

@implementation NBPersonalSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor bj_gray_100]];
    [self setUpData];
    [self setUpView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateTitle];
    [self requesetServer];
    [self.tableView reloadData];
}

#pragma  mark --- setup

- (void)updateTitle{
    NSString *remarkName = [NSString defaultString:[self.bjChatInfo getContactRemarkName] defaultValue:@""];
    NSString *name = [NSString defaultString:[self.bjChatInfo getToName] defaultValue:@""];
    self.title = (remarkName.length>0)?remarkName:name;
}

- (void)setUpData
{
    [self dataArray];
}
- (void)setUpView
{
    [self setupBackBarButtonItem];
    [self switchBtn];
    [self.view addSubview:self.tableView];
    
    if (![self isTeacher]) {
        [self.view addSubview:self.footerView];
        [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.height.mas_equalTo(44);
            make.bottom.mas_equalTo(-20);
        }];
    }
}
- (UITableView *)tableView
{
    CGFloat height = [self isTeacher]?64:0;
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.current_w, self.view.current_h-height) style:UITableViewStyleGrouped];
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
        [_avtarBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:self.bjChatInfo.chatToUser.avatar] forState:UIControlStateNormal placeholderImage:placeholderImage];
        [_headerView addSubview:_avtarBtn];
        weakifyself;
        [_avtarBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^{
            strongifyself;
            NSString *string = [NSString stringWithFormat:@"%@/x/%lld",[BJDeployEnv sharedInstance].baseMAPIURLStr,[self.bjChatInfo getToId]];
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
        NSString *remarkName = [NSString defaultString:[self.bjChatInfo getContactRemarkName] defaultValue:@""];
        [_nameLabel setText:remarkName.length>0?remarkName:[self.bjChatInfo getContactNickName]];
        
        _idLabel = [[UILabel alloc] init];
        [_idLabel setFont:[UIFont systemFontOfSize:13]];
        [_idLabel setTextColor:[UIColor bj_gray_500]];
        [_headerView addSubview:_idLabel];
        [_idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avtarBtn.mas_right).offset(15);
        }];
        [_idLabel setText:[NSString stringWithFormat:@"ID:%lld",[self.bjChatInfo getToId]]];
        
        _nickNameLabel = [[UILabel alloc] init];
        [_nickNameLabel setFont:[UIFont systemFontOfSize:13]];
        [_nickNameLabel setTextColor:[UIColor bj_gray_500]];
        [_headerView addSubview:_nickNameLabel];
        [_nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avtarBtn.mas_right).offset(15);
        }];
        [_nickNameLabel setText:[NSString stringWithFormat:@"昵称：%@",[self.bjChatInfo getContactNickName]]];
        
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
        [_sendMessageBtn setTitle:@"发消息" forState:UIControlStateNormal];
        [_sendMessageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendMessageBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [_footerView addSubview:_sendMessageBtn];
        [_sendMessageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.top.and.height.equalTo(_footerView);
        }];
        
    }
    return _footerView;
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        _dataArray = [[NSMutableArray alloc]initWithObjects:@{@"title":@[@"备注及描述",@"标签",@"主营科目"]},
                      @{@"title":@[@"加入黑名单"]}, nil];
    }
    return _dataArray;
}
- (UISwitch *)switchBtn
{
    if (!_switchBtn) {
        _switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _switchBtn.onTintColor = [UIColor colorWithHexString:@"#44db5e"];
        [_switchBtn addTarget:self action:@selector(switchBtnChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchBtn;
}
#pragma mark  - private

- (void)switchBtnChange:(UISwitch *)sender
{
    if (sender.on == YES) {
        [self showAlertViewMessage:@"加入黑名单后，该学生无法再向您发送消息，今后将不能购买您的课程。\n在 消息页面－右上角设置按钮－我的黑名单，可以找到被拉黑学生并解除拉黑状态。" CallBack:^(BOOL sure) {
            if (sure) {
                [MobClick event:@"20124"];
                [self addBlackContant];
            }else{
                self.switchBtn.on = NO;
            }
        }];
    }else{
        [self showAlertViewMessage:@"是否解除对该学生的黑名单屏蔽" CallBack:^(BOOL sure) {
            if (sure) {
                [self removeBlackContant];
            }else{
                self.switchBtn.on = YES;
            }
        }];
    }
}
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
- (void)addBlackContant
{
    weakdef(self)
    [[BJIMManager shareInstance]addBlackContactId:[self.bjChatInfo getToId]
                                      contactRole:[self.bjChatInfo getToRole]
                                         callback:^(BaseResponse *response) {
                                             strongdef(self)
                                             if (response.code==0) {
                                                 [self showHUDWithText:@"加入黑名单成功" animated:YES];
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:NBContactBlacklistNotification object:@(YES)];
                                             }else{
                                                 self.switchBtn.on=NO;
                                                 [self showHUDWithText:response.msg animated:YES];
                                             }
                                         }];
}
- (void)removeBlackContant
{
    [[BJIMManager shareInstance] removeBlackContactId:[self.bjChatInfo getToId]
                                          contactRole:[self.bjChatInfo getToRole]
                                             callback:^(BaseResponse *reponse) {
                                                 if (reponse.code==0) {
                                                     [self showHUDWithText:@"移除黑名单成功" animated:YES];
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:NBContactBlacklistNotification object:@(NO)];
                                                 }else{
                                                     self.switchBtn.on=YES;
                                                     [self showHUDWithText:reponse.msg animated:YES];
                                                 }
                                             }];
}
- (void)requesetServer
{
    weakifyself;
    NSDictionary *dic = @{@"student_user_number":[NSNumber numberWithLongLong:[self.bjChatInfo getToId]]};
    NBNetworkRequest *request = [[NBNetworkRequest alloc] initWithOwner:self urlPath:@"/v1/im/student_contact_detail" parameters:dic];
    request.requestType = QFNetworkRequestTypeGet;
    [request nb_startWithSuccessCallback:^(__kindof NBNetworkRequest * _Nonnull request, __kindof NBResponse * _Nonnull response, NBNetworkCallback  _Nullable failure) {
        strongifyself
        [self hideLoading];
        if (request.response.responseCode == NBRequestSucceeded)
        {
            self.tagString = [[request.response.responseData valueForKey:@"student"] valueForKey:@"prefer_string"];
            [self.tableView reloadData];
        }
    } failureCallback:^(__kindof NBNetworkRequest * _Nonnull request, __kindof NBResponse * _Nonnull response) {
        strongifyself
        [self hideLoading];
    }];
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
        case BaseInfoSection:
            num = BaseInfoSectionCellCount;
            break;
        case BlackSection:
            num = 1;
            break;
        default:
            break;
    }
    return num;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    switch (indexPath.section)
    {
        case BaseInfoSection:
        {
            height = [self heightForBaseInfoCell:indexPath];
        }
            break;
        case BlackSection:
        {
            height = [self heightForBlackCell:indexPath];
        }
            break;
        default:
            break;
    }
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"ContactorsCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ContactorsCell"];
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
    cell.textLabel.text = [[_dataArray[indexPath.section] objectForKey:@"title"] objectAtIndex:indexPath.row];
    
    switch (indexPath.section)
    {
        case BaseInfoSection:
        {
            switch (indexPath.row) {
                case RemarkCell:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    NSString *remarkName = [NSString defaultString:[self.bjChatInfo getContactRemarkName] defaultValue:@""];
                    [cell.detailTextLabel setText:remarkName.length>0?remarkName:@""];
                }
                    break;
                    case TagCell:
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    
                    if (self.tagString.length > 12)
                    {
                        self.tagString = [NSString stringWithFormat:@"%@...",[self.tagString substringToIndex:11]];
                    }
                    
                    [cell.detailTextLabel setText:self.tagString];
                }
                    break;
                case CategoryCell:
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    [cell.detailTextLabel setText:@"高中数学>高二>数学"];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            case BlackSection:
        {
            cell.accessoryView = _switchBtn;
            IMUserRelation relation = self.bjChatInfo.chatToUser.relation;
            if (relation==eUserRelation_normal) {
                _switchBtn.on=NO;
            }else{
                _switchBtn.on=YES;
            }
            [cell.detailTextLabel setText:nil];
        }
            break;
        default:
            break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==BaseInfoSection)
    {
        switch (indexPath.row)
        {
            case RemarkCell:
            {
                NBRemarkNameViewController *vc = [NBRemarkNameViewController new];
                vc.bjChatInfo = self.bjChatInfo;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
}
#pragma mark - Inter 
- (BOOL)isTeacher
{
    if ([self.bjChatInfo getToRole] == eUserRole_Teacher)
    {
        return YES;
    }
    return NO;
}
- (CGFloat)heightForBaseInfoCell:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    switch (indexPath.row)
    {
        case RemarkCell:
            height = [self isTeacher]?0:44;
            break;
        case TagCell:
            height = [self isTeacher]?0:44;
            break;
        case CategoryCell:
            height = [self isTeacher]?44:0;
            break;
        default:
            break;
    }
    return height;
}
- (CGFloat)heightForBlackCell:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    switch (indexPath.row)
    {
        case 0:
            height = [self isTeacher]?0:44;
            break;
        default:
            break;
    }
    return height;
}
@end

//
//  NBPersonalSettingViewController.m
//  BJEducation
//
//  Created by liujiaming on 16/11/22.
//  Copyright © 2016年 com.bjhl. All rights reserved.
//

#import "NBPersonalSettingViewController.h"
#import "NSString+utils.h"
#import "NBRemarkNameViewController.h"

@interface NBPersonalSettingViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView * tableView;
@property (nonatomic,strong)NSMutableArray * dataArray;
@property (nonatomic,strong)UISwitch  * switchBtn;

@end

@implementation NBPersonalSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
}
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.current_w, self.view.current_h) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundView = nil;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    }
    return _tableView;
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]initWithObjects:@{@"title":@[@"主页",@"备注"]},
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
                                                 }else{
                                                     self.switchBtn.on=YES;
                                                     [self showHUDWithText:reponse.msg animated:YES];
                                                 }
                                             }];
}
#pragma mark  tableview delegate /datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataArray[section] valueForKey:@"title"] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"ContactorsCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactorsCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor bj_gray_600];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        //line
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.view.current_w, 0.5)];
        lineView.backgroundColor = [UIColor bj_gray_200];
        lineView.tag = 100;
        [cell.contentView addSubview:lineView];
        lineView.hidden = YES;
        
        //remarkname
        UILabel * lable = [[UILabel alloc]init];
        lable.textColor = [UIColor bj_gray_400];
        lable.backgroundColor =[UIColor clearColor];
        lable.font = [UIFont systemFontOfSize:14];
        lable.tag = 1000;
        lable.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:lable];
        lable.hidden = YES;
    }
    UIView *view = [cell.contentView viewWithTag:100];
    if (indexPath.section==0&&indexPath.row==0) {
        view.hidden = NO;
    }else{
        view.hidden = YES;
    }
    cell.textLabel.text = [[_dataArray[indexPath.section] objectForKey:@"title"] objectAtIndex:indexPath.row];
    if (!(indexPath.section==_dataArray.count-1&&indexPath.row==0)) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryView = _switchBtn;
        IMUserRelation relation = self.bjChatInfo.chatToUser.relation;
        if (relation==eUserRelation_normal) {
            _switchBtn.on=NO;
        }else{
            _switchBtn.on=YES;
        }
    }
    
    UILabel * lable = (UILabel *)[cell.contentView viewWithTag:1000];
    CGSize size = [self.title stringSizeWithFont:[UIFont systemFontOfSize:14] size:CGSizeMake(200, 44)];
    [lable setFrame:CGRectMake(ScreenWidth-30-size.width, (44-size.height)/2, size.width, size.height)];
    NSString *remarkName = [NSString defaultString:[self.bjChatInfo getContactRemarkName] defaultValue:@""];
    lable.text = remarkName.length>0?remarkName:@"";
    if (indexPath.section==0&&indexPath.row==1) {
        lable.hidden = NO;
    }else{
        lable.hidden = YES;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            NSString *string = [NSString stringWithFormat:@"%@/x/%lld",[BJDeployEnv sharedInstance].baseMAPIURLStr,[self.bjChatInfo getToId]];
            [[BJActionManager sharedManager] sendTotarget:self handleWithUrl:string];
        }
        if (indexPath.row==1) {
            NBRemarkNameViewController *vc = [NBRemarkNameViewController new];
            vc.bjChatInfo = self.bjChatInfo;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
@end

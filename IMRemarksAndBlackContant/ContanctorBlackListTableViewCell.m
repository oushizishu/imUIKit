//
//  ContanctorBlackListTableViewCell.m
//  BJEducation_student
//
//  Created by liujiaming on 15/10/31.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "ContanctorBlackListTableViewCell.h"
#import "AsynImageView.h"

@implementation ContanctorBlackListTableViewCell
{
    UIImageView * _headImageView;
    UILabel * _name;
    UILabel * _detail;
    UIButton * _attentionButton;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatUI];
    }
    return self;
}
- (void)creatUI
{
    _headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 19/2, 45, 45)];
    _headImageView.layer.cornerRadius = 45/2.0;
    _headImageView.layer.masksToBounds = YES;
    [_headImageView setBackgroundColor:[UIColor bj_gray_200]];
    [self.contentView addSubview:_headImageView];
    
    _name = [[UILabel alloc]initWithFrame:CGRectMake(_headImageView.current_x_w+15, _headImageView.current_y+5, self.current_w-130, 15)];
    _name.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_name];
    
    _detail = [[UILabel alloc]initWithFrame:CGRectMake(_headImageView.current_x_w+15, _name.current_y_h+5, DEVICE_SCREEN_WIDTH-110, 15)];
    _detail.font =[UIFont systemFontOfSize:12];
    _detail.textColor = [UIColor bj_gray_400];
    [self.contentView addSubview:_detail];
    
    UIView * sepView = [[UIView alloc]initWithFrame:CGRectMake(_headImageView.current_x_w+15, 63.5, DEVICE_SCREEN_WIDTH-_headImageView.current_x_w-15, .5)];
    sepView.backgroundColor =[UIColor bj_gray_300];
    [self.contentView addSubview:sepView];
    
    UIButton * button = [UIButton new];
    [button setBackgroundColor:[UIColor bj_red]];
    [button setTitle:@"移出黑名单" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setRightUtilityButtons:@[button] WithButtonWidth:100];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
}
- (NSString *)getRoleStr:(NSInteger)role
{
    NSString *roleStr;
    switch (role)
    {
        case eUserRole_Teacher:
            roleStr = @"老师";
            break;
        case eUserRole_Student:
            roleStr = @"学生";
            break;
        case eUserRole_Institution:
            roleStr = @"机构";
            break;
        default:
            break;
    }
    return roleStr;
}

- (void)setData:(User *)data
{
    if (data) {
        _data = data;
        [self loadViewData];
    }
}

- (void)loadViewData
{
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:Maked0ImageUrl(_data.avatar,45,45)]];
    [_name setText:(_data.remarkName && ![_data.remarkName isEqualToString:@""])?_data.remarkName:_data.name];
    [_detail setText:[self getRoleStr:_data.userRole]];
}
@end

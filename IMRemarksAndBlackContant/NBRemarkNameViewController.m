//
//  NBRemarkNameViewController.m
//  BJEducation
//
//  Created by liujiaming on 16/11/22.
//  Copyright © 2016年 com.bjhl. All rights reserved.
//

#import "NBRemarkNameViewController.h"
#import "NSString+NBByteLength.h"
#import "NSString+utils.h"

@interface NBRemarkDetailTextView : UITextView

@end

@implementation NBRemarkDetailTextView
{
    UILabel *_placeholder;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _placeholder = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, self.current_w, 20)];
        _placeholder.text = @"添加更多备注信息，最多100个字";
        _placeholder.textColor = [UIColor colorWithHexString:@"#9d9d9e"];
        _placeholder.font = [UIFont systemFontOfSize:15];
        [self addSubview:_placeholder];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeEdit) name:UITextViewTextDidChangeNotification object:nil];
    
        self.textColor = [UIColor colorWithHexString:@"#3c3d3e"];
        self.font = [UIFont systemFontOfSize:15];
    }
    return self;
}

- (void)changeEdit
{
    if (self.text.length>0) {
        _placeholder.hidden = YES;
    }else{
        _placeholder.hidden = NO;
    }
}

@end

@interface NBRemarkNameViewController () <UITextViewDelegate>

@property (nonatomic,strong)UILabel *remarkTip;
@property (nonatomic,strong)UITextField *remarkName;
@property (nonatomic,strong)UILabel *detailtextTip;
@property (nonatomic,strong)NBRemarkDetailTextView *detailText;
@property (nonatomic,strong)UILabel *realNameLabel;

@end

@implementation NBRemarkNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateRightBtnColor];
}

#pragma mark - private
- (void)updateRightBtnColor
{
    if (self.remarkName.text.length>0||self.detailText.text.length>0) {
        [self.navigationItem.rightBarButtonItem.customView setTitleColor:[UIColor colorWithHexString:@"#37a4f5"] forState:UIControlStateNormal];
    }else{
        [self.navigationItem.rightBarButtonItem.customView setTitleColor:[UIColor colorWithHexString:@"#8cc8fd"] forState:UIControlStateNormal];
    }
}
- (void)sureClick:(UIButton *)button
{
    [[BJIMManager shareInstance]setRemarkName:self.remarkName.text.length>0?self.remarkName.text:@"" user:self.bjChatInfo.chatToUser callback:^(NSString *remarkName, NSInteger errCode, NSString *errMsg) {
        if (errCode==0) {
            [self showHUDWithText:@"修改成功" animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self showHUDWithText:errMsg animated:YES];
        }
    }];
}
- (NSString *)getRemarkNameFromChatInfo
{
    NSString *remarkName = [NSString defaultString:[self.bjChatInfo getContactRemarkName] defaultValue:@""];
    return remarkName;
}
- (NSString *)getRealNameFromChatInfo
{
    NSString *name = [NSString defaultString:[self.bjChatInfo getToName] defaultValue:@""];
    return name;
}
#pragma setupview

- (void)setupview{
    [self setupBackBarButtonItem];
    self.navigationItem.rightBarButtonItem = [self rightButton];
    self.title = @"备注";
    self.view.backgroundColor = [UIColor bj_gray_100];
    [self.view addSubview:self.remarkTip];
    [self.view addSubview:self.realNameLabel];
    [self remarkName];
    [self.view addSubview:self.detailtextTip];
    [self detailText];
}
- (UIBarButtonItem *)rightButton
{
    //right button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [button setTitleColor:[UIColor colorWithHexString:@"#37a4f5"] forState:UIControlStateNormal];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.frame = CGRectMake(0, 0, 60, 44);
    [button addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc]initWithCustomView:button];
}
- (UILabel *)remarkTip
{
    if (!_remarkTip) {
        _remarkTip = [[UILabel alloc]initWithFrame:CGRectMake(15, 64, 40, 36)];
        [self setLabel:_remarkTip text:@"备注名"];
    }
    return _remarkTip;
}

- (UILabel *)realNameLabel
{
    if (!_realNameLabel) {
        _realNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 64, self.view.current_w-80, 36)];
        _realNameLabel.textAlignment = NSTextAlignmentRight;
        [self setLabel:_realNameLabel text:[NSString stringWithFormat:@"用户名:%@",[self getRealNameFromChatInfo]]];
    }
    return _realNameLabel;
}

- (UITextField *)remarkName
{
    if (!_remarkName) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, self.remarkTip.current_y_h, self.view.current_w, 45)];
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
        _remarkName = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, self.view.current_w-30, 45)];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:@"添加备注名最多10个字"];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#9d9d9e"] range:NSMakeRange(0,string.length)];
        _remarkName.attributedPlaceholder = string;
        _remarkName.font = [UIFont systemFontOfSize:15];
        _remarkName.textColor = [UIColor colorWithHexString:@"#3c3d3e"];
        _remarkName.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_remarkName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [view addSubview:_remarkName];
        _remarkName.text = [self getRemarkNameFromChatInfo].length>0?[self getRemarkNameFromChatInfo]:@"";
    }
    return _remarkName;
}

- (UILabel *)detailtextTip
{
    if (!_detailtextTip) {
        _detailtextTip = [[UILabel alloc]initWithFrame:CGRectMake(15, self.remarkTip.current_y_h+45, 50, 36)];
        [self setLabel:_detailtextTip text:@"详细信息"];
    }
    return _detailtextTip;
}

- (NBRemarkDetailTextView *)detailText
{
    if (!_detailText) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, self.detailtextTip.current_y_h, self.view.current_w, 124)];
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
        _detailText = [[NBRemarkDetailTextView alloc]initWithFrame:CGRectMake(10, 5, self.view.current_w-20, 124-5)];
        _detailText.delegate = self;
        [view addSubview:_detailText];
    }
    return _detailText;
}

- (void)setLabel:(UILabel *)label text:(NSString *)text{
    if ([label isKindOfClass:[UILabel class]]) {
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithHexString:@"#9d9d9e"];
        label.text = text;
    }
}
#pragma mark  textfield delegate
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.remarkName) {
        if (textField.text.length > 10) {
            textField.text = [textField.text substringToIndex:10];
        }
    }
    [self updateRightBtnColor];
}

- (void)textViewDidChange:(UITextView *)textView
{
    // 选中范围的标记
    UITextRange *textSelectedRange = [textView markedTextRange];
    // 获取高亮部分
    UITextPosition *textPosition = [textView positionFromPosition:textSelectedRange.start offset:0];
    // 如果在变化中是高亮部分在变, 就不要计算字符了
    if (textSelectedRange && textPosition) {
        return;
    }
    
    if ([self.detailText.text nb_UTF8LengthOfString] > 100 * 3) {
        self.detailText.text = [self.detailText.text nb_substringWithCharLength:100 * 3];
    }
    [self updateRightBtnColor];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.remarkName resignFirstResponder];
    [self.detailText resignFirstResponder];
}
@end

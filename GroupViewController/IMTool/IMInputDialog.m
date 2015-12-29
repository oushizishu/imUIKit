//
//  IMInputDialog.m
//  BJEducation_student
//
//  Created by bjhl on 15/12/15.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "IMInputDialog.h"

@interface IMInputDialog()

@property (strong ,nonatomic)UIView *contentView;
@property (strong ,nonatomic)UITextField *textField;
@property (strong ,nonatomic)UIButton *cancelBtn;
@property (strong ,nonatomic)UIButton *comfireBtn;

@property (copy ,nonatomic)IMUserInputComplete userComplete;
@property (copy ,nonatomic)IMUserInputCancel userCancel;

@end

@implementation IMInputDialog

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

-(void)showWithDefaultContent:(NSString*)content withInputComplete:(IMUserInputComplete)complete withInputCancel:(IMUserInputCancel)cancel;
{
    CGRect sRect = [UIScreen mainScreen].bounds;
    
    self.userComplete = complete;
    self.userCancel = cancel;
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(sRect.size.width/8, (sRect.size.height-100)/2-100, sRect.size.width-sRect.size.width/4, 100)];
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#f7f9fa"];
    self.contentView.layer.masksToBounds = YES;
    [self.contentView.layer setCornerRadius:5.0f];
    [self.view addSubview:self.contentView];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.contentView.frame.size.width-20, 30)];
    //self.textField.backgroundColor = [UIColor lightGrayColor];
    [self.textField.layer setCornerRadius:5.0f];
    [self.textField.layer  setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.textField.layer setBorderWidth:0.5f];
    self.textField.placeholder = @"请输入文件名称，不能为空。";
    self.textField.text = content;
    self.textField.clearButtonMode = UITextFieldViewModeAlways;
    [self.contentView addSubview:self.textField];
    
    UIView *lineW = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-50, self.contentView.frame.size.width, 0.5)];
    lineW.backgroundColor = [UIColor colorWithHexString:@"#dcddde"];
    [self.contentView addSubview:lineW];
    
    UIView *lineH = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height-50, 0.5, 50)];
    lineH.backgroundColor = [UIColor colorWithHexString:@"#dcddde"];
    [self.contentView addSubview:lineH];
    
    self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-50, self.contentView.frame.size.width/2, 50)];
    self.cancelBtn.backgroundColor = [UIColor clearColor];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.cancelBtn];
    
    self.comfireBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height-50, self.contentView.frame.size.width/2, 50)];
    self.comfireBtn.backgroundColor = [UIColor clearColor];
    [self.comfireBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.comfireBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.comfireBtn addTarget:self action:@selector(comfireBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.comfireBtn];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController addChildViewController:self];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.view];
    [self willMoveToParentViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    
}

- (void)cancelBtnAction
{
    if (self.userCancel) {
        self.userCancel();
    }
    [self.view removeFromSuperview];
    
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(version < 7.0f || version >= 8.0f)
    {
        [self removeFromParentViewController];
    }
}

- (void)comfireBtnAction
{
    if (self.userComplete) {
        self.userComplete(self.textField.text);
    }
    [self.view removeFromSuperview];
    
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(version < 7.0f || version >= 8.0f)
    {
        [self removeFromParentViewController];
    }
}

@end

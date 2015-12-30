//
//  IMDialog.m
//  BJEducation
//
//  Created by bjhl on 15/12/18.
//  Copyright © 2015年 com.bjhl. All rights reserved.
//

#import "IMDialog.h"
#import "IMLinshiTool.h"

#define IMDIALOGHEIGHT 150.0f

@interface IMDialog()

@property (strong ,nonatomic) UIView *contentView;
@property (strong ,nonatomic)UIButton *cancelBtn;
@property (strong ,nonatomic)UIButton *comfireBtn;

@property (copy, nonatomic) IMDialogComfire comfire;
@property (copy, nonatomic) IMDialogCancel cancel;

@end

@implementation IMDialog

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

-(void)showWithContent:(NSString*)content withSelectBlock:(IMDialogComfire)comfire withCancelBlock:(IMDialogCancel)cancel
{
    CGRect sRect = [UIScreen mainScreen].bounds;
    
    self.comfire = comfire;
    self.cancel = cancel;
    
    CGFloat maxW = sRect.size.width-sRect.size.width/4-30;
    
    UIFont *font = [UIFont systemFontOfSize:15.0f];
    NSArray *splA = [IMLinshiTool splitMsg:content withFont:font withMaxWid:maxW];
    
    NSMutableArray *splMA = [[NSMutableArray alloc] init];
    if ([splA count] > 3) {
        [splMA addObjectsFromArray:[splA subarrayWithRange:NSMakeRange(0, 3)]];
    }else
    {
        [splMA addObjectsFromArray:splA];
    }
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(sRect.size.width/8, (sRect.size.height-(64+[splA count]*40))/2, sRect.size.width-sRect.size.width/4, 64+[splA count]*40)];
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#f7f9fa"];
    self.contentView.layer.masksToBounds = YES;
    [self.contentView.layer setCornerRadius:5.0f];
    [self.view addSubview:self.contentView];
    
    for (int i = 0; i < [splMA count]; i++) {
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(15, 20+i*40, self.contentView.frame.size.width-30, 20)];
        lable.font = font;
        lable.textAlignment = NSTextAlignmentCenter;
        lable.text = [splMA objectAtIndex:i];
        lable.textColor =[UIColor colorWithHexString:IMCOLOT_GREY600];
        [self.contentView addSubview:lable];
    }
    
    UIView *lineW = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-44, self.contentView.frame.size.width, 0.5)];
    lineW.backgroundColor = [UIColor colorWithHexString:@"#dcddde"];
    [self.contentView addSubview:lineW];
    
    UIView *lineH = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height-44, 0.5, 50)];
    lineH.backgroundColor = [UIColor colorWithHexString:@"#dcddde"];
    [self.contentView addSubview:lineH];
    
    self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-44, self.contentView.frame.size.width/2, 44)];
    self.cancelBtn.backgroundColor = [UIColor clearColor];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.cancelBtn];
    
    self.comfireBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height-44, self.contentView.frame.size.width/2, 44)];
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
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
//    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if(version < 7.0f || version >= 8.0f)
//    {
//        [self removeFromParentViewController];
//    }
    
    if (self.cancel) {
        self.cancel();
    }
}

- (void)comfireBtnAction
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
//    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if(version < 7.0f || version >= 8.0f)
//    {
//        [self removeFromParentViewController];
//    }
    
    if (self.comfire) {
        self.comfire();
    }
    
}

@end

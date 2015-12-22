//
//  MBProgressHUD+IMKit.m
//
//  Created by wangziliang on 15/12/1.
//

#import "MBProgressHUD+IMKit.h"

@implementation MBProgressHUD(IMKit)

+ (void)imShowError:(NSString *)error
{
    [self imShow:error icon:@"error.png" view:[UIApplication sharedApplication].keyWindow];
}

#pragma mark 显示错误信息
+ (void)imShowError:(NSString *)error toView:(UIView *)view{
    [self imShow:error icon:@"error.png" view:view];
}

+ (void)imShow:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16];
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:2];
}

+ (void)imShowMessageThenHide:(NSString*) msg toView:(UIView*)view
{
    [self imShowMessageThenHide:msg toView:view onHide:nil];
}

+ (void)imShowMessageThenHide:(NSString *)msg toView:(UIView *)view onHide:(void (^)())onHide
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    NSAssert1(view != nil, @"showLoading view没找到 %s", __FUNCTION__);
    
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (!hud){
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    NSAssert1(hud != nil, @"hud为nil %s", __FUNCTION__);
    
    hud.detailsLabelFont = [UIFont systemFontOfSize:16];
    hud.detailsLabelText = msg;
    
    // 再设置模式
    hud.mode = MBProgressHUDModeText;
    [hud setUserInteractionEnabled:false];
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    hud.dimBackground = NO;
    // 2秒之后再消失
    int hideInterval = 2;
    [hud hide:YES afterDelay:hideInterval];
    
    if (onHide){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(hideInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            onHide();
        });
    }
}

+ (MBProgressHUD*) imShowLoading:(NSString*)msg toView:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    NSAssert1(view != nil, @"showLoading view没找到 %s", __FUNCTION__);
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    
    NSAssert1(hud != nil, @"hud为nil %s", __FUNCTION__);
    hud.detailsLabelText = msg;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16];
    
    // 再设置模式
    hud.mode = MBProgressHUDModeIndeterminate;
    //[hud setUserInteractionEnabled:false];
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    return hud;
}

@end

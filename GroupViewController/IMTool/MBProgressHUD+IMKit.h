//
//  MBProgressHUD+IMKit.h
//
//  Created by wangziliang on 15/12/1.
//

#import <MBProgressHUD.h>

@interface MBProgressHUD(IMKit)

+ (void)imShowError:(NSString *)error;

+ (void)imShowError:(NSString *)error toView:(UIView *)view;
/**
 *  显示toast
 *
 *  @param msg  消息内容
 *  @param view 所在的superview
 */
+ (void)imShowMessageThenHide:(NSString *)msg toView:(UIView*)view;
+ (void)imShowMessageThenHide:(NSString *)msg toView:(UIView *)view onHide:(void (^)())onHide;

/**
 *  显示加载中，以及文本消息
 *
 *  @param msg  消息内容，如果为nil，则只显示loading图
 *  @param view 所在的superview
 *
 *  @return 返回当前hud，方便之后hide
 */
+ (MBProgressHUD*) imShowLoading:(NSString *)msg toView:(UIView *)view;

@end

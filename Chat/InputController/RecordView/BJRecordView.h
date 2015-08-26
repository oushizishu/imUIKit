/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>

@protocol BJRecordViewDelegate <NSObject>
@required
- (double)getAudioMeter;

@end

@interface BJRecordView : UIView
@property (weak, nonatomic) id<BJRecordViewDelegate>delegate;
//录音区域
@property(strong ,nonatomic)UIView *recordView;
//外部圆形区
@property(strong ,nonatomic)UIView *roundView;
//圆形显示区
@property(nonatomic, strong)UIView *showView;
// 显示动画的ImageView
@property (nonatomic, strong) UIImageView *recordAnimationView;
//文本框
@property (nonatomic, strong) UILabel *tLable;
// 提示文字
@property (nonatomic, strong) UILabel *textLabel;
//倒计时提示
@property (nonatomic, strong) UILabel *countdownLable;
//声音长度
@property(nonatomic)CGFloat timelength;

// 录音按钮按下
-(void)recordButtonTouchDown;
// 手指在录音按钮内部时离开
-(void)recordButtonTouchUpInside;
// 手指在录音按钮外部时离开
-(void)recordButtonTouchUpOutside;
// 手指移动到录音按钮内部
-(void)recordButtonDragInside;
// 手指移动到录音按钮外部
-(void)recordButtonDragOutside;

@end

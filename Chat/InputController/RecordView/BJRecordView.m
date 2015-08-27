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

#import "BJRecordView.h"
@interface BJRecordView ()
{
    NSTimer *_timer;
    
}

@end

@implementation BJRecordView
@synthesize showView = _showView;
@synthesize recordAnimationView = _recordAnimationView;
@synthesize tLable = _tLable;
@synthesize textLabel = _textLabel;
@synthesize timelength = _timelength;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
//        bgView.backgroundColor = [UIColor grayColor];
//        bgView.layer.cornerRadius = 5;
//        bgView.layer.masksToBounds = YES;
//        bgView.alpha = 0.6;
//        [self addSubview:bgView];
        
        UIView *roundView = [[UIView alloc] initWithFrame:CGRectMake(45/2,0, self.frame.size.width-45, self.frame.size.width-45)];
        roundView.layer.cornerRadius = roundView.frame.size.height/2;
        roundView.backgroundColor = [UIColor colorWithHexString:@"#ffcc80"];
        [self addSubview:roundView];
        
        _showView = [[UIView alloc] initWithFrame:CGRectMake(30, 30, roundView.frame.size.width-60, roundView.frame.size.height-60)];
        _showView.clipsToBounds = YES;
        _showView.layer.cornerRadius = self.showView.frame.size.height/2;
        _showView.backgroundColor = [UIColor whiteColor];
        [roundView addSubview:_showView];
        
        _recordAnimationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _showView.frame.size.width, _showView.frame.size.height)];
        _recordAnimationView.image = [UIImage imageNamed:@"ic_record_n"];
        [_showView addSubview:_recordAnimationView];
        
        _tLable = [[UILabel alloc] initWithFrame:CGRectMake(10, _showView.frame.size.height-30, _showView.frame.size.width-20, 25)];
        _tLable.textAlignment = NSTextAlignmentCenter;
        _tLable.backgroundColor = [UIColor clearColor];
        _timelength = 0;
        _tLable.text = [NSString stringWithFormat:@"%lu\"",self.timelength];
        _tLable.font = [UIFont systemFontOfSize:12];
        _tLable.textColor = [UIColor colorWithHexString:@"#6d6e6e"];
        [_recordAnimationView addSubview:_tLable];
        
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                               self.bounds.size.height - 35,
                                                               self.bounds.size.width - 20,
                                                               25)];
        
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.text = @" 手指上滑，取消发送 ";
        [self addSubview:_textLabel];
        _textLabel.font = [UIFont systemFontOfSize:12];
        _textLabel.textColor = [UIColor colorWithHexString:@"#9d9e9e"];
        _textLabel.layer.cornerRadius = 5;
        _textLabel.layer.borderColor = [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor;
        _textLabel.layer.masksToBounds = YES;
    }
    return self;
}

// 录音按钮按下
-(void)recordButtonTouchDown
{
    // 需要根据声音大小切换recordView动画
    _textLabel.text = @" 手指上滑，取消发送 ";
    self.timelength = 0;
    _tLable.text = [NSString stringWithFormat:@"%lu\"",self.timelength];
    [_recordAnimationView addSubview:_tLable];
    [self.recordAnimationView setImage:[UIImage imageNamed:@"ic_record_n"]];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(setVoiceImage)
                                            userInfo:nil
                                             repeats:YES];
    
}
// 手指在录音按钮内部时离开
-(void)recordButtonTouchUpInside
{
    [_timer invalidate];
}
// 手指在录音按钮外部时离开
-(void)recordButtonTouchUpOutside
{
    [_timer invalidate];
}
// 手指移动到录音按钮内部
-(void)recordButtonDragInside
{
    _textLabel.text = @" 手指上滑，取消发送 ";
    [_recordAnimationView addSubview:_tLable];
    [self.recordAnimationView setImage:[UIImage imageNamed:@"ic_record_n"]];
}

// 手指移动到录音按钮外部
-(void)recordButtonDragOutside
{
    _textLabel.text = @" 松开手指，取消发送 ";
    [_tLable removeFromSuperview];
    [self.recordAnimationView setImage:[UIImage imageNamed:@"ic_sound-record_n"]];
}

-(void)setVoiceImage {
    _timelength++;
    _tLable.text = [NSString stringWithFormat:@"%lu\"",_timelength];
}

@end

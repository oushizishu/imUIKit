//
//  BJChatInputBarViewController+BJRecordView.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/27.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJChatInputBarViewController+BJRecordView.h"
#import "BJRecordView.h"
#import <BJAudioBufferRecorder.h>
#import <JLMicrophonePermission.h>
#import "BJChatLimitMacro.h"
#import "BJChatUtilsMacro.h"
#import <BJHL-Common-iOS-SDK/BJCommonDefines.h>

static char BJRecordView_View;
static char BJRecordView_Recorder;

@interface BJChatInputBaseViewController ()<BJRecordViewDelegate>
/**
 *  RecordView
 */
@property (strong, nonatomic) BJRecordView *recordView;
@property (strong, nonatomic) BJAudioBufferRecorder *recorder;
@end

@implementation BJChatInputBarViewController (BJRecordView)
- (void)bjrv_cancelTouchRecordView;
{
    [self.recordView recordButtonTouchUpInside];
    [self.recordView removeFromSuperview];
}

- (void)bjrv_setupRecordView:(UIButton *)button;
{
    [button addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [button addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
}

- (void)recordButtonTouchDown
{
    __weak typeof(self) weakSelf = self;
    //如果还没有获取授权，则按住效果会被打断
    if (SYSTEM_VERSION_LESS_THAN(@"7.0") || [[JLMicrophonePermission sharedInstance] authorizationStatus] == JLPermissionAuthorized)
    {
        weakSelf.recordView.center = weakSelf.parentViewController.view.center;
        CGRect rFrame = weakSelf.recordView.frame;
        CGRect pFrame = weakSelf.parentViewController.view.frame;
        rFrame.origin.y = (pFrame.size.height-rFrame.size.height)/2;
        weakSelf.recordView.frame = rFrame;
        [weakSelf.parentViewController.view addSubview:weakSelf.recordView];
        [weakSelf.parentViewController.view bringSubviewToFront:weakSelf.recordView];
        [weakSelf.recordView recordButtonTouchDown];
        [self.recorder startRecord:^(BOOL isStart) {
            [weakSelf.recorder enableLevelMetering:YES];
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.recorder setFinishCallback:^(NSString *message,NSInteger timeLength,BOOL isSuc, BOOL isFinish){
                [weakSelf recordButtonTouchUpInside];
            }];
        });
        
    }
    else
    {
        [[JLMicrophonePermission sharedInstance] authorize:^(bool granted, NSError *error) {
            
        }];
        
    }
}


- (void)recordButtonTouchUpOutside
{
    [self.recordView recordButtonTouchUpOutside];
    [self.recorder cancelRecord];
    [self.recordView removeFromSuperview];
}

- (void)recordButtonTouchUpInside
{
    [self.recordView recordButtonTouchUpInside];
    [self.recordView removeFromSuperview];
    __weak typeof(self) weakSelf = self;
    self.recorder.finishCallback = ^(NSString *message,NSInteger timeLength,BOOL isSuc,BOOL isFinish){
        if (isFinish && timeLength>BJChat_Audio_Min_Time) {//录制并转码成功，并且大于2秒
            [BJSendMessageHelper sendAudioMessage:message duration:timeLength chatInfo:weakSelf.chatInfo];
        }
        else if (timeLength<=BJChat_Audio_Min_Time)//录制时间不够
        {
            @IMTODO("错误提示");
//            [MBProgressHUD showMessage:@"录制时间太短" toView:[self.view superview]];
        }
        else if (isSuc) {//录制成功，正在转mp3
            @IMTODO("添加录音成功提示。");
            
        }
        else//失败，失败原因在message
        {
            @IMTODO("添加提示。");
//            [MBProgressHUD showMessage:message toView:[self.view superview]];
        }
    };
    self.recorder.remainingCallback = ^(CGFloat time){
        
    };
    [self.recorder stopRecord];
}

- (void)recordDragOutside
{
    [self.recordView recordButtonDragOutside];
}

- (void)recordDragInside
{
    [self.recordView recordButtonDragInside];
}

#pragma mark - DXRecordViewDelegate
- (double)getAudioMeter;
{
    return self.recorder.audioMeter;
}

#pragma mark - set get
- (BJRecordView *)recordView
{
    if (objc_getAssociatedObject(self, &BJRecordView_View) == nil) {
        BJRecordView *view = [[BJRecordView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
        view.delegate = self;
        [self setRecordView:view];
    }
    
    return objc_getAssociatedObject(self, &BJRecordView_View);
}

- (void)setRecordView:(BJRecordView *)recordView
{
    objc_setAssociatedObject(self, &BJRecordView_View, recordView, OBJC_ASSOCIATION_RETAIN);
}

- (BJAudioBufferRecorder *)recorder
{
    if (objc_getAssociatedObject(self, &BJRecordView_Recorder) == nil) {
        BJAudioBufferRecorder *recorder = [[BJAudioBufferRecorder alloc] init];
        recorder.duration = 60;
        [self setRecorder:recorder];
    }
    return objc_getAssociatedObject(self, &BJRecordView_Recorder);
}

- (void)setRecorder:(BJAudioBufferRecorder *)recorder
{
    objc_setAssociatedObject(self, &BJRecordView_Recorder, recorder, OBJC_ASSOCIATION_RETAIN);
}

@end

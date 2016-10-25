//
//  BJChatInputEmojiViewController.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/27.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJChatInputEmojiViewController.h"
#import "BJFaceView.h"
#import "BJFacialView.h"
#import <PureLayout.h>
#import "BJSendMessageHelper.h"

@interface BJChatInputEmojiViewController()<BJFaceDelegate>
@property (strong, nonatomic) BJFaceView *faceView;
@end

@implementation BJChatInputEmojiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200);
    self.view.autoresizingMask = UIViewAutoresizingNone;

    [self.view addSubview:self.faceView];
    
    //增加线
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    topLineView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    [self.view addSubview:topLineView];
}

#pragma mark - action
- (void)sendFaceMessage:(NSString *)str
{
    [BJSendMessageHelper sendEmojiMessage:str content:[BJFacialView imageUrlWithEmoji:str] chatInfo:self.chatInfo];
}

#pragma mark - DXFaceDelegate
- (void)selectThenSendImage:(UIImage *)img emoji:(NSString *)emoji
{
    if (img) {
        [self sendFaceMessage:emoji];
    }
}

#pragma mark - set get
- (BJFaceView *)faceView
{
    if (_faceView == nil) {
        _faceView = [[BJFaceView alloc] initWithFrame:self.view.bounds];
        _faceView.backgroundColor = [UIColor clearColor];
        _faceView.delegate = self;
    }
    return _faceView;
}

@end

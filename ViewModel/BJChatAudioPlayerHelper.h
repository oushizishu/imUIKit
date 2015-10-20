//
//  BJAudioPlayerWithCache.h
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/27.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IMMessage.h>
typedef void (^ChatAudioPlayerFinishCallback)(NSError *error);

@interface BJChatAudioPlayerHelper : NSObject

+ (instancetype)sharedInstance;
- (void)startPlayerWithMessage:(IMMessage *)message callback:(ChatAudioPlayerFinishCallback)callback;
/**
 *  停止某一个音频消息的播放，如果当前播放的不是此消息，播放不受影响，并且因为是主动停止，不会通知callback
 *
 *  @param message 音频消息
 */
- (void)stopPlayerWithMessage:(IMMessage *)message;
/**
 *  停止当前的播放 并且因为是被动停止，所以会通知callback
 */
- (void)stopPlayer;
- (BOOL)isPlayerWithMessage:(IMMessage *)message;

/**
 *  把消息的音频文件下载到本地
 *
 *  @param message
 */
- (void)downLoadAudioWithMessage:(IMMessage *)message;
@end

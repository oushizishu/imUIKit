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
- (void)stopPlayerWithMessage:(IMMessage *)message;
/**
 *  停止当前的播放
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

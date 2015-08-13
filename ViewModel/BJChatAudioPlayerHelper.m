//
//  BJAudioPlayerWithCache.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/27.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJChatAudioPlayerHelper.h"
#import <BJAudioPlayer.h>
#import "IMMessage+ViewModel.h"
#import "BJChatUtilsMacro.h"
#import "BJChatFileCacheManager.h"
#import <BJNetworkUtil.h>
#import <BJCommonProxy.h>
#import <NSError+BJIM.h>

@interface BJChatAudioPlayerHelper ()
@property (strong, nonatomic) BJAudioPlayer *player;
/**
 *  有标识作用，如果播放完毕，会赋值nil
 */
@property (strong, nonatomic) IMMessage *message;
@property (copy, nonatomic) ChatAudioPlayerFinishCallback callback;
@property (strong, nonatomic) NSMutableDictionary *downloadAudioDic;
@end

@implementation BJChatAudioPlayerHelper

+ (instancetype)sharedInstance
{
    static BJChatAudioPlayerHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (NSString *)downKeyStrWithMessage:(IMMessage *)message
{
    return [NSString stringWithFormat:@"%ld",(long)message.rowid];
}

- (NSString *)localFilePathWithMessage:(IMMessage *)message
{
    NSString *localPath = [BJChatFileCacheManager audioCachePathWithName:[self downKeyStrWithMessage:message]];
    return [localPath stringByAppendingPathExtension:@"mp3"];
}

#pragma mark - Public

- (void)startPlayerWithMessage:(IMMessage *)message callback:(ChatAudioPlayerFinishCallback)callback;
{
    if (message.msg_t != eMessageType_AUDIO) {
        return;
    }
    self.callback = callback;
    self.message = message;
    if ([message.audioURL isFileURL]) {
        [self.player startPlayWithUrl:message.audioURL];
    }
    else if(message.audioURL)
    {
        NSString *localPath = [self localFilePathWithMessage:message];
        if ([BJFileManagerTool isFileExisted:nil path:localPath]) {
            [self.player startPlayWithUrl:[NSURL fileURLWithPath:localPath]];
        }
        else
        {
            [self downLoadAudioWithMessage:message];
            
        }
    }
    else
    {
        if (callback) {
            callback([NSError bjim_errorWithReason:@"文件不存在"]);
        }
    }
}

- (void)stopPlayerWithMessage:(IMMessage *)message;
{
    if ([self isPlayerWithMessage:message]) {
        [self stopPlayer];
    }
}

- (BOOL)isPlayerWithMessage:(IMMessage *)message;
{
    return [self.message isEqual:message];
}

/**
 *  停止当前的播放
 */
- (void)stopPlayer;
{
    [self.player stopPlay];
    self.message = nil;
}

#pragma mark - 下载
- (void)downLoadAudioWithMessage:(IMMessage *)message
{
    if (message.msg_t != eMessageType_AUDIO) {
        return;
    }
    
    if ([self.downloadAudioDic objectForKey:[self downKeyStrWithMessage:message]]) {
        return;
    }
    WS(weakSelf);
    [self.downloadAudioDic setObject:message forKey:[self downKeyStrWithMessage:message]];
    RequestParams *params = [[RequestParams alloc] initWithUrl:[message.audioURL absoluteString]];
    [BJCommonProxyInstance.networkUtil doDownloadResource:params fileDownPath:[self localFilePathWithMessage:message] success:^(id response, NSDictionary *responseHeaders, RequestParams *params) {
        if ([weakSelf.message isEqual:message]) {
            [weakSelf startPlayerWithMessage:message callback:weakSelf.callback];
        }
    } failure:^(NSError *error, RequestParams *params) {
        if ([weakSelf.message isEqual:message]) {
            [weakSelf.downloadAudioDic removeObjectForKey:[self downKeyStrWithMessage:message]];
            if (weakSelf.callback) {
                weakSelf.callback(error);
            }
        }
    } progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpected) {
        
    }];
}

#pragma mark - set get
- (BJAudioPlayer *)player
{
    if (_player == nil) {
        _player = [[BJAudioPlayer alloc] init];
        __weak typeof(self) weakSelf = self;
        _player.callback = ^(NSString *message, BOOL isFinish){
            if (isFinish && weakSelf.callback) {
                NSError *error = nil;
                if (message.length>0) {
                    error = [NSError errorWithDomain:@"BJChat" code:100 userInfo:@{NSLocalizedFailureReasonErrorKey:message}];
                }
                weakSelf.message = nil;
                weakSelf.callback(error);
            }
        };
    }
    return _player;
}

- (NSMutableDictionary *)downloadAudioDic
{
    if (_downloadAudioDic == nil) {
        _downloadAudioDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _downloadAudioDic;
}

@end

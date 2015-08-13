//
//  BJSendMessageHelper.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/25.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJSendMessageHelper.h"
#import <IMTxtMessageBody.h>
#import <IMAudioMessageBody.h>
#import <IMImgMessageBody.h>
#import <IMEmojiMessageBody.h>
#import "BJChatInfo.h"
#import "CardSimpleItem.h"
#import "BJChatFileCacheManager.h"
@implementation BJSendMessageHelper

+ (instancetype)sharedInstance
{
    static BJSendMessageHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+ (void)sendMessage:(IMMessage *)message
{
    if ([[BJSendMessageHelper sharedInstance].deledate respondsToSelector:@selector(willSendMessage:)]) {
        [[BJSendMessageHelper sharedInstance].deledate willSendMessage:message];
    }
    [[BJIMManager shareInstance] sendMessage:message];
}

#pragma mark - 消息发送
+ (IMMessage *)sendTextMessage:(NSString *)text chatInfo:(BJChatInfo *)chatInfo;
{
    IMTxtMessageBody *messageBody = [[IMTxtMessageBody alloc] init];
    messageBody.content = text;
    IMMessage *message = [[IMMessage alloc] init];
    message.messageBody = messageBody;
    message.createAt = [NSDate date].timeIntervalSince1970;
    message.chat_t = chatInfo.chat_t;
    message.msg_t = eMessageType_TXT;
    message.receiver = chatInfo.getToId;
    message.receiverRole = chatInfo.getToRole;
    [BJSendMessageHelper sendMessage:message];
    return message;
}

+ (IMMessage *)sendAudioMessage:(NSString *)filePath duration:(NSInteger)duration chatInfo:(BJChatInfo *)chatInfo;
{
    //弄成相对路径，每次build发现绝对路径有变化
    NSString *relativePath = [BJChatFileCacheManager audioCacheRelativePathWithName:[filePath lastPathComponent]];
    IMAudioMessageBody *messageBody = [[IMAudioMessageBody alloc] init];
    messageBody.file = relativePath;
    messageBody.length = duration;
    
    IMMessage *message = [[IMMessage alloc] init];
    message.createAt = [NSDate date].timeIntervalSince1970;
    message.messageBody = messageBody;
    message.chat_t = chatInfo.chat_t;
    message.msg_t = eMessageType_AUDIO;
    message.receiver = chatInfo.getToId;
    message.receiverRole = chatInfo.getToRole;
    [BJSendMessageHelper sendMessage:message];
    return message;
}

+ (IMMessage *)sendImageMessage:(NSString *)filePath imageSize:(CGSize)size chatInfo:(BJChatInfo *)chatInfo;
{
    //弄成相对路径，每次build发现绝对路径有变化
    NSString *relativePath = [BJChatFileCacheManager audioCacheRelativePathWithName:[filePath lastPathComponent]];
    IMImgMessageBody *messageBody = [[IMImgMessageBody alloc] init];
    messageBody.file = relativePath;
    messageBody.width = size.width;
    messageBody.height = size.height;
    
    IMMessage *message = [[IMMessage alloc] init];
    message.messageBody = messageBody;
    message.createAt = [NSDate date].timeIntervalSince1970;
    message.chat_t = chatInfo.chat_t;
    message.msg_t = eMessageType_IMG;
    message.receiver = chatInfo.getToId;
    message.receiverRole = chatInfo.getToRole;
    [BJSendMessageHelper sendMessage:message];
    return message;
}

+ (IMMessage *)sendEmojiMessage:(NSString *)emoji content:(NSString *)content chatInfo:(BJChatInfo *)chatInfo;
{
    IMEmojiMessageBody *messageBody = [[IMEmojiMessageBody alloc] init];
    messageBody.name = emoji;
    messageBody.content = content;
    messageBody.type = EmojiContent_GIF;
    
    IMMessage *message = [[IMMessage alloc] init];
    message.messageBody = messageBody;
    message.createAt = [NSDate date].timeIntervalSince1970;
    message.chat_t = chatInfo.chat_t;
    message.msg_t = eMessageType_EMOJI;
    message.receiver = chatInfo.getToId;
    message.receiverRole = chatInfo.getToRole;
    [BJSendMessageHelper sendMessage:message];
    return message;
}

+ (IMMessage *)sendCardMessage:(CardSimpleItem *)card
                      chatInfo:(BJChatInfo *)chatInfo;
{
    return [BJSendMessageHelper sendTextMessage:card.url chatInfo:chatInfo];
//    
//    IMCardMessageBody *messageBody = [[IMCardMessageBody alloc] init];
//    messageBody.title = card.title;
//    messageBody.content = card.content;
//    messageBody.url = card.url;
//    messageBody.thumb = card.thumb;
//    
//    IMMessage *message = [[IMMessage alloc] init];
//    message.messageBody = messageBody;
//    message.createAt = [NSDate date].timeIntervalSince1970;
//    message.chat_t = chatInfo.chat_t;
//    message.msg_t = eMessageType_CARD;
//    message.receiver = chatInfo.getToId;
//    message.receiverRole = chatInfo.getToRole;
//    [BJSendMessageHelper sendMessage:message];
//    return message;
}

@end

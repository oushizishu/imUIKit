//
//  BJChatInfo.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/25.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJChatInfo.h"
#import <BJIMConstants.h>
#import <Conversation+DB.h>
#import "BJExchangeIMModel.h"
#import "User+ViewModel.h"
#import "Group+ViewModel.h"
@implementation BJChatInfo

- (instancetype)initWithUser:(User *)user
{
    self = [super init];
    if (self) {
        _chat_t = eChatType_Chat;
        _chatToUser = user;
    }
    return self;
}

- (instancetype)initWithGroup:(Group *)group
{
    self = [super init];
    if (self) {
        _chat_t = eChatType_GroupChat;
        _chatToGroup = group;
    }
    return self;
}

- (instancetype)initWithContact:(id<BJContactInfoProtocol>)contact;
{
    if ([contact isKindOfClass:[User class]]) {
        self = [self initWithUser:(User *)contact];
    }
    else if ([contact isKindOfClass:[Group class]])
    {
        self = [self initWithGroup:(Group *)contact];
    }
    else
    {
        if ([contact getContactType] == BJContact_Group) {
            self = [self initWithGroup:[BJExchangeIMModel groupWithContact:contact]];
        }
        else
        {
            self = [self initWithUser:[BJExchangeIMModel userWithContact:contact]];
        }
    }
    return self;
}

- (instancetype)initWithConversation:(Conversation *)conversation;
{
    if (conversation.chat_t == eChatType_Chat) {
        self = [self initWithUser:conversation.chatToUser];
    }
    else{
        self = [self initWithGroup:conversation.chatToGroup];
    }
    if (self) {
        
    }
    return self;
}

- (int64_t)getToId;
{
    if (self.chat_t == eChatType_Chat) {
        return self.chatToUser.userId;
    }
    else
        return self.chatToGroup.groupId;
}

- (IMUserRole)getToRole;
{
    if (self.chat_t == eChatType_Chat) {
        return self.chatToUser.userRole;
    }
    else
        return eUserRole_Anonymous;
}

- (NSString *)getToName;
{
    if (self.chat_t == eChatType_Chat) {
        return self.chatToUser.name;
    }
    else
        return self.chatToGroup.groupName;
}

#pragma mark -BJContactInfoProtocol
- (NSString *)getContactNickName;
{
    if (self.chat_t == eChatType_Chat) {
        return [self.chatToUser getContactNickName];
    }
    else if (self.chat_t == eChatType_GroupChat)
    {
        return @"";
    }
    else
    {
        return @"";
    }
}

- (NSString *)getContactRemarkName;
{
    if (self.chat_t == eChatType_Chat) {
        return [self.chatToUser getContactRemarkName];
    }
    else if (self.chat_t == eChatType_GroupChat)
    {
        return @"";
    }
    else
    {
        return @"";
    }
}

- (NSString *)getContactName;
{
    if (self.chat_t == eChatType_Chat) {
        return [self.chatToUser getContactName];
    }
    else if (self.chat_t == eChatType_GroupChat)
    {
        return @"";
    }
    else
    {
        return @"";
    }
}

- (NSString *)getContactAvatar;
{
    if (self.chat_t == eChatType_Chat) {
        return [self.chatToUser getContactAvatar];
    }
    else if (self.chat_t == eChatType_GroupChat)
    {
        return [self.chatToGroup getContactAvatar];
    }
    else
    {
        return @"";
    }
}

- (BJContactType)getContactType;
{
    if (self.chat_t == eChatType_Chat) {
        return [self.chatToUser getContactType];
    }
    else if (self.chat_t == eChatType_GroupChat)
    {
        return [self.chatToGroup getContactType];
    }
    return BJContact_Unkonwn;
}

- (long long)getContactId;
{
    if (self.chat_t == eChatType_Chat) {
        return self.chatToUser.userId;
    }
    else
        return self.chatToGroup.groupId;
}

- (long long)getContactTime;
{
    return 0;
}

- (NSAttributedString *)getContactContentAttr;
{
    return nil;
}

- (NSString *)getContactHeader;
{
    if (self.chat_t == eChatType_Chat) {
        return [self.chatToUser getContactHeader];
    }
    else if (self.chat_t == eChatType_GroupChat)
    {
        return [self.chatToGroup getContactHeader];
    }
    else
    {
        return @"";
    }
}

@end

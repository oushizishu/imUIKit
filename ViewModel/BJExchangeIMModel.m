//
//  ExchangeIMToContactModel.m
//  BJEducation_Institution
//
//  Created by Randy on 15/8/3.
//  Copyright (c) 2015年 com.bjhl. All rights reserved.
//

#import "BJExchangeIMModel.h"

@implementation BJExchangeIMModel

+ (Group *)groupWithContact:(id<BJContactInfoProtocol>)contact;
{
    Group *group = [[Group alloc] init];
    group.groupId = [contact getContactId];
    group.groupName = [contact getContactName];
    group.createTime = [contact getContactTime];
    group.avatar = [contact getContactAvatar];
    return group;
}

+ (User *)userWithContact:(id<BJContactInfoProtocol>)contact;
{
    User *user = [[User alloc] init];
    user.name = [contact getContactName];
    user.avatar = [contact getContactAvatar];
    user.userId = [contact getContactId];
    user.userRole = (IMUserRole)[contact getContactType];
    return user;
}
@end

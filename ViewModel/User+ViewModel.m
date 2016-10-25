//
//  User+ViewModel.m
//  BJEducation_Institution
//
//  Created by Randy on 15/7/31.
//  Copyright (c) 2015年 com.bjhl. All rights reserved.
//

#import "User+ViewModel.h"
#import "BJChatUtilsMacro.h"

@implementation User (ViewModel)

- (NSString *)getContactNickName;
{
    if (self.userRole == eUserRole_System) {
        return @"系统消息";
    }
    else if (self.userRole == eUserRole_Kefu)
    {
        return @"跟谁学客服";
    }
    return self.name;
}

- (NSString *)getContactRemarkName;
{
    return self.remarkName;
}

- (NSString *)getContactName;
{
    if (self.remarkName.length>0) {
        return self.remarkName;
    }
    return [self getContactNickName];
}

- (NSString *)getContactAvatar;
{
    if (self.userRole == eUserRole_Kefu) {
        return @"http://img.gsxservice.com/ic_customer.png";
    }
    return self.avatar;
}

- (long long)getContactTime;
{
    return 0;
}

- (NSAttributedString *)getContactContentAttr;
{
    return nil;
}

- (BJContactType)getContactType;
{
    return (BJContactType)self.userRole;
}

- (long long)getContactId;
{
    return self.userId;
}

- (NSString *)getContactHeader;
{
    if (self.remarkName.length>0) {
        return self.remarkHeader;
    }
    return self.nameHeader;
}
- (IMUserOnlineStatus )getContactOnlineStatus
{
    return self.onlineStatus;
}
@end

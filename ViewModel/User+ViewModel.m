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

- (NSString *)getContactName;
{
    if (self.remarkName.length>0) {
        return self.remarkName;
    }
    return self.name;
}

- (NSString *)getContactAvatar;
{
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
    return self.userRole;
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

@end

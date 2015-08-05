//
//  Group+ViewModel.m
//  BJEducation_Institution
//
//  Created by Randy on 15/7/31.
//  Copyright (c) 2015年 com.bjhl. All rights reserved.
//

#import "Group+ViewModel.h"
#import "BJChatUtilsMacro.h"

@implementation Group (ViewModel)
- (NSString *)getContactName;
{
    return self.groupName;
}

- (NSString *)getContactAvatar;
{
    return self.avatar;
}

- (long long)getContactTime;
{
    return self.createTime;
}

- (NSAttributedString *)getContactContentAttr;
{
    return nil;
}

- (BJContactType)getContactType;
{
    return BJContact_Group;
}

- (long long)getContactId;
{
    return self.groupId;
}

- (NSString *)getContactHeader;
{
    return self.nameHeader;
}

@end

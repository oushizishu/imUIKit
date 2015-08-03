//
//  Group+ViewModel.m
//  BJEducation_Institution
//
//  Created by Randy on 15/7/31.
//  Copyright (c) 2015年 com.bjhl. All rights reserved.
//

#import "Group+ViewModel.h"

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

- (ContactType)getContactType;
{
    return Contact_Group;
}

- (long long)getContactId;
{
    return self.groupId;
}

- (NSString *)getContactHeader;
{
    @TODO("返回head数据");
    return @"";
}

@end

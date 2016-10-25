//
//  BJContactInfoProtocol.h
//  BJEducation_Institution
//
//  Created by Randy on 15/7/31.
//  Copyright (c) 2015年 com.bjhl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BJIMConstantKit.h"

@protocol BJContactInfoProtocol <NSObject>
@required
- (NSString *)getContactName;

- (NSString *)getContactAvatar;
- (long long)getContactTime;
- (NSAttributedString *)getContactContentAttr;
- (BJContactType)getContactType;
- (long long)getContactId;
- (NSString *)getContactHeader;

@optional
- (NSString *)getContactNickName;
- (NSString *)getContactRemarkName;
- (NSString *)getContactRemarkName;
- (IMUserOnlineStatus )getContactOnlineStatus;

@end

//
//  BJContactInfoProtocol.h
//  BJEducation_Institution
//
//  Created by Randy on 15/7/31.
//  Copyright (c) 2015年 com.bjhl. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
{
    //    Contact_Visitor = -1,
    BJContact_Teacher = 0,
    BJContact_Students = 2,
    BJContact_Organization = 6,
    BJContact_KeFu = 7,
    BJContact_Admin = 1000,
    BJContact_Group = 1001,
    BJContact_Unkonwn = 1002,
}BJContactType;

@protocol BJContactInfoProtocol <NSObject>
@required
- (NSString *)getContactName;
- (NSString *)getContactAvatar;
- (long long)getContactTime;
- (NSAttributedString *)getContactContentAttr;
- (BJContactType)getContactType;
- (long long)getContactId;
- (NSString *)getContactHeader;
@end

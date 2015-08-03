//
//  ExchangeIMToContactModel.h
//  BJEducation_Institution
//
//  Created by Randy on 15/8/3.
//  Copyright (c) 2015年 com.bjhl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Group.h>
#import <User.h>
#import "BJContactInfoProtocol.h"
@interface BJExchangeIMModel : NSObject
+ (Group *)groupWithContact:(id<BJContactInfoProtocol>)contact;
+ (User *)userWithContact:(id<BJContactInfoProtocol>)contact;
@end

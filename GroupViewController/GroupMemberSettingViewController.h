//
//  GroupMemberSettingViewController.h
//  BJEducation
//
//  Created by Mac_ZL on 17/2/14.
//  Copyright © 2017年 com.bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJChatInfo.h"


@interface GroupMemberSettingViewController : UIViewController

@property (nonatomic,assign)int64_t groupId;

@property (nonatomic,strong)User *user;

@property (nonatomic,assign)BOOL isOwner;//是否是群主

@end

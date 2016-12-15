//
//  NBPersonalSettingViewController.h
//  BJEducation
//
//  Created by liujiaming on 16/11/22.
//  Copyright © 2016年 com.bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJChatInfo.h"

//加入黑名单操作
extern NSString *const NBContactBlacklistNotification;

@interface NBPersonalSettingViewController : UIViewController

@property (nonatomic,strong)BJChatInfo *bjChatInfo;

@end

//
//  ChatViewController.h
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/22.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJChatInfo.h"
@interface BJChatViewController : UIViewController
@property (strong, nonatomic, readonly) BJChatInfo *chatInfo;
- (instancetype)initWithChatInfo:(BJChatInfo *)chatInfo;

//展示群组新的通知
- (void)showGroupNewNotice;
//展示群组通知
- (void)showGroupNotice;

@end

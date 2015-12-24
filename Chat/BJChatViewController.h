//
//  ChatViewController.h
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/22.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJChatInfo.h"
typedef void (^OpenURL)(NSString*url);
@interface BJChatViewController : UIViewController
@property (strong, nonatomic, readonly) BJChatInfo *chatInfo;
@property (nonatomic,copy)OpenURL openURL;
- (instancetype)initWithChatInfo:(BJChatInfo *)chatInfo;

//展示群组通知
- (void)showGroupNotice;

@end

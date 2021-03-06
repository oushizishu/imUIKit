/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "UIResponder+BJIMChatRouter.h"
NSString *const kBJRouterEventImageBubbleTapEventName = @"kBJRouterEventImageBubbleTapEventName";
NSString *const kBJRouterEventAudioBubbleTapEventName = @"kBJRouterEventAudioBubbleTapEventName";
NSString *const kBJRouterEventCardEventName = @"kRouterEventChatCellBubbleCardEventName";
NSString *const kBJRouterEventUserInfoObject = @"kBJRouterEventUserInfoObject";
NSString *const kBJRouterEventChatCellHeadTapEventName = @"kBJRouterEventChatCellHeadTapEventName";
NSString *const kBJRouterEventChatCellBubbleTapEventName = @"kBJRouterEventChatCellBubbleTapEventName";
NSString *const kBJRouterEventChatCellBubbleLongTapEventName = @"kBJRouterEventChatCellBubbleLongTapEventName";
NSString *const kBJResendButtonTapEventName = @"kBJResendButtonTapEventName";

NSString *const kBJRouterEventLinkName = @"kBJRouterEventLinkName";
NSString *const kBJRouterEventPhoneCall = @"kBJRouterEventPhoneCall";

@implementation UIResponder (BJIMChatRouter)

- (void)bjim_routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    [[self nextResponder] bjim_routerEventWithName:eventName userInfo:userInfo];
}

@end

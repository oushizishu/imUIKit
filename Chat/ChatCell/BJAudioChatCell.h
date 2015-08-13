//
//  BJAudioChatCell.h
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/27.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJChatBaseCell.h"

#define AUDIOLENGTH_MAX_WIDTH 60
#define AUDIOSHOW_MAX_WIDTH 200.0f

@interface BJAudioChatCell : BJChatBaseCell
-(void)startAudioAnimation;
-(void)stopAudioAnimation;
@end

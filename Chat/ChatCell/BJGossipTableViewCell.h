//
//  BJTipTextTableViewCell.h
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/29.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IMMessage.h>
#import "BJChatViewCellProtocol.h"

#define BJ_GOSSIP_FONTSIZE 11
#define BJ_GOSSIP_FONTCOLOR @"#9d9e9e"
#define BJ_GOOSIP_BACKCOLOR @"#dcddde"
#define BJ_GOSSIP_TEXTMAXWIDTH 180.0f
#define BJ_GOSSIP_MARGIN 10
#define BJ_GOSSIP_LINESPAC 5

@interface BJGossipTableViewCell : UITableViewCell<BJChatViewCellProtocol>
@property (strong, nonatomic)IMMessage *message;
@property (strong, nonatomic)NSIndexPath *indexPath;
@end

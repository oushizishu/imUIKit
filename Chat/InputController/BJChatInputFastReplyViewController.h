//
//  BJChatInputFastReplyViewController.h
//  BJEducation_Institution
//
//  Created by Lina on 16/11/2.
//  Copyright © 2016年 com.bjhl. All rights reserved.
//

#import "BJChatInputBaseViewController.h"
#import "BJChatInputProtocol.h"

typedef void (^SelectedFastReplyAction)(NSString *content);

@interface BJChatInputFastReplyViewController : BJChatInputBaseViewController
@property (nonatomic,copy) SelectedFastReplyAction actionBlock;
- (void)requstServer;
@end

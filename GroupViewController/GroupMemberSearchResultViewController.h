//
//  GroupMemberSearchResultViewController.h
//  BJEducation
//
//  Created by Mac_ZL on 17/2/16.
//  Copyright © 2017年 com.bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BaseCellMode;
@interface GroupMemberSearchResultViewController : UIViewController

@property (nonatomic,assign) int64_t groupId;
@property (nonatomic,copy)void (^searchBarCancelBlock)(void);
@property (nonatomic,copy)void (^selectMemberBlock)(BaseCellMode *model);


@end
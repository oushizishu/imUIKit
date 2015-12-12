//
//  IMGroupUserCellMode.h
//  说明:群成员cellmode
//  Created by wangziliang on 15/12/4.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "BaseCellMode.h"
#import <BJHL-IM-iOS-SDK/GroupDetail.h>

@class IMGroupUserCellMode;

@protocol IMGroupUserCellModeDelegate <NSObject>

- (void)setGroupUserAdmin:(IMGroupUserCellMode*)cellMode;
- (void)cancelGroupUserAmin:(IMGroupUserCellMode*)cellMode;
- (void)tranferGroupUser:(IMGroupUserCellMode*)cellMode;
- (void)removeGroupUser:(IMGroupUserCellMode*)cellMode;

@end

typedef NS_ENUM(NSInteger, IMGroupUserCellModeMenuType)
{
    KIMGroupUserCellModeMenuType_NoMenu = 1,
    KIMGroupUserCellModeMenuType_Delete = 2,
    KIMGroupUserCellModeMenuType_DeleteAndMore = 3,
};

@interface IMGroupUserCell : BaseModeCell

@end

@interface IMGroupUserCellMode : BaseCellMode

@property (weak ,nonatomic) id<IMGroupUserCellModeDelegate> groupUserDelegate;
@property (strong ,nonatomic) GroupDetailMember *GroupDetailMember;
@property (nonatomic) BOOL operaterIsAdmin;
@property (nonatomic) BOOL operaterIsMajor;
@property (nonatomic) BOOL ifShowMenu;

-(instancetype)initWithGroupDetailMember:(GroupDetailMember*)member;

-(IMGroupUserCellModeMenuType)getMenuType;

-(void)deleteAction;
-(void)moreAction;

@end

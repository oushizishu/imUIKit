//
//  IMAnnouncementCellMode.h
//  说明：群公告cellmode
//  Created by wangziliang on 15/12/2.
//

#import "BaseCellMode.h"
#import <Mantle.h>
#import <BJHL-IM-iOS-SDK/GroupDetail.h>

@interface IMAnnouncementCell : BaseModeCell

@end

@interface IMAnnouncementCellMode : BaseCellMode

@property(strong ,nonatomic)GroupNotice *groupNotice;

@property(nonatomic)BOOL ifCanDelete;

@property(strong ,nonatomic)NSArray *contentArray;

-(instancetype)initWithGroupNotice:(GroupNotice*)groupNotice;

-(void)deleteAnnouncement;

@end

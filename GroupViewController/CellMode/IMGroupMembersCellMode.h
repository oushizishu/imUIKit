//
//  IMGroupMembersCellMode.h
//  说明:群详情页显示群组成员cellmode
//  Created by wangziliang on 15/12/3.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "BaseCellMode.h"

@interface IMGroupMembersCell : BaseModeCell

@end

@interface IMGroupMembersCellMode : BaseCellMode

@property(strong ,nonatomic)NSArray *memberArray;

@end

//
//  IMGroupTeachersCellMode.h
//  说明:详情页中显示的主讲老师头像姓名显示cellmode
//  Created by wangziliang on 15/12/4.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "BaseCellMode.h"
#import <BJHL-IM-iOS-SDK/GroupDetail.h>

@interface GroupTeacherView : UIView

-(void)setGroupTeacher:(GroupTeacher*)teacher;

@end

@interface IMGroupTeachersCell : BaseModeCell

@end

@interface IMGroupTeachersCellMode : BaseCellMode

@property (strong ,nonatomic)NSArray<GroupTeacher *> *teacherArray;

@end

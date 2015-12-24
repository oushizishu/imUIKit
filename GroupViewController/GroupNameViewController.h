//
//  GroupNameViewController.h
//  说明：群名称页
//  Created by wangziliang on 15/12/4.
//

#import <UIKit/UIKit.h>
#import <BJHL-IM-iOS-SDK/GroupDetail.h>

@interface GroupNameViewController : UIViewController

-(instancetype)initWithGroudId:(NSString*)groudId withGroupDetail:(GroupDetail*)groupDetail;

@end

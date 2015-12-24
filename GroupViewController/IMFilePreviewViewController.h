//
//  IMFilePreviewViewController.h
//  说明:文件预览模块
//  Created by wangziliang on 15/12/10.
//

#import <UIKit/UIKit.h>
#import <BJHL-IM-iOS-SDK/GroupDetail.h>

@interface IMFilePreviewViewController : UIViewController

- (instancetype)initWithGroupFile:(NSString*)groudId withGroupFile:(GroupFile*)groupFile;

@end

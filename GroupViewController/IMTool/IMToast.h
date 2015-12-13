//
//  IMToast.h
//  说明：toast通知控件封装
//  Created by wangziliang on 15/12/12.
//

#import <UIKit/UIKit.h>

@interface IMToast : UIView

+(IMToast*)showThenHidden:(NSString*)content withView:(UIView*)view afterDelay:(NSTimeInterval)delay;

@end

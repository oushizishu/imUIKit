//
//  IMDialog.h
//
//  Created by wangziliang on 15/12/18.
//

#import <UIKit/UIKit.h>

typedef void (^IMDialogComfire)();
typedef void (^IMDialogCancel)();

@interface IMDialog : UIViewController

-(void)showWithContent:(NSString*)content withSelectBlock:(IMDialogComfire)comfire withCancelBlock:(IMDialogCancel)cancel;

@end

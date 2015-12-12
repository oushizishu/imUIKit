//
//  IMSingleSelectDialog.h
//  说明:单选对话框封装
//  Created by wangziliang on 15/12/7.
//

#import <UIKit/UIKit.h>

typedef void (^IMUserSelectBlock)(NSInteger index);
typedef void (^IMUserCancelBlock)();


@interface IMSelectItem : UIView

- (instancetype)initWithFrame:(CGRect)frame withContent:(NSString*)content;

- (void)setItemSelectState:(BOOL)state;

@end

@interface IMSingleSelectDialog : UIViewController

-(void)showWithTitle:(NSString*)title withArray:(NSArray<NSString *> *)array withSelectBlock:(IMUserSelectBlock)userSelect withCancelBlock:(IMUserCancelBlock)userCancel;

@end

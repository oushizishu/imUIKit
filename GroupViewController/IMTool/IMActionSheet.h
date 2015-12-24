//
//  IMActionSheet.h
//  BJEducation_student
//
//  Created by bjhl on 15/12/10.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^IMActionSheetSelectBlock)(NSInteger index);
typedef void (^IMActionSheetCancelBlock)();

@interface IMActionSheetItem : UIView

- (instancetype)initWithFrame:(CGRect)frame withContent:(NSString*)content selectState:(BOOL)state;

@end

@interface IMActionSheet : UIViewController

-(void)showWithTitle:(NSString*)title
           withArray:(NSArray<NSString *> *)array
        withCurIndex:(NSInteger)index
     withSelectBlock:(IMActionSheetSelectBlock)userSelect
     withCancelBlock:(IMActionSheetCancelBlock)userCancel;



@end

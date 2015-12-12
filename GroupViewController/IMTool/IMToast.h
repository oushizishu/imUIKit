//
//  IMToast.h
//  BJEducation_student
//
//  Created by bjhl on 15/12/12.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMToast : UIView

+(IMToast*)makeToast:(NSString*)content withView:(UIView*)view;

-(void)show;

@end

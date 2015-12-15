//
//  IMInputDialog.h
//  BJEducation_student
//
//  Created by bjhl on 15/12/15.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^IMUserInputComplete)(NSString *content);
typedef void (^IMUserInputCancel)();

@interface IMInputDialog : UIViewController

-(void)showWithDefaultContent:(NSString*)content withInputComplete:(IMUserInputComplete)complete withInputCancel:(IMUserInputCancel)cancel;

@end

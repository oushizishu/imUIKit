//
//  BJAudioShowCalculation.h
//  BJEducation_student
//
//  Created by bjhl on 15/8/11.
//  Copyright (c) 2015年 Baijiahulian. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BJ_AUDIOSHOW_MAXLENGTH 200.0f
#define BJ_AUDIOSHOW_MINLENGTH 80.0f
#define BJ_AUDIOSHOW_DEFAULTUNITL 10.0f

@interface BJAudioShowCalculation : NSObject

@property(nonatomic)CGFloat curShowLength;
@property(nonatomic)NSInteger curTimeLength;

+ (instancetype)sharedInstance;

-(CGFloat)calculationShowWidth:(NSInteger)timeLength;
-(void)reset;

@end
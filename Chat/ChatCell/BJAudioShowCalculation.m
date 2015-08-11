//
//  BJAudioShowCalculation.m
//  BJEducation_student
//
//  Created by bjhl on 15/8/11.
//  Copyright (c) 2015年 Baijiahulian. All rights reserved.
//

#import "BJAudioShowCalculation.h"

@implementation BJAudioShowCalculation

+ (instancetype)sharedInstance
{
    static BJAudioShowCalculation *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super alloc] init];
    });
    return _sharedInstance;
}

-(instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _curShowLength = 0.0f;
    _curTimeLength = 0;
    
    return self;
}

-(CGFloat)calculationShowWidth:(NSInteger)timeLength
{
    if (timeLength>0) {
        CGFloat unitl = 0.0f;
        if (_curTimeLength == 0) {
            unitl = BJ_AUDIOSHOW_DEFAULTUNITL;
        }else
        {
            unitl = _curShowLength/_curTimeLength;
        }
        
        CGFloat newL = timeLength*unitl;
        
        if (newL<=_curTimeLength) {
            if (newL < BJ_AUDIOSHOW_MINLENGTH) {
                newL = BJ_AUDIOSHOW_MINLENGTH;
            }
        }else
        {
            CGFloat permissionL = _curShowLength+(BJ_AUDIOSHOW_MAXLENGTH-_curShowLength)/2;
            if (newL>permissionL) {
                newL = permissionL;
            }
            if (newL < BJ_AUDIOSHOW_MINLENGTH) {
                newL = BJ_AUDIOSHOW_MINLENGTH;
            }
        }
        
        if (newL > _curShowLength) {
            _curShowLength = newL;
            _curTimeLength = timeLength;
        }
        
        return newL;
    }else
    {
        return BJ_AUDIOSHOW_MINLENGTH;
    }
}

-(void)reset
{
    _curTimeLength = 0.0f;
    _curTimeLength = 0;
}

@end

//
//  IMToast.m
//  BJEducation_student
//
//  Created by bjhl on 15/12/12.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "IMToast.h"
#import "IMLinshiTool.h"

#define IMTOAST_FRAME_INTERVAL 20
#define IMTOAST_CONTENTINTERVAL_TOP 10
#define IMTOAST_CONTENTINTERVAL_BOTTOM 10
#define IMTOAST_CONTENTINTERVAL_LEFT 40
#define IMTOAST_CONTENTINTERVAL_RIGHT 20
#define IMTOAST_CONTENTINTERVAL_SPROW 5
#define IMTOAST_CONTENTINTERVAL_HEIGHTROW 20
#define IMTOAST_CONTENTINTERVAL_MAXCOUNT 5

@interface IMToast()

@end

@implementation IMToast

+(IMToast*)makeToast:(NSString*)content withView:(UIView*)view
{
    IMToast *toast = nil;
    
    CGFloat contentW = view.frame.size.width-IMTOAST_FRAME_INTERVAL*2-IMTOAST_CONTENTINTERVAL_LEFT-IMTOAST_CONTENTINTERVAL_RIGHT;
    UIFont *font = [UIFont systemFontOfSize:16.0f];
    if (contentW > 20) {
        NSArray *array = [IMLinshiTool splitMsg:content withFont:font withMaxWid:contentW];
        
        if (array != nil && [array count] > 0) {
            if ([array count] == 1) {
                contentW = [content sizeWithFont:font].width;
            }
            if ([array count]>IMTOAST_CONTENTINTERVAL_MAXCOUNT) {
                array = [array subarrayWithRange:NSMakeRange(0, IMTOAST_CONTENTINTERVAL_MAXCOUNT)];
            }
            
            toast = [[IMToast alloc] initWithFrame:CGRectMake((view.frame.size.width-contentW-IMTOAST_CONTENTINTERVAL_RIGHT-IMTOAST_CONTENTINTERVAL_LEFT)/2, 0,contentW+IMTOAST_CONTENTINTERVAL_RIGHT+IMTOAST_CONTENTINTERVAL_LEFT , ([array count]-1)*IMTOAST_CONTENTINTERVAL_SPROW+[array count]*IMTOAST_CONTENTINTERVAL_HEIGHTROW+IMTOAST_CONTENTINTERVAL_TOP+IMTOAST_CONTENTINTERVAL_BOTTOM) withContentArray:array];
        }
    }
    
    if (toast != nil) {
        [view addSubview:toast];
        toast.hidden = YES;
    }
    return toast;
}

-(instancetype)initWithFrame:(CGRect)frame withContentArray:(NSArray<NSString *> *)contentArray;
{
    self = [self initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((IMTOAST_CONTENTINTERVAL_LEFT-20)/2, IMTOAST_CONTENTINTERVAL_TOP, 20, 20)];
        [imageView setImage:[UIImage imageNamed:@"ic_horn"]];
        [self addSubview:imageView];
        
        for (int i = 0; i < [contentArray count]; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(IMTOAST_CONTENTINTERVAL_LEFT, IMTOAST_CONTENTINTERVAL_TOP+(IMTOAST_CONTENTINTERVAL_HEIGHTROW+IMTOAST_CONTENTINTERVAL_SPROW)*i, frame.size.width-(IMTOAST_CONTENTINTERVAL_LEFT+IMTOAST_CONTENTINTERVAL_RIGHT), IMTOAST_CONTENTINTERVAL_HEIGHTROW)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:16.0f];
            label.textAlignment = NSTextAlignmentLeft;
            label.text = [contentArray objectAtIndex:i];
            [self addSubview:label];
        }
        
    }
    return self;
}

-(void)show
{
    self.hidden = NO;
    [self performSelector:@selector(hindden) withObject:self afterDelay:10];
}

-(void)hindden
{
    [self removeFromSuperview];
}

@end

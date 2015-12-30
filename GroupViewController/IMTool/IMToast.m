//
//  IMToast.m
//
//  Created by wangziliang on 15/12/12.
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
#define IMTOAST_CONTENTINTERVAL_MAXCOUNT 2

@interface IMToast()

@property(strong ,nonatomic)UIImageView *imageView;
@property(strong ,nonatomic)NSMutableArray<UILabel *> *contentLArray;

@end

@implementation IMToast

+(instancetype)shareInstance
{
    static IMToast *_imToast = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imToast = [[self alloc] initWithFrame:CGRectZero];
    });
    return _imToast;
}

+(IMToast*)showThenHidden:(NSString*)content withView:(UIView*)view afterDelay:(NSTimeInterval)delay
{
    IMToast *toast = [self shareInstance];
    
    toast.frame = CGRectZero;
    
    CGFloat contentW = view.frame.size.width-IMTOAST_FRAME_INTERVAL*2-IMTOAST_CONTENTINTERVAL_LEFT-IMTOAST_CONTENTINTERVAL_RIGHT;
    UIFont *font = [UIFont systemFontOfSize:16.0f];
    if (contentW > 20) {
        NSArray *array = [IMLinshiTool splitMsg:content withFont:font withMaxWid:contentW];
        NSMutableArray *mArray = [[NSMutableArray alloc] init];
        
        if (array != nil && [array count] > 0) {
            if ([array count] == 1) {
                contentW = [content sizeWithFont:font].width;
            }
            if ([array count]>IMTOAST_CONTENTINTERVAL_MAXCOUNT) {
                [mArray addObjectsFromArray:[array subarrayWithRange:NSMakeRange(0, IMTOAST_CONTENTINTERVAL_MAXCOUNT-1)]];
                NSMutableString *mString = [[NSMutableString alloc] init];
                for (int i = IMTOAST_CONTENTINTERVAL_MAXCOUNT-1; i < [array count]; i++) {
                    [mString appendString:[array objectAtIndex:i]];
                }
                [mArray addObject:mString];
            }else
            {
                [mArray addObjectsFromArray:array];
            }
            
            [toast showThenHidden:CGRectMake((view.frame.size.width-contentW-IMTOAST_CONTENTINTERVAL_RIGHT-IMTOAST_CONTENTINTERVAL_LEFT)/2, 0,contentW+IMTOAST_CONTENTINTERVAL_RIGHT+IMTOAST_CONTENTINTERVAL_LEFT , ([array count]-1)*IMTOAST_CONTENTINTERVAL_SPROW+[array count]*IMTOAST_CONTENTINTERVAL_HEIGHTROW+IMTOAST_CONTENTINTERVAL_TOP+IMTOAST_CONTENTINTERVAL_BOTTOM) withWithContentArray:mArray afterDelay:delay];
        }
    }
    
    [view addSubview:toast];
    return toast;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)showThenHidden:(CGRect)frame withWithContentArray:(NSArray<NSString *> *)contentArray afterDelay:(NSTimeInterval)delay;
{
    if (self.imageView != nil) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    
    for (int i = 0; i < [self.contentLArray count]; i++) {
        UILabel *itemL = [self.contentLArray objectAtIndex:i];
        [itemL removeFromSuperview];
    }
    [self.contentLArray removeAllObjects];
    
    self.frame = frame;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((IMTOAST_CONTENTINTERVAL_LEFT-20)/2, IMTOAST_CONTENTINTERVAL_TOP, 20, 20)];
    [self.imageView setImage:[UIImage imageNamed:@"ic_horn"]];
    [self addSubview:self.imageView];
    
    for (int i = 0; i < [contentArray count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(IMTOAST_CONTENTINTERVAL_LEFT, IMTOAST_CONTENTINTERVAL_TOP+(IMTOAST_CONTENTINTERVAL_HEIGHTROW+IMTOAST_CONTENTINTERVAL_SPROW)*i, frame.size.width-(IMTOAST_CONTENTINTERVAL_LEFT+IMTOAST_CONTENTINTERVAL_RIGHT), IMTOAST_CONTENTINTERVAL_HEIGHTROW)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:16.0f];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = [contentArray objectAtIndex:i];
        [self addSubview:label];
        [self.contentLArray addObject:label];
    }
    
    [IMToast cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidden) object:nil];
    [self performSelector:@selector(hidden) withObject:nil afterDelay:delay];
}

-(void)hidden
{
    [self removeFromSuperview];
}

- (NSMutableArray<UILabel *> *)contentLArray
{
    if (_contentLArray == nil) {
        _contentLArray = [[NSMutableArray alloc] init];
    }
    return _contentLArray;
}

@end

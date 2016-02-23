//
//  IMSingleSelectDialog.m
//
//  Created by wangziliang on 15/12/7.
//

#import "IMSingleSelectDialog.h"
#import <BJHL-Common-iOS-SDK/UIColor+Util.h>

@protocol IMSelectItemDelegate <NSObject>

- (void)userHitItem:(IMSelectItem*)item;

@end

@interface IMSelectItem()

@property (weak ,nonatomic)id<IMSelectItemDelegate> delegate;
@property (strong ,nonatomic)UIView *bCView;
@property (strong ,nonatomic)UIView *sCView;
@property (strong ,nonatomic)UILabel *contenrtLabel;

@property (nonatomic) BOOL selectState;

@end

@implementation IMSelectItem

- (instancetype)initWithFrame:(CGRect)frame withContent:(NSString*)content
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.bCView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/6, 0, 20, 20)];
        self.bCView.backgroundColor = [UIColor clearColor];
        [self.bCView.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.bCView.layer setBorderWidth:0.5f];
        [self.bCView.layer setCornerRadius:10.0f];
        self.bCView.layer.masksToBounds = YES;
        [self addSubview:self.bCView];
        
        UITapGestureRecognizer *hitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bCViewPressed:)];
        [self.bCView addGestureRecognizer:hitTap];
        
        self.sCView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 10, 10)];
        self.sCView.backgroundColor = [UIColor orangeColor];
        [self.sCView.layer setCornerRadius:5.0f];
        self.sCView.layer.masksToBounds = YES;
        [self.bCView addSubview:self.sCView];
        self.sCView.hidden = YES;
        
        self.selectState = NO;
        
        self.contenrtLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/6+20+10, 0, frame.size.width*2/3-(20+10), 20)];
        self.contenrtLabel.font = [UIFont systemFontOfSize:14.0f];
        self.contenrtLabel.textColor = [UIColor blackColor];
        self.contenrtLabel.textAlignment = NSTextAlignmentLeft;
        self.contenrtLabel.text = content;
        [self addSubview:self.contenrtLabel];
        
    }
    return self;
}

- (void)bCViewPressed:(id)sender
{
    if (self.delegate != nil) {
        [self.delegate userHitItem:self];
    }
}


- (void)setItemSelectState:(BOOL)state
{
    if (self.selectState != state) {
        self.selectState = state;
        if (self.selectState) {
            [self.bCView.layer setBorderColor:[UIColor orangeColor].CGColor];
            self.sCView.hidden = NO;
        }else
        {
            [self.bCView.layer setBorderColor:[UIColor grayColor].CGColor];
            self.sCView.hidden = YES;
        }
    }
}

@end

@interface IMSingleSelectDialog()<IMSelectItemDelegate>

@property (strong ,nonatomic)UIView *contentView;
@property (strong ,nonatomic)UILabel *titleLabel;
@property (strong ,nonatomic)UIScrollView *scrollView;
@property (strong ,nonatomic)UIButton *cancelBtn;
@property (strong ,nonatomic)UIButton *comfireBtn;

@property (strong ,nonatomic)NSMutableArray *selectItemArray;
@property (weak ,nonatomic)IMSelectItem *curSelectItem;

@property (copy ,nonatomic)IMUserSelectBlock userSelectBlock;
@property (copy ,nonatomic)IMUserCancelBlock userCancelBlock;

@end

@implementation IMSingleSelectDialog

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

-(void)showWithTitle:(NSString*)title withArray:(NSArray<NSString *> *)array withSelectBlock:(IMUserSelectBlock)userSelect withCancelBlock:(IMUserCancelBlock)userCancel
{
    CGRect sRect = [UIScreen mainScreen].bounds;
    
    self.userSelectBlock = userSelect;
    self.userCancelBlock = userCancel;
    
    NSInteger arrayCount = 0;
    if (array != nil) {
        arrayCount = [array count];
    }
    CGFloat scrollH = 35*arrayCount;
    
    if (scrollH > (sRect.size.height*2/3-88)) {
        scrollH = sRect.size.height*2/3-88;
    }
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(sRect.size.width/8, (sRect.size.height-(scrollH+88))/2, sRect.size.width-sRect.size.width/4, scrollH+88)];
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#f7f9fa"];
    self.contentView.layer.masksToBounds = YES;
    [self.contentView.layer setCornerRadius:5.0f];
    [self.view addSubview:self.contentView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, self.contentView.frame.size.width, 20)];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = title;
    [self.contentView addSubview:self.titleLabel];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, self.contentView.frame.size.width, scrollH)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.scrollView];
    
    if (arrayCount*35>scrollH) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, arrayCount*35);
    }
    
    self.selectItemArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < arrayCount; i++) {
        IMSelectItem *item = [[IMSelectItem alloc] initWithFrame:CGRectMake(0,35*i ,self.scrollView.frame.size.width ,20) withContent:[array objectAtIndex:i]];
        item.delegate = self;
        [self.selectItemArray addObject:item];
        [self.scrollView addSubview:item];
    }
    
    if ([self.selectItemArray count] > 0) {
        self.curSelectItem = [self.selectItemArray firstObject];
        [self.curSelectItem setItemSelectState:YES];
    }
    
    UIView *lineW = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-44, self.contentView.frame.size.width, 0.5)];
    lineW.backgroundColor = [UIColor colorWithHexString:@"#dcddde"];
    [self.contentView addSubview:lineW];
    
    UIView *lineH = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height-44, 0.5, 50)];
    lineH.backgroundColor = [UIColor colorWithHexString:@"#dcddde"];
    [self.contentView addSubview:lineH];
    
    self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-44, self.contentView.frame.size.width/2, 44)];
    self.cancelBtn.backgroundColor = [UIColor clearColor];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.cancelBtn];
    
    self.comfireBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height-44, self.contentView.frame.size.width/2, 44)];
    self.comfireBtn.backgroundColor = [UIColor clearColor];
    [self.comfireBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.comfireBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.comfireBtn addTarget:self action:@selector(comfireBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.comfireBtn];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController addChildViewController:self];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.view];
    [self willMoveToParentViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    
}

- (void)cancelBtnAction
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    if (self.userCancelBlock) {
        self.userCancelBlock();
    }
    
//    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if(version < 7.0f || version >= 8.0f)
//    {
//        [self removeFromParentViewController];
//    }
}

- (void)comfireBtnAction
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    NSInteger index = 0;
    if (self.selectItemArray != nil && [self.selectItemArray containsObject:self.curSelectItem]) {
        index = [self.selectItemArray indexOfObject:self.curSelectItem];
    }
    if (self.userSelectBlock) {
        self.userSelectBlock(index);
    }
    
//    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if(version < 7.0f || version >= 8.0f)
//    {
//        [self removeFromParentViewController];
//    }
    
}

- (void)userHitItem:(IMSelectItem *)item
{
    if (item != self.curSelectItem) {
        if (self.curSelectItem != nil) {
            [self.curSelectItem setItemSelectState:NO];
        }
        self.curSelectItem = item;
        [self.curSelectItem setItemSelectState:YES];
    }
}

@end

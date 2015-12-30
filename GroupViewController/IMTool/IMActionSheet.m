//
//  IMActionSheet.m
//  BJEducation_student
//
//  Created by bjhl on 15/12/10.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "IMActionSheet.h"

@protocol IMActionSheetItemDelegate <NSObject>

- (void)actionSheetHitItem:(IMActionSheetItem*)item;

@end

@interface IMActionSheetItem()<UITabBarControllerDelegate>

@property (weak ,nonatomic)id<IMActionSheetItemDelegate> delegate;
@property (strong ,nonatomic)UILabel *contenrtLabel;
@property (strong ,nonatomic)UIImageView *flagImageView;

@property (nonatomic) BOOL selectState;

@end

@implementation IMActionSheetItem

- (instancetype)initWithFrame:(CGRect)frame withContent:(NSString*)content selectState:(BOOL)state
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPressed:)];
        
        [self addGestureRecognizer:tap];
        
        self.selectState = state;
        
        CGFloat maxWid = 0;
        
        if (self.selectState) {
            maxWid = frame.size.width-90;
        }else
        {
            maxWid = frame.size.width-30;
        }
        
        UIFont *font = [UIFont systemFontOfSize:18.0f];
        
        CGSize contentSize = [content sizeWithFont:font];
        
        if (contentSize.width > maxWid) {
            contentSize.width = maxWid;
        }
        
        self.contenrtLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width-contentSize.width)/2, 0, contentSize.width, 20)];
        self.contenrtLabel.font = font;
        self.contenrtLabel.textColor = [UIColor blackColor];
        self.contenrtLabel.textAlignment = NSTextAlignmentCenter;
        self.contenrtLabel.text = content;
        [self addSubview:self.contenrtLabel];
        
        if (self.selectState) {
            self.contenrtLabel.textColor = [UIColor orangeColor];
            self.flagImageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-contentSize.width)/2+contentSize.width+10, 0, 20, 20)];
            [self.flagImageView setImage:[UIImage imageNamed:@"ic_cell_check"]];
            [self addSubview:self.flagImageView];
        }
        
    }
    return self;
}

- (void)ViewPressed:(id)sender
{
    if (self.delegate != nil) {
        [self.delegate actionSheetHitItem:self];
    }
}

- (void)viewPressed:(id)sender
{
    if (self.delegate != nil) {
        [self.delegate actionSheetHitItem:self];
    }
}


@end

@interface IMActionSheet()<IMActionSheetItemDelegate>

@property (strong ,nonatomic)UIView *contentView;
@property (strong ,nonatomic)UILabel *titleLabel;
@property (strong ,nonatomic)UIScrollView *scrollView;
@property (strong ,nonatomic)UIButton *cancelBtn;

@property (strong ,nonatomic)NSMutableArray *selectItemArray;

@property (copy ,nonatomic)IMActionSheetSelectBlock userSelectBlock;
@property (copy ,nonatomic)IMActionSheetCancelBlock userCancelBlock;

@end

@implementation IMActionSheet

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

-(void)showWithTitle:(NSString*)title
           withArray:(NSArray<NSString *> *)array
        withCurIndex:(NSInteger)index
     withSelectBlock:(IMActionSheetSelectBlock)userSelect
     withCancelBlock:(IMActionSheetCancelBlock)userCancel
{
    CGRect sRect = [UIScreen mainScreen].bounds;
    
    self.userSelectBlock = userSelect;
    self.userCancelBlock = userCancel;
    
    NSInteger arrayCount = 0;
    if (array != nil) {
        arrayCount = [array count];
    }
    CGFloat scrollH = 50*arrayCount;
    
    if (scrollH > sRect.size.height/2) {
        scrollH = sRect.size.height/2-110;
    }
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, sRect.size.height-(scrollH + 110), sRect.size.width,scrollH+110)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.contentView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, self.contentView.frame.size.width, 20)];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = title;
    [self.contentView addSubview:self.titleLabel];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, self.contentView.frame.size.width, scrollH)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.scrollView];
    
    if (arrayCount*50>scrollH) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, arrayCount*50);
    }
    
    self.selectItemArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < arrayCount; i++) {
        IMActionSheetItem *item = nil;
        if (index == i) {
            item = [[IMActionSheetItem alloc] initWithFrame:CGRectMake(0,50*i+10 ,self.scrollView.frame.size.width ,20) withContent:[array objectAtIndex:i] selectState:YES];
        }else
        {
            item = [[IMActionSheetItem alloc] initWithFrame:CGRectMake(0,50*i+10 ,self.scrollView.frame.size.width ,20) withContent:[array objectAtIndex:i] selectState:NO];
        }
        item.delegate = self;
        [self.selectItemArray addObject:item];
        [self.scrollView addSubview:item];
    }
    
    UIView *spView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-60, self.contentView.frame.size.width, 10)];
    spView.backgroundColor = [UIColor colorWithHexString:@"#ebeced"];
    [self.contentView addSubview:spView];
    
    self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-50, self.contentView.frame.size.width, 50)];
    self.cancelBtn.backgroundColor = [UIColor clearColor];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.cancelBtn];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController addChildViewController:self];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.view];
    [self willMoveToParentViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    
}

- (void)cancelBtnAction
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
//    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if(version < 7.0f || version >= 8.0f)
//    {
//        [self removeFromParentViewController];
//    }
    
    if (self.userCancelBlock) {
        self.userCancelBlock();
    }
}

- (void)actionSheetHitItem:(IMActionSheetItem *)item
{
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
//    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if(version < 7.0f || version >= 8.0f)
//    {
//        [self removeFromParentViewController];
//    }
    
    
    NSInteger index = -1;
    if (self.selectItemArray != nil && [self.selectItemArray containsObject:item]) {
        index = [self.selectItemArray indexOfObject:item];
    }
    if (self.userSelectBlock) {
        self.userSelectBlock(index);
    }
}


@end

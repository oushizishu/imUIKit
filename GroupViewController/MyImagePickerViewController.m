//
//  MyImagePickerViewController.m
//
//  Created by wangziliang on 15/12/8.
//

#import "MyImagePickerViewController.h"
#import <BJHL-Common-iOS-SDK/UIColor+Util.h>
#import <BJHL-Common-iOS-SDK/BJCommonDefines.h>

@interface CollectionItemCell()

@property(strong ,nonatomic)UIImageView *imageImage;

@end

@implementation CollectionItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageImage.backgroundColor = [UIColor grayColor];
        [self addSubview:self.imageImage];
    }
    return self;
}

- (void)setMyCellMode:(CollectionItemCellMode*)mode
{
    [self.imageImage setImage:[UIImage imageWithCGImage:[mode.asset thumbnail]]];
    
}

@end

@implementation CollectionItemCellMode

- (instancetype)initWithAsset:(ALAsset*)asset
{
    self = [super init];
    if (self) {
        self.asset = asset;
    }
    return self;
}

@end

@interface MyImagePickerViewController()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

//资源库遍历工具
@property(strong,nonatomic)ALAssetsLibrary *alAssetsLibrary;
@property(strong,nonatomic)UICollectionView *collectionView;

@property(strong,nonatomic)NSMutableArray *modeArray;

@end

@implementation MyImagePickerViewController

-(BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ebeced"];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 14, 22)];
    [backBtn setImage:[UIImage imageNamed:@"im_black_leftarrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemBar = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = itemBar;
    
    self.title = @"图片";
    
    [self getCtrlArray];
    
}

-(void)getCtrlArray
{
    WS(weakself);
    self.alAssetsLibrary = [[ALAssetsLibrary alloc] init];
    dispatch_queue_t dispatchQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^(void) {
        // 遍历所有相册
        [self.alAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                            usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                                // 遍历每个相册中的项ALAsset
                                                
                                                if (group != nil) {
                                                    NSString* groupname = [group valueForProperty:ALAssetsGroupPropertyName];
                                                    if (groupname != nil) {
                                                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                        });
                                                        
                                                        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index,BOOL *stop) {
                                                            // ALAsset的类型
                                                            
                                                            if (result != nil) {
                                                                NSString *assetType = [result valueForProperty:ALAssetPropertyType];
                                                                if ([assetType isEqualToString:ALAssetTypePhoto]){
                                                                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                                        [weakself appendAssert:result];
                                                                    });
                                                                }
                                                            }
                                                            
                                                        }];
                                                    }
                                                }
                                                
                                            }
                                          failureBlock:^(NSError *error) {
                                              //NSLog(@"Failed to enumerate the asset groups.");
                                          }];
        
    });
}

- (void)appendAssert:(ALAsset*)asset
{
    CollectionItemCellMode *mode = [[CollectionItemCellMode alloc] initWithAsset:asset];
    [self.modeArray addObject:mode];
    [self.collectionView reloadData];
}

- (void)backAction:(id)aciton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.modeArray count];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1    ;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CollectionItemCell";
    CollectionItemCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell setMyCellMode:[self.modeArray objectAtIndex:indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect sRect = [UIScreen mainScreen].bounds;
    return CGSizeMake((sRect.size.width-40)/4, (sRect.size.width-40)/4);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionItemCellMode *cellMode = [self.modeArray objectAtIndex:indexPath.row];
    if (self.delegate) {
        [self.delegate MyimagePickerController:self withCellMode:cellMode];
    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        CGRect rectScreen = [UIScreen mainScreen].bounds;
        CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        CGRect rectNav = self.navigationController.navigationBar.frame;
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, rectScreen.size.height) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[CollectionItemCell class] forCellWithReuseIdentifier:@"CollectionItemCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (NSMutableArray*)modeArray
{
    if (_modeArray == nil) {
        _modeArray = [[NSMutableArray alloc] init];
    }
    return _modeArray;
}

@end

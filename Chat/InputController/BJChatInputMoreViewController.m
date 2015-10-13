//
//  BJChatInpuMoreViewController.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/27.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJChatInputMoreViewController.h"
#import <PureLayout.h>
#import "BJActionCollectionViewCell.h"
#import "BJSendMessageHelper.h"
#import "BJChatFileCacheManager.h"
#import "UIImage+compressionSize.h"
#import "BJChatLimitMacro.h"
#import "BJChatUtilsMacro.h"
#import "CouponTableViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>


@interface BJChatInputMoreViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *editList;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@end

@implementation BJChatInputMoreViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.editList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ChatInputMore" ofType:@"plist"]];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200);
    [self.view addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BJActionCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([BJActionCollectionViewCell class])];
}


#pragma mark - Action

- (void)sendImageMessage:(UIImage *)image
{
    if (image) {
        NSString *filePath = [BJChatFileCacheManager imageCachePathWithName:[BJChatFileCacheManager generateJpgImageName]];
        NSAssert(filePath.length>0, @"文件路径不能为空");
        //JEPG格式
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 处理耗时操作的代码块...
            NSData *data = [image bj_jpgDataWithCompressionSize:BJChat_Image_Max_SizeM];
            [data writeToFile:filePath atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                //通知主线程刷新
                [BJSendMessageHelper sendImageMessage:filePath imageSize:image.size chatInfo:self.chatInfo];
            });
        });
    }
}

- (void)showCameraView
{
    if ([self.delegate respondsToSelector:@selector(chatInputDidEndEdit)]) {
        [self.delegate chatInputDidEndEdit];
    }
#if TARGET_IPHONE_SIMULATOR
    @IMTODO("模拟器不支持拍照");
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    self.imagePicker.allowsEditing = YES;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeJPEG,(NSString *)kUTTypePNG];
    [self.navigationController presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
}

- (void)showPictureView
{
    if ([self.delegate respondsToSelector:@selector(chatInputDidEndEdit)]) {
        [self.delegate chatInputDidEndEdit];
    }
//    self.imagePicker.allowsEditing = YES;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeJPEG,(NSString *)kUTTypePNG];
    [self.navigationController presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)showCouponView
{
    if ([self.delegate respondsToSelector:@selector(chatInputDidEndEdit)]) {
        [self.delegate chatInputDidEndEdit];
    }

    CouponTableViewController *couponController = [[CouponTableViewController alloc] init];
    couponController.showCouponType = ShowCouponValid;
    couponController.isSingleChat = self.chatInfo.chat_t == eChatType_Chat ? YES : NO;
    if (couponController.isSingleChat) {
        couponController.dicContactInfo = self.chatInfo.chatToUser;
    } else {
        couponController.dicContactInfo = self.chatInfo.chatToGroup;
    }
    [self.navigationController pushViewController:couponController animated:YES];
}

- (void)didSelectWithKey:(NSString *)key;
{
    if ([key isEqualToString:@"picture"]) {
        [self showPictureView];
    }
    else if ([key isEqualToString:@"camera"])
    {
        [self showCameraView];
    }
    else if ([key isEqualToString:@"coupon"])
    {
        [self showCouponView];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self sendImageMessage:orgImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if ([self.chatInfo getToRole] == eUserRole_Teacher ||
        [self.chatInfo getToRole] == eUserRole_Kefu ||
        ![CommonInstance.mainAccount isAuthorized:eAuthorization_YouHuiQuan]) {
        return self.editList.count - 1;                 //对方为老师或客服不能发送优惠券
    } else {
        return self.editList.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BJActionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BJActionCollectionViewCell class]) forIndexPath:indexPath];
    if (!cell) {
        cell = [[BJActionCollectionViewCell alloc] init];
    }
    NSDictionary *editDic = [self.editList objectAtIndex:indexPath.row];
    NSString *imageName = [editDic objectForKey:@"icon"];
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.nameLabel.text = [editDic objectForKey:@"name"];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *editDic = [self.editList objectAtIndex:indexPath.row];
    [self didSelectWithKey:[editDic objectForKey:@"key"]];
}

#pragma mark - set get
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(60, 105);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 5;
        layout.sectionInset = UIEdgeInsetsMake(5, 15, 5, 15);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

@end

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

#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD+Simple.h"
#import "SendCourseListViewController.h"
#import "BJCouponManagerViewController.h"
#import "CardSimpleItem.h"
#import <User.h>

#import "NBAppConfiguration.h"
#import "WebPageViewController.h"
#import <BJHL-Kit-iOS/BJHL-Kit-iOS.h>

@interface BJChatInputMoreViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *editList;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@end

@implementation BJChatInputMoreViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    @IMTODO("发送优惠券");
    self.editList = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ChatInputMore" ofType:@"plist"]];
    User * user = self.chatInfo.chatToUser;
    if (user) {
        if ([user.name isEqualToString:@"跟谁学客服"]||[user.name isEqualToString:@"客服"]) {
            NSArray * arr = [NSArray arrayWithObjects:[self.editList firstObject],[self.editList objectAtIndex:1], nil];
            [self.editList removeAllObjects];
            [self.editList addObjectsFromArray:arr];
        }
    }
    if ([Profile currentProfile].isOrganization) {
        for (NSDictionary * dic in self.editList) {
            if ([[dic objectForKey:@"key"] isEqualToString:@"coupon"]) {
                [self.editList removeObject:dic];
            }
        }
    }
    self.view.autoresizingMask = UIViewAutoresizingNone;
    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 220);
    [self.view addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BJActionCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([BJActionCollectionViewCell class])];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCouponMessage:) name:@"sendCouponNotification" object:nil];
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
    
    // 友盟统计：消息-联系人聊天界面-拍照
    [MobClick event:@"20113"];
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
    
    // 友盟统计：消息-联系人聊天界面-相册
    [MobClick event:@"20114"];
}

- (void)showMyCardView{
//    if (![Profile currentProfile].canSearched) {
//        [MBProgressHUD showWindowMessageThenHide:@"审核上线后才能拥有名片哦"];
//        return;
//    }
    CardSimpleItem * item = [[CardSimpleItem alloc] init];
    item.url = [NSString stringWithFormat:@"%@/%lld", [BJDeployEnv sharedInstance].baseMAPIURLStr, CommonInstance.mainAccount.personId];
    [BJSendMessageHelper sendCardMessage:item chatInfo:self.chatInfo];
    
    // 友盟统计：消息-联系人聊天界面-我的名片
    [MobClick event:@"20115"];
}

- (void)showCourseView{
    SendCourseListViewController *send = [[SendCourseListViewController alloc] init];
    WS(weakSelf)
    send.selectCallback = ^(NSDictionary *dic){
        NSString *url = dic[@"detail_url"];
        [weakSelf sendCourseViewWithURL:url];
    };
    [self.navigationController pushViewController:send animated:YES];
    
    // 友盟统计：消息-联系人聊天界面-推广班课
    [MobClick event:@"20117"];
}

- (void)showCouponView{
//    IMChatType type = self.chatInfo.chat_t;
//    WS(weakSelf);
//    BJCouponManagerViewController *controller = [[BJCouponManagerViewController alloc]initWithState:BJCouponManagerControllerState_sendCoupon withSendCouponClick:^(NSString *searialNumber,NSString *url) {
//        [weakSelf sendCouponViewWithURL:url money:0];
//    } chatType:type?BJChatFromType_group:BJChatFromType_sigle];
//    [self.navigationController pushViewController:controller animated:YES];
    NBAppConfiguration *configuration = [NBAppConfiguration sharedInstance];
    NSURL *url = [NSURL URLWithString:[configuration.serverConfig.couponUrl valueForKey:@"from_im"]];
    WebPageViewController *webVC = [[WebPageViewController alloc]initWithURL:url];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)didSelectWithKey:(NSString *)key;
{
    if ([key isEqualToString:@"picture"]) {
        [self showPictureView];
    }
    else if ([key isEqualToString:@"camera"])
    {
        [self showCameraView];
    }else if ([key isEqualToString:@"card"]){
        [self showMyCardView];
    }else if ([key isEqualToString:@"course"]){
        [self showCourseView];
    }else if ([key isEqualToString:@"coupon"]){
        [self showCouponView];
    }
}

- (void)sendCourseViewWithURL:(NSString *)url{
    CardSimpleItem * item = [[CardSimpleItem alloc] init];
    item.url = url;
    [BJSendMessageHelper sendCardMessage:item chatInfo:self.chatInfo];
}

- (void)sendCouponViewWithURL:(NSString *)url money:(NSString *)money{
    CardSimpleItem * item = [[CardSimpleItem alloc] init];
    item.url = url;
    item.money = [money integerValue];
    [BJSendMessageHelper sendCardMessage:item chatInfo:self.chatInfo];
}

- (void)sendCouponMessage:(NSNotification*)notification{
    NSString *url = [[notification userInfo] stringValueForKey:@"url" defaultValue:@""];
    NSString *number = [[notification userInfo] stringValueForKey:@"number" defaultValue:@""];
    [self sendCouponViewWithURL:url money:number];
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
    return self.editList.count;
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
        CGSize itemSize = CGSizeMake(59, 80);
        layout.itemSize = itemSize;
        CGFloat lineSpace = ([UIScreen mainScreen].bounds.size.width - itemSize.width * 4) / 5.0f;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 13;
        layout.minimumLineSpacing = lineSpace;
        layout.sectionInset = UIEdgeInsetsMake(20, lineSpace, 27, lineSpace);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor bjck_colorWithHexString:@"#F4F4F6"];
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

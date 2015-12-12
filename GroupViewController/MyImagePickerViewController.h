//
//  MyImagePickerViewController.h
//
//  Created by wangziliang on 15/12/8.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class MyImagePickerViewController;
@class CollectionItemCellMode;

@protocol MyImagePickerViewControllerDelegate <NSObject>

-(void)MyimagePickerController:(MyImagePickerViewController*)picker withCellMode:(CollectionItemCellMode*)cellMode;

@end

@class CollectionItemCellMode;

@interface CollectionItemCell : UICollectionViewCell

- (void)setMyCellMode:(CollectionItemCellMode*)mode;

@end

@interface CollectionItemCellMode : NSObject

@property (strong ,nonatomic)ALAsset *asset;

- (instancetype)initWithAsset:(ALAsset*)asset;

@end

@interface MyImagePickerViewController : UIViewController

@property(weak ,nonatomic)id<MyImagePickerViewControllerDelegate> delegate;

@end

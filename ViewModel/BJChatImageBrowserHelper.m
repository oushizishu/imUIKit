

#import "BJChatImageBrowserHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BJChatImageBrowserHelper()

@property (strong, nonatomic) UIWindow *keyWindow;

@property (strong, nonatomic) NSMutableArray *photos;

@end

@implementation BJChatImageBrowserHelper

+ (instancetype)shareInstance
{
    static BJChatImageBrowserHelper *sharedMessageReadManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedMessageReadManager = [[self alloc] init];
    });
    return sharedMessageReadManager;
}

#pragma mark - getter

- (UIWindow *)keyWindow
{
    if(_keyWindow == nil)
    {
        _keyWindow = [[UIApplication sharedApplication] keyWindow];
    }
    
    return _keyWindow;
}

- (NSMutableArray *)photos
{
    if (_photos == nil) {
        _photos = [[NSMutableArray alloc] init];
    }
    
    return _photos;
}

- (BJPictueBrowser *)photoBrowser
{
    if (_photoBrowser == nil) {
        _photoBrowser = [[BJPictueBrowser alloc] initWithDelegate:self];
        [_photoBrowser setCurrentPhotoIndex:0];
    }
    
    return _photoBrowser;
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(BJPictueBrowser *)photoBrowser
{
    return [self.photos count];
}

- (id <BJPicture>)photoBrowser:(BJPictueBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.photos.count)
    {
        return [self.photos objectAtIndex:index];
    }
    
    return nil;
}

#pragma mark - private


#pragma mark - public

- (void)showBrowserWithImages:(NSArray *)imageArray
{
    if (imageArray && [imageArray count] > 0) {
        NSMutableArray *photoArray = [NSMutableArray array];
        for (id object in imageArray) {
            BJPicture *photo;
            if ([object isKindOfClass:[UIImage class]]) {
                photo = [BJPicture photoWithImage:object];
            }
            else if ([object isKindOfClass:[NSURL class]])
            {
                photo = [BJPicture photoWithURL:object];
            }
            else if ([object isKindOfClass:[NSString class]])
            {
                
            }
            [photoArray addObject:photo];
        }
        
        self.photos = photoArray;
    }
    
    UIViewController *rootController = [self.keyWindow rootViewController];
    BJPictueBrowser *browser = [[BJPictueBrowser alloc] initWithDelegate:self];

    [browser setCurrentPhotoIndex:0];
    
    [browser presentInViewController:rootController completion:nil];
}


@end

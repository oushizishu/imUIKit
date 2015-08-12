//
//  BJChatViewController+BrowserHelper.m
//  BJEducation_student
//
//  Created by Mrlu-bjhl on 15/8/12.
//  Copyright (c) 2015年 Baijiahulian. All rights reserved.
//

#import "BJChatViewController+BrowserHelper.h"
static const char *photoKey = "photoKey";
@implementation BJChatViewController (BrowserHelper)

- (void)setPhotos:(NSMutableArray *)photos
{
    objc_setAssociatedObject(self, photoKey, photos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableArray *)photos
{
    return (objc_getAssociatedObject(self, photoKey));
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
    
    BJPictueBrowser *browser = [[BJPictueBrowser alloc] initWithDelegate:self];
    
    [browser setCurrentPhotoIndex:0];
    
    [browser presentInViewController:self completion:nil];
}

@end

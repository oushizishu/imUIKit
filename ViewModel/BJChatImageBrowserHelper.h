

#import <Foundation/Foundation.h>

#import <BJHL-Common-iOS-SDK/BJPictueBrowser.h>

@interface BJChatImageBrowserHelper : NSObject<BJPictureBrowserDelegate>

@property (strong, nonatomic) BJPictueBrowser *photoBrowser;

+ (instancetype)shareInstance;

//default
- (void)showBrowserWithImages:(NSArray *)imageArray;

@end

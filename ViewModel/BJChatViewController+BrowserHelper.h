//
//  BJChatViewController+BrowserHelper.h
//  BJEducation_student
//
//  Created by Mrlu-bjhl on 15/8/12.
//  Copyright (c) 2015年 Baijiahulian. All rights reserved.
//

#import "BJChatViewController.h"
#import <BJHL-Common-iOS-SDK/BJPictueBrowser.h>

@interface BJChatViewController (BrowserHelper)<BJPictureBrowserDelegate>

@property (strong, nonatomic) NSMutableArray *photos;

//default
- (void)showBrowserWithImages:(NSArray *)imageArray;

@end

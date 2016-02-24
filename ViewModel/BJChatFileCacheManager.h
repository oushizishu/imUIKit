//
//  BJFileCacheManager.h
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/29.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BJHL-Foundation-iOS/BJHL-Foundation-iOS.h>
@interface BJChatFileCacheManager : NSObject
+ (NSString *)chatRootPath;
+ (NSString *)chatAudiosPath;
+ (NSString *)chatImagesPath;
+ (NSString *)chatUploadFilePath;
+ (NSString *)chatDownloadFilePath;
+ (NSString *)chatGroupFilePath;

+ (NSString *)imageCachePathWithName:(NSString *)imageName;
+ (NSString *)audioCachePathWithName:(NSString *)audioName;

//上传文件缓存路径
+ (NSString *)uploadFileCachePathwithName:(NSString *)fileName;
//下载文件缓存路径
+ (NSString *)downloadFileCacherPathWithName:(NSString *)fileName;
//群文件缓存路径
+ (NSString *)groupFileCachePathWithName:(NSString *)fileName;

/**
 *  相对于library 的路径 例如 .../library/caches/chat/audio/1.mp3 返回caches/chat/audio/1.mp3
 *
 *  @param imagName 文件名称
 *
 *  @return
 */
+ (NSString *)imageCacheRelativePathWithName:(NSString *)imagName;
+ (NSString *)audioCacheRelativePathWithName:(NSString *)audioName;

+ (NSString *)generateJpgImageName;
+ (NSString *)generateMp3AudioName;
@end

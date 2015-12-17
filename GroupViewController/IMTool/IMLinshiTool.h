//
//  IMLinshiTool.h
//
//  Created by wangziliang on 15/12/7.
//

#import <Foundation/Foundation.h>

#define IMFONTHEIGHT_BIG 15.0f
#define IMFONTHEIGHT_NORMAL 14.0f
#define IMFONTHETGHT_SAMALL 13.0f

#define IMCOLOT_GREY600 @"#3c3d3d"
#define IMCOLOT_GREY500 @"#6d6e6e"
#define IMCOLOT_GREY400 @"#9d9e9e"
#define IMCOLOT_GREY100 @"#f2f4f5"


@interface IMLinshiTool : NSObject

+ (NSString *) pinyinFromChineseString:(NSString *)string;

+ (NSString*)getStringWithStringByMD5:(NSString*)str;

+ (NSString*)getDocumnetsDirectory;

+ (BOOL)ifExistDircory:(NSString*)path;

+ (BOOL)ifExistFile:(NSString*)path;

+ (BOOL)createDirectory:(NSString*)path;

+ (NSInteger)getMsgLineCount:(NSString*)showMsg withFont:(UIFont*)font withMaxWid:(CGFloat)width;

+ (NSArray*)splitMsg:(NSString*)showMsg withFont:(UIFont*)font withMaxWid:(CGFloat)width;

+(long long) fileSizeAtPath:(NSString*) filePath;

+(NSString*)getSizeStrWithFileSize:(long long)fileSize;

@end

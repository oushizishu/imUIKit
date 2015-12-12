//
//  IMLinshiTool.h
//
//  Created by wangziliang on 15/12/7.
//

#import <Foundation/Foundation.h>

@interface IMLinshiTool : NSObject

+ (NSString *) pinyinFromChineseString:(NSString *)string;

+ (NSString*)getStringWithStringByMD5:(NSString*)str;

+ (NSString*)getDocumnetsDirectory;

+ (BOOL)ifExistDircory:(NSString*)path;

+ (BOOL)ifExistFile:(NSString*)path;

+ (BOOL)createDirectory:(NSString*)path;

+ (NSInteger)getMsgLineCount:(NSString*)showMsg withFont:(UIFont*)font withMaxWid:(CGFloat)width;

+ (NSArray*)splitMsg:(NSString*)showMsg withFont:(UIFont*)font withMaxWid:(CGFloat)width;

@end

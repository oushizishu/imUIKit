//
//  UtilsMacro.h
//  BJEducation_Institution
//
//  Created by Randy on 15/4/27.
//  Copyright (c) 2015年 com.bjhl. All rights reserved.
//

#ifndef BJChat_UtilsMacro_h
#define BJChat_UtilsMacro_h

#define BJChatColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// 转成字符串
#define BJIM_STRINGIFY(S) #S
// 需要解两次才解开的宏
#define BJIM_DEFER_STRINGIFY(S) BJIM_STRINGIFY(S)
#define BJIM_PRAGMA_MESSAGE(MSG) _Pragma(BJIM_STRINGIFY(message(MSG)))
// 为warning增加更多信息
#define BJIM_FORMATTED_MESSAGE(MSG) "[IMTODO-" BJIM_DEFER_STRINGIFY(__COUNTER__) "] " MSG " \n" BJIM_DEFER_STRINGIFY(__FILE__) " line " BJIM_DEFER_STRINGIFY(__LINE__)
// 使宏前面可以加@
#define BJIM_KEYWORDIFY try {} @catch (...) {}
// 最终使用的宏
#define IMTODO(MSG) BJIM_KEYWORDIFY BJIM_PRAGMA_MESSAGE(BJIM_FORMATTED_MESSAGE(MSG))

#endif

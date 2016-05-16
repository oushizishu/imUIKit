//
//  XHMessageBubbleHelper.m
//  MessageDisplayExample
//
//  Created by 曾 宪华 on 14-6-2.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessageBubbleHelper.h"

@interface XHMessageBubbleHelper () {
    NSCache *_recvAttributedStringCache;
    NSCache *_sendAttributedStringCache;
}

@end

@implementation XHMessageBubbleHelper

+ (instancetype)sharedMessageBubbleHelper {
    static XHMessageBubbleHelper *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[XHMessageBubbleHelper alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _recvAttributedStringCache = [[NSCache alloc] init];
        _sendAttributedStringCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)setDataDetectorsAttributedAttributedString:(NSMutableAttributedString *)attributedString
                                            atText:(NSString *)text
                             withRegularExpression:(NSRegularExpression *)expression
                                        attributes:(NSDictionary *)attributesDict {
    [expression enumerateMatchesInString:text
                                 options:0
                                   range:NSMakeRange(0, [text length])
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                  NSRange matchRange = [result range];
                                  if (attributesDict) {
                                      [attributedString addAttributes:attributesDict range:matchRange];
                                  }
                                  
                                  if ([result resultType] == NSTextCheckingTypeLink) {
                                      NSURL *url = [result URL];
                                      [attributedString addAttribute:NSLinkAttributeName value:url range:matchRange];
                                  } else if ([result resultType] == NSTextCheckingTypePhoneNumber) {
                                      NSString *phoneNumber = [result phoneNumber];
                                      [attributedString addAttribute:NSLinkAttributeName value:phoneNumber range:matchRange];
                                  } else if ([result resultType] == NSTextCheckingTypeDate) {
//                                      NSDate *date = [result date];
                                  }
                              }];
}

- (NSAttributedString *)bubbleAttributtedStringWithText:(NSString *)text matchColor:(UIColor *)matchColor normalColor:(UIColor *)normalColor isSend:(BOOL)isSend
{
    if (!text) {
        return [[NSAttributedString alloc] init];
    }
    
    if (isSend) {
        if ([_sendAttributedStringCache objectForKey:text]) {
            return [_sendAttributedStringCache objectForKey:text];
        } else {
            if ([_recvAttributedStringCache objectForKey:text]) {
                return [_recvAttributedStringCache objectForKey:text];
            }
        }
    }
    
    NSDictionary *textAttributes = @{NSForegroundColorAttributeName : matchColor};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSForegroundColorAttributeName value:normalColor range:NSMakeRange(0,text.length)];
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber | NSTextCheckingTypeDate
                                                               error:nil];
    [self setDataDetectorsAttributedAttributedString:attributedString atText:text withRegularExpression:detector attributes:textAttributes];
    
    if (isSend) {
        [_sendAttributedStringCache setObject:attributedString forKey:text];
    } else {
        [_recvAttributedStringCache setObject:attributedString forKey:text];
    }
    
    return attributedString;
}



@end

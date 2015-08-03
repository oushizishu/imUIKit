//
//  CardSimpleItem.h
//  BJEducation_Institution
//
//  Created by Randy on 15/8/1.
//  Copyright (c) 2015年 com.bjhl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardSimpleItem : NSObject
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *thumb;
@property (assign, nonatomic) NSInteger money;
@end

//
//  MyNode.h
//
//  Created by ziliang wang on 13-11-28.
//  Copyright (c) 2013年 wzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyNode : NSObject

@property (weak ,nonatomic) MyNode *superNode;
@property (strong ,nonatomic) NSString *nodeName;
@property (strong ,nonatomic) NSDictionary *nodeAttributes;
@property (strong ,nonatomic) NSMutableArray *storageMutableArray;

-(void)appNode:(MyNode*)node;
-(void)appValue:(NSString*)value;
-(MyNode*)getSonNodeByNodeName:(NSString*)nodeName;
-(NSString*)getNodeValue;
-(NSArray*)getSonArray;

@end

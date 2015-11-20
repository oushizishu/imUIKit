//
//  MyNode.m
//
//  Created by ziliang wang on 13-11-28.
//  Copyright (c) 2013年 wzl. All rights reserved.
//

#import "MyNode.h"

//#define SONNODEDEFAULTCOUNT 100

@implementation MyNode

-(void)appNode:(MyNode*)node
{
    if(self.storageMutableArray == nil)
    {
        self.storageMutableArray = [[NSMutableArray alloc] init];
    }
    [self.storageMutableArray addObject:node];
}

-(void)appValue:(NSString*)value
{
    if(self.storageMutableArray == nil)
    {
        self.storageMutableArray = [[NSMutableArray alloc] init];
    }
    [self.storageMutableArray addObject:value];
}

-(MyNode*)getSonNodeByNodeName:(NSString*)nodeName
{
    MyNode *node = nil;
    
    if (nodeName != nil) {
        if (self.storageMutableArray != nil) {
            for (int i = 0; i < [self.storageMutableArray count]; i++) {
                id object = [self.storageMutableArray objectAtIndex:i];
                
                if ([object isKindOfClass:[MyNode class]]) {
                    MyNode *sonNode = (MyNode*)object;
                    if ([sonNode.nodeName isEqualToString:nodeName]) {
                        node = sonNode;
                        break;
                    }
                }
            }
        }
    }
    
    return node;
}

-(NSString*)getNodeValue
{
    NSMutableString *reStr = [[NSMutableString alloc] init];
    if (self.storageMutableArray != nil) {
        for (int i = 0; i < [self.storageMutableArray count]; i++) {
            id object = [self.storageMutableArray objectAtIndex:i];
            
            if ([object isKindOfClass:[NSString class]]) {
                [reStr appendString:object];
            }
        }
    }
    return reStr;
}

-(NSArray*)getSonArray
{
    return self.storageMutableArray;
}

@end

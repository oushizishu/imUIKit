//
//  MyXmlDomParser.h
//
//  Created by ziliang wang on 13-11-28.
//  Copyright (c) 2013年 wzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyNode.h"

@interface MyXmlDomParser : NSObject<NSXMLParserDelegate>

-(BOOL)parserData:(NSData*)data;
-(BOOL)parserStr:(NSString *)string;

-(NSString*)getNodeValueByPath:(NSString*)path;
-(MyNode*)getNodeByPath:(NSString*)path;
-(MyNode*)getRootNode;

@end

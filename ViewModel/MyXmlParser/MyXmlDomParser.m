//
//  MyXmlDomParser.m
//
//  Created by ziliang wang on 13-11-28.
//  Copyright (c) 2013年 wzl. All rights reserved.
//

#import "MyXmlDomParser.h"

@interface MyXmlDomParser()

@property (strong ,nonatomic) MyNode *rootNode;
@property (strong ,nonatomic) NSMutableString *cacheStr;
@property (weak ,nonatomic) MyNode *cursorNode;

@end

@implementation MyXmlDomParser

-(BOOL)parserData:(NSData*)data
{
    NSXMLParser *par = [[NSXMLParser alloc] initWithData:data];
    [par setDelegate:self];
    return [par parse];
}

-(BOOL)parserStr:(NSString *)string
{
    NSXMLParser *par = [[NSXMLParser alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    [par setDelegate:self];
    return [par parse];
}

-(NSString*)getNodeValueByPath:(NSString*)path
{
    NSArray *pathA = [path componentsSeparatedByString:@"."];
    MyNode *node = nil;
    BOOL isExist;
    if (pathA != nil) {
        for (int i = 0; i<[pathA count]; i++) {
            isExist = FALSE;
            if (node == nil) {
                if ([self.rootNode.nodeName isEqualToString:[pathA objectAtIndex:i]]) {
                    node = self.rootNode;
                    isExist = TRUE;
                }
            }else
            {
                for (int j = 0; j< [node.storageMutableArray count]; j++) {
                    id object = [node.storageMutableArray objectAtIndex:j];
                    if ([object isKindOfClass:[MyNode class]]) {
                        MyNode *sonNode = (MyNode*)object;
                        if([sonNode.nodeName isEqualToString:[pathA objectAtIndex:i]])
                        {
                            node = sonNode;
                            isExist = TRUE;
                            break;
                        }
                    }
                }
            }
            if (!isExist) {
                return nil;
            }
        }
    }
    
    if (node != nil) {
        return [node getNodeValue];
    }else
    {
        return nil;
    }
}

-(MyNode*)getNodeByPath:(NSString*)path
{
    NSArray *pathA = [path componentsSeparatedByString:@"."];
    MyNode *node = nil;
    BOOL isExist;
    if (pathA != nil) {
        for (int i = 0; i<[pathA count]; i++) {
            isExist = FALSE;
            if (node == nil) {
                if ([self.rootNode.nodeName isEqualToString:[pathA objectAtIndex:i]]) {
                    node = self.rootNode;
                    isExist = TRUE;
                }
            }else
            {
                for (int j = 0; j< [node.storageMutableArray count]; j++) {
                    id object = [node.storageMutableArray objectAtIndex:j];
                    if ([object isKindOfClass:[MyNode class]]) {
                        MyNode *sonNode = (MyNode*)object;
                        if([sonNode.nodeName isEqualToString:[pathA objectAtIndex:i]])
                        {
                            node = sonNode;
                            isExist = TRUE;
                            break;
                        }
                    }
                }
            }
            if (!isExist) {
                return nil;
            }
        }
    }
    
    return node;
}

-(MyNode*)getRootNode
{
    return self.rootNode;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    MyNode *node = [[MyNode alloc] init];
    node.nodeName = elementName;
    node.nodeAttributes = attributeDict;
    if (self.rootNode == nil) {
        self.rootNode = node;
    }
    if(self.cursorNode != nil)
    {
        if(self.cacheStr != nil&&self.cacheStr.length>0)
        {
            [self.cursorNode appValue:self.cacheStr];
            self.cacheStr = nil;
        }
        node.superNode = self.cursorNode;
        [self.cursorNode appNode:node];
    }
    
    self.cursorNode = node;
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (self.cursorNode != nil) {
        if(self.cacheStr != nil&&self.cacheStr.length>0)
        {
            [self.cursorNode appValue:self.cacheStr];
            self.cacheStr = nil;
        }
        self.cursorNode = [self.cursorNode superNode];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.cacheStr == nil) {
        self.cacheStr = [[NSMutableString alloc] init];
    }
    [self.cacheStr appendString:string];
}

-(void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    
}

@end

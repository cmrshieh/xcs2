//
//  XCProject.m
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-04-28.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import "XCProject.h"
#import "XCProjectParser.h"
#import "XCElement.h"

@implementation XCProject

- (id)init
{
    self = [super init];
    if (self) {
        projDict = nil;
    }
    return self;
}

- (BOOL)parse:(NSString*)data
{
    XCProjectParser* parser = [[XCProjectParser alloc] init];

    projDict = [parser parse:data];
    if (projDict) {
        objects = [projDict dictValueForKey:@"objects"];
        NSString *rootObjId = [projDict stringValueForKey:@"rootObject"];
        rootObj = [self objectForId:rootObjId];

        return YES;
    }

    return NO;
}

- (XCDictionary*)objectForId:(NSString*)objId
{
    return [objects dictValueForKey:objId];
}

- (void)list
{
    NSString *mainFolderId = [rootObj stringValueForKey:@"mainGroup"];
    XCDictionary *mainFolder = [self objectForId:mainFolderId];
    [self listFolder:mainFolder indent:0];
}

- (void)listFolder:(XCDictionary*)folder indent:(NSUInteger)indent
{
    for (NSUInteger i = 0; i < indent; i ++)
        printf(" ");
    NSString *name = [folder stringValueForKey:@"name"];
    if (name == nil)
        name = [folder stringValueForKey:@"path"];
    printf("%s", 
            [name UTF8String]);
    BOOL isGroup = NO;
    if ([[folder stringValueForKey:@"isa"] caseInsensitiveCompare:@"PBXGroup"] == NSOrderedSame)
        isGroup = YES;
    if ([[folder stringValueForKey:@"isa"] caseInsensitiveCompare:@"PBXVariantGroup"] == NSOrderedSame)
        isGroup = YES;

    if (isGroup) {
        printf("/\n");
        NSArray *children = [folder arrayValueForKey:@"children"];
        for (XCString *idString in children) {
            XCDictionary *obj = [self objectForId:idString.stringValue];
            if (obj)
                [self listFolder:obj indent:indent+2];
        }
    }
    else
        printf("\n");
}
@end

//
//  XCProject.m
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-04-28.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import "XCProject.h"
#import "NSObject+DeepMutableCopy.h"
#import "XCError.h"

@implementation XCProject

- (id)init
{
    self = [super init];
    if (self) {
        projDict = nil;
    }
    return self;
}

- (BOOL)parseFile:(NSString*)path
{
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

    if (dict) {
        projDict = [dict deepMutableCopy];

        objects = [projDict objectForKey:@"objects"];
        NSString *rootObjId = [projDict objectForKey:@"rootObject"];
        rootObj = [self objectForId:rootObjId];

        return YES;
    }

    return NO;
}

- (BOOL)saveToFile:(NSString*)path
{
    NSMutableString *projString = [NSMutableString stringWithString:@"// !$*UTF8*$!\n"];
    [projString appendString:[projDict description]];
    NSData *projData = [projString dataUsingEncoding:NSUTF8StringEncoding];
    return [projData writeToFile:path atomically:YES];
    
}

- (NSMutableDictionary*)objectForId:(NSString*)objId
{
    return [objects valueForKey:objId];
}

- (void)listVerbose:(BOOL)verbose
{
    NSString *mainGroupId = [rootObj objectForKey:@"mainGroup"];
    NSDictionary *mainGroup = [self objectForId:mainGroupId];
    [self listGroup:mainGroup withId:mainGroupId indent:0 verbose:verbose];
}


- (void)listGroup:(NSDictionary*)group withId:(NSString*)groupId indent:(NSUInteger)indent verbose:(BOOL)verbose
{
    for (NSUInteger i = 0; i < indent; i ++)
        printf(" ");
    NSString *name = [group objectForKey:@"name"];
    if (name == nil)
        name = [group objectForKey:@"path"];
    if (name == nil)
        name = @"";
    printf("%s", 
            [name UTF8String]);
    if (verbose)
        printf(" (%s)", [groupId UTF8String]);
    
    BOOL isGroup = NO;
    if ([group isA:@"PBXGroup"])
        isGroup = YES;
    if ([group isA:@"PBXVariantGroup"])
        isGroup = YES;

    if (isGroup) {
        printf("/\n");
        NSArray *children = [group objectForKey:@"children"];
        for (NSString *idString in children) {
            NSDictionary *obj = [self objectForId:idString];
            if (obj)
                [self listGroup:obj withId:idString indent:indent+2 verbose:verbose];
        }
    }
    else
        printf("\n");
}

- (BOOL)removeFileId:(NSString*)fileId error:(NSError**)error
{
    if (error)
        *error = nil;
    NSDictionary *fileObj = [self objectForId:fileId];
    if (!fileObj) {
        if (error)
            *error = [XCError objectNotFound];
        return NO;
    }

    if (![fileObj isA:@"PBXFileReference"]) {
        if (error)
            *error = [XCError invaidOperation];
        return NO;
    }

    NSString *buildFileId = nil;
    
    for (NSString *objId in objects) {
        NSDictionary *obj = [objects objectForKey:objId];
        if (![obj isA:@"PBXBuildFile"])
            continue;
        NSString *refId = [obj objectForKey:@"fileRef"];
        if ([refId isEqualToString:fileId]) {
            buildFileId = objId;
            break;
        }
    }
    
    if (buildFileId) {
        // go through targets/phases and remove references to BuildFile
        NSArray *targetIds = [rootObj objectForKey:@"targets"];
        for (NSString *targetId in targetIds) {
            NSDictionary *target = [self objectForId:targetId];
            NSArray *buildPhaseIds = [target objectForKey:@"buildPhases"];
            for (NSString *phaseId in buildPhaseIds) {
                NSDictionary *phase = [self objectForId:phaseId];
                NSMutableArray *files = [phase objectForKey:@"files"];
                [files removeObject:buildFileId];
            }
        }
        
        // remove build file itself
        [objects removeObjectForKey:buildFileId];
    }
    
    // and now remove the file itself and references to it from groups
    [self removeFromGroups:fileId];
    [objects removeObjectForKey:fileId];

    return YES;
}

- (void)removeFromGroups:(NSString*)refId
{
    NSString *mainGroupId = [rootObj objectForKey:@"mainGroup"];
    NSMutableDictionary *mainGroup = [self objectForId:mainGroupId];
    [self removeFromGroup:mainGroup itemWithId:refId];
}


- (void)removeFromGroup:(NSDictionary*)group itemWithId:(NSString*)refId
{
    BOOL isGroup = NO;
    if ([group isA:@"PBXGroup"])
        isGroup = YES;
    if ([group isA:@"PBXVariantGroup"])
        isGroup = YES;
    
    if (isGroup) {
        NSMutableArray *children = [group objectForKey:@"children"];

        [children removeObject:refId];

        for (NSString *idString in children) {
            NSDictionary *obj = [self objectForId:idString];
            if (obj)
                [self removeFromGroup:obj itemWithId:refId];
        }
    }
}


- (NSString*)idForPath:(NSString*)path
{
    NSArray *elements = [path pathComponents];
    NSString *mainGroupId = [rootObj objectForKey:@"mainGroup"];
    NSMutableDictionary *mainGroup = [self objectForId:mainGroupId];
    NSRange range;
    
    if ([elements count] == 0)
        return nil;
    
    if ([[elements objectAtIndex:0] isEqualToString:@"/"]) {
        range.location = 1;
        range.length = [elements count] - 1;
        elements = [elements subarrayWithRange:range];
    }

    return [self idForPathElements:elements inObject:mainGroup withId:mainGroupId];
}

- (NSString*)idForPathElements:(NSArray*)pathElements inObject:(NSMutableDictionary*)group withId:(NSString*)objId
{

    // should be last element and name should match with the file
    if ([pathElements count] == 0) {
            return objId;
    }
    
    BOOL isGroup = NO;
    if ([group isA:@"PBXGroup"])
        isGroup = YES;
    if ([group isA:@"PBXVariantGroup"])
        isGroup = YES;
    
    if (isGroup) {
        NSArray *children = [group objectForKey:@"children"];
        NSString *currentElement = [pathElements objectAtIndex:0];
        for (NSString *idString in children) {
            NSMutableDictionary *obj = [self objectForId:idString];
            NSString *name = [obj objectForKey:@"name"];
            if (name == nil)
                name = [obj objectForKey:@"path"];
            if (name == nil)
                name = @"";
            if ([name isEqualToString:currentElement]) {
                NSRange range;
                
                range.location = 1;
                range.length = [pathElements count] - 1;
                NSArray *newElements = [pathElements subarrayWithRange:range];
                return [self idForPathElements:newElements inObject:obj withId:idString];
            }
        }
    }
    
    return nil;
}

@end

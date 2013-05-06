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
    if (projDict)
        return YES;

    return NO;
}

- (void)list
{
    XCElement *rootObjId = [projDict elementForKey:@"rootObject"];
    NSLog(@"rootObj: %@", rootObjId);
}

@end

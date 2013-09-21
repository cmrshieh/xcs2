//
//  NSDictionary+PBXObject.m
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-09-20.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import "NSDictionary+PBXObject.h"

@implementation NSDictionary (PBXObject)

- (BOOL)isA:(NSString*)kind {
    if (self == nil)
        return NO;

    return ([[self objectForKey:@"isa"] caseInsensitiveCompare:kind] == NSOrderedSame);
}

@end

//
//  NSObject+DeepMutableCopy.m
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-09-20.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import "NSObject+DeepMutableCopy.h"

@implementation NSObject (DeepMutableCopy)

-(id)deepMutableCopy
{
    if ([self isKindOfClass:[NSArray class]]) {
        NSArray *oldArray = (NSArray *)self;
        NSMutableArray *newArray = [NSMutableArray array];
        for (id obj in oldArray) {
            [newArray addObject:[obj deepMutableCopy]];
        }
        return newArray;
    }
    else if ([self isKindOfClass:[NSDictionary class]]) {
        NSDictionary *oldDict = (NSDictionary *)self;
        NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
        for (id obj in oldDict) {
            [newDict setObject:[oldDict[obj] deepMutableCopy] forKey:obj];
        }
        return newDict;
    }
    else if ([self isKindOfClass:[NSSet class]]) {
        NSSet *oldSet = (NSSet *)self;
        NSMutableSet *newSet = [NSMutableSet set];
        for (id obj in oldSet) {
            [newSet addObject:[obj deepMutableCopy]];
        }
        return newSet;
#if MAKE_MUTABLE_COPIES_OF_NONCOLLECTION_OBJECTS
    }
    else if ([self conformsToProtocol:@protocol(NSMutableCopying)]) {
        // e.g. NSString
        return [self mutableCopy];
    }
    else if ([self conformsToProtocol:@protocol(NSCopying)]) {
        // e.g. NSNumber
        return [self copy];
#endif
    }
    else {
        return self;
    }
}

@end

//
//  XCElement.m
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-04-28.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import "XCElement.h"

@implementation XCElement
- (ElementKind)kind
{
    
    return elNone;
}

- (void)dump
{
    NSLog(@"%@", self);
}
@end

@implementation XCString
- (ElementKind)kind
{
    
    return elString;
}
@end

@implementation XCArray
- (ElementKind)kind
{
    
    return elArray;
}
@end

@implementation XCDictionary
- (ElementKind)kind
{
    
    return elDictionary;
}

- (void)dump
{
    NSEnumerator *enumerator = [_dictValue keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        NSLog(@"%@ --> %@", key, [_dictValue objectForKey:key]);
    }
}

- (XCElement*)elementForKey:(NSString*)key
{
    return  [_dictValue objectForKey:key];
}

// More type-strict versions
- (NSString*)stringValueForKey:(NSString*)key
{
    XCElement *el = [_dictValue objectForKey:key];
    if ([el kind] == elString) {
        XCString *s = (XCString *)el;
        return [s.stringValue copy];
    }

    return nil;
}

- (NSArray*)arrayValueForKey:(NSString*)key
{
    XCElement *el = [_dictValue objectForKey:key];
    if ([el kind] == elArray) {
        XCArray *d = (XCArray *)el;
        return [d.arrayValue copy];
    }

    return nil;
}

- (XCDictionary*)dictValueForKey:(NSString*)key
{
    XCElement *el = [_dictValue objectForKey:key];
    if ([el kind] == elDictionary) {
        XCDictionary *d = (XCDictionary *)el;
        return d;
    }

    return nil;
}

@end

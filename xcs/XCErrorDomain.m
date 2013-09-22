//
//  XCErrorDomain.m
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-09-21.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import "XCErrorDomain.h"

@implementation XCErrorDomain

+ (NSString *)domain
{
    return nil;
}

- (NSString *)domain
{
    return [[self class] domain];
}

+ (NSError *)errorWithErrorCode:(NSInteger)errorCode
{
    return [NSError errorWithDomain:[self domain] code:errorCode userInfo:nil];
}

+ (NSError *)errorWithErrorCode:(NSInteger)errorCode userInfo:(NSDictionary *)userInfo
{
    return [NSError errorWithDomain:[self domain] code:errorCode userInfo:userInfo];
}

@end

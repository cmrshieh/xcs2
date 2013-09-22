//
//  XCError.m
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-09-21.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import "XCError.h"

NSString * const kXCErrorDomain = @"com.bluezbox.xcs";

@implementation XCError

+ (NSString *)domain
{
    return kXCErrorDomain;
}

+ (NSError *)objectNotFound
{
    NSDictionary *info = [NSDictionary dictionaryWithObject:@"Object not found" forKey:NSLocalizedDescriptionKey];
    return [self errorWithErrorCode:XCErrorCode_ObjectNotFound userInfo:info];
}

+ (NSError *)invaidOperation
{
    NSDictionary *info = [NSDictionary dictionaryWithObject:@"Invalid operation for this kind of object" forKey:NSLocalizedDescriptionKey];
    
    return [self errorWithErrorCode:XCErrorCode_InvalidOperation userInfo:info];
}

@end


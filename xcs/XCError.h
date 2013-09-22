//
//  XCError.h
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-09-21.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import "XCErrorDomain.h"

@interface XCError : XCErrorDomain

+ (NSError *)objectNotFound;
+ (NSError *)invaidOperation;

@end

extern NSString * const kXCErrorDomain;

typedef enum XCErrorCode {
    XCErrorCode_NoError = 0,
    XCErrorCode_ObjectNotFound,
    XCErrorCode_InvalidOperation
} XCErrorCode;
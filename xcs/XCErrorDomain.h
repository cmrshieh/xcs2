//
//  XCErrorDomain.h
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-09-21.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCErrorDomain : NSObject

+ (NSString *)domain; // << required override
- (NSString *)domain; // << returns [[self class] domain]

// example convenience methods:
// uses [self domain]
+ (NSError *)errorWithErrorCode:(NSInteger)errorCode; // << user info would be nil
+ (NSError *)errorWithErrorCode:(NSInteger)errorCode userInfo:(NSDictionary *)userInfo;



@end

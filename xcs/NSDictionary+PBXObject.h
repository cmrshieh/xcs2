//
//  NSDictionary+PBXObject.h
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-09-20.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (PBXObject)

- (BOOL)isA:(NSString*)kind;

@end

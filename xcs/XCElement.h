//
//  XCElement.h
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-04-28.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum
{
    elNone = 0,
    elString,
    elArray,
    elDictionary
} ElementKind;

@interface XCElement : NSObject

- (ElementKind)kind;
- (void)dump;
@end

@interface XCString : XCElement
@property (strong) NSString *stringValue;
@end

@interface XCArray : XCElement
@property (strong) NSArray *arrayValue;
@end

@interface XCDictionary : XCElement
@property (strong) NSDictionary *dictValue;
@end

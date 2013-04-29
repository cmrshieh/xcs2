//
//  XCProject.h
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-04-28.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCElement.h"

@interface XCProject : NSObject {
    NSUInteger _lexerPos;
    XCDictionary *parserRoot;
}

@property (strong) NSString *pbxData;
@property (strong) NSString *tokValue;

- (BOOL)parse:(NSString*)data;

@end

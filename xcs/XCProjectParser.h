//
//  XCProjectParser.h
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-05-06.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCElement.h"

@interface XCProjectParser : NSObject {
    NSUInteger _lexerPos;
    NSUInteger _row, _col;
    NSUInteger _prevRow, _prevCol;
    BOOL _nextLine;
}

@property (strong) NSString *pbxData;
@property (strong) NSString *tokValue;

- (XCDictionary*)parse:(NSString*)data;

@end

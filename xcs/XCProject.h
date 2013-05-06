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
    XCDictionary *projDict;
}

- (BOOL)parse:(NSString*)data;
- (void)list;

@end

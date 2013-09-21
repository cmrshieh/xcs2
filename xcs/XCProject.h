//
//  XCProject.h
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-04-28.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCProject : NSObject {
    NSDictionary *projDict;
    NSDictionary *objects;
    NSDictionary *rootObj;
}

- (BOOL)parseFile:(NSString*)path;
- (void)list;
- (NSDictionary*)objectForId:(NSString*)objId;

@end

//
//  XCProject.h
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-04-28.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+PBXObject.h"

@interface XCProject : NSObject {
    NSMutableDictionary *projDict;
    NSMutableDictionary *objects;
    NSMutableDictionary *rootObj;
}

- (BOOL)parseFile:(NSString*)path;
- (BOOL)saveToFile:(NSString*)path;
- (void)listVerbose:(BOOL)verbose;
- (BOOL)removeFileId:(NSString*)fileId error:(NSError**)error;
- (NSMutableDictionary*)objectForId:(NSString*)objId;

@end

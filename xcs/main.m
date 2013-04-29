//
//  main.m
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-04-28.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCProject.h"

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        NSError *err;
        XCProject *proj = [[XCProject alloc] init];
        NSString *projData = [NSString stringWithContentsOfFile:@"project.pbxproj" encoding:NSUTF8StringEncoding error:&err];
        if (projData == nil) {
            NSLog(@"Failed ot read project file: %@", [err localizedDescription]);
            exit (1);
        }
        [proj parse:projData];
    }
    return 0;
}


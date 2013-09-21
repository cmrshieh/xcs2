//
//  main.m
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-04-28.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCProject.h"

void usage(const char *app)
{
    fprintf(stderr, "Usage: %s command keys project.pbxproj\n", app);
}

int main(int argc,  char * argv[])
{
    int c;
    BOOL listCmd = NO;
    BOOL verbose = NO;
    
    while ((c = getopt(argc, argv, "hlv")) != -1) {
        switch (c) {
            case 'h':
                usage(argv[0]);
                exit(0);
            case 'l':
                listCmd = YES;
                break;
            case 'v':
                verbose = YES;
                break;
            default:
                usage(argv[0]);
                exit(1);
                break;
        }
    }
    
    argc -= optind;
    
    if (argc < 1) {
        usage(argv[0]);
        exit(1);
    }
    
    argv += optind;

    XCProject *proj = [[XCProject alloc] init];
    NSString *f = [NSString stringWithUTF8String:argv[0]];
    @try {
        [proj parseFile:f];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to load project file: %@", exception);
    }

    if (listCmd)
        [proj listVerbose:verbose];

    return 0;
}


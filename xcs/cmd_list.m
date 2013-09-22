//
//  cmd_load
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-09-20.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import "XCProject.h"

static void usage()
{
    fprintf(stderr, "Usage: xcs list [-vh] project.pbxproj\n");
}

void cmd_list(int argc, char **argv)
{
    int c;
    BOOL verbose = NO;
    
    while ((c = getopt(argc, argv, "hv")) != -1) {
        switch (c) {
            case 'h':
                usage();
                exit(0);
            case 'v':
                verbose = YES;
                break;
            default:
                usage();
                exit(1);
                break;
        }
    }
    
    argc -= optind;
    
    if (argc < 1) {
        usage();
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
    
    [proj listVerbose:verbose];    
}
//
//  cmd_rm.m
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-09-20.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import "XCProject.h"

static void usage()
{
    fprintf(stderr, "Usage: xcs2 rm [id:FILEID | path/to/file] project.pbxproj\n");
}

void cmd_rm(int argc, char **argv)
{
    int c;
    char *file_spec;
    BOOL is_path = YES;
    
    
    while ((c = getopt(argc, argv, "h")) != -1) {
        switch (c) {
            case 'h':
                usage();
                exit(0);

            default:
                usage();
                exit(1);
                break;
        }
    }
    
    argc -= optind;
    
    if (argc < 2) {
        usage();
        exit(1);
    }
    
    argv += optind;

    if (strncmp("id:", argv[0], 3) == 0) {
        is_path = NO;
        file_spec = strdup(argv[0] + 3);
    }
    else
        file_spec = strdup(argv[0]);
    
    XCProject *proj = [[XCProject alloc] init];
    NSString *f = [NSString stringWithUTF8String:argv[1]];
    
    @try {
        [proj parseFile:f];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to load project file: %@", exception);
    }
    
    if (is_path) {
        fprintf(stderr, "Delete by name not implemented\n");
        return;
    }
    else
        [proj removeFileId:[NSString stringWithUTF8String:file_spec]];
    
    [proj saveToFile:f];
}
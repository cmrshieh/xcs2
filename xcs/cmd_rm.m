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
    
    XCProject *proj = [[XCProject alloc] init];
    NSString *f = [NSString stringWithUTF8String:argv[1]];
    
    @try {
        [proj parseFile:f];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to load project file: %@", exception);
    }
    
    

    NSString *fileId;
    if (strncmp("id:", argv[0], 3) == 0) {
        fileId = [NSString stringWithUTF8String:(argv[0] + 3)];
    }
    else {
        fileId = [proj idForPath:[NSString stringWithUTF8String:argv[0]]];
        if (fileId == nil) {
            fprintf(stderr, "%s: no such file\n", argv[0]);
            return;
        }
    }
    

    NSError *err;
    if (![proj removeFileId:fileId error:&err]) {
        fprintf(stderr, "Couldn't remove object: %s\n", [[err localizedDescription] UTF8String]);
        return;
    }
    
    [proj saveToFile:f];
}
//
//  main.m
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-04-28.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCProject.h"
#import "commands.h"

static void usage()
{
    fprintf(stderr, "xcs cmd [-options]\n");
    fprintf(stderr, "Commands:\n");
    fprintf(stderr, "\tlist [-hv] path/to/project\n");
    fprintf(stderr, "\trm [id:FILEID | path/to/file] path/to/project\n");

}

int main(int argc,  char * argv[])
{

    if (argc < 2) {
        usage();
        exit(0);
    }

    if (strcmp(argv[1], "list") == 0) {
        argc--;
        argv++;
        cmd_list(argc, argv);
    }
    else if (strcmp(argv[1], "rm") == 0) {
        argc--;
        argv++;
        cmd_rm(argc, argv);
    }
    else {
        fprintf(stderr, "Unknown command: %s\n", argv[1]);
        usage();
        exit(0);
    }

    return 0;
}


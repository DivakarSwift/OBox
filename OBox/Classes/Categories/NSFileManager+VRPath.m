//
//  NSFileManager+VRPath.m
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "NSFileManager+VRPath.h"

@implementation NSFileManager (VRPath)

- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString {
    NSString *mkdTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:templateString];
    
    const char *templateCString = [mkdTemplate fileSystemRepresentation];
    char *buffer = (char *)malloc(strlen(templateCString) + 1);
    strcpy(buffer, templateCString);
    
    NSString *directoryPath = nil;
    
    char *result = mkdtemp(buffer);
    if (result) {
        directoryPath = [self stringWithFileSystemRepresentation:buffer length:strlen(result)];
    }
    free(buffer);
    
    return directoryPath;
}

@end

//
//  NSFileManager+VRPath.h
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (VRPath)

- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString;

@end

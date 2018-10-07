//
//  VRContextManager.m
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "VRContextManager.h"

@implementation VRContextManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static VRContextManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        NSDictionary *options = @{kCIContextWorkingColorSpace:[NSNull null]};
        _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:options];
    }
    return self;
}

@end

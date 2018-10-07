//
//  VRContextManager.h
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRContextManager : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, readonly, strong) EAGLContext *eaglContext;
@property (nonatomic, readonly, strong) CIContext *ciContext;

@end

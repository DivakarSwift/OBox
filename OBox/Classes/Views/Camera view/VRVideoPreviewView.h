//
//  VRVideoPreviewView.h
//  VRMicro
//
//  Created by kegebai on 2018/5/3.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "VRImageTarget.h"

@interface VRVideoPreviewView : GLKView <VRImageTarget>

@property (nonatomic, strong) CIFilter *filter;
@property (nonatomic, strong) CIContext *ciContext;

@end

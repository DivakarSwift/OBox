//
//  VRVideoCatcher.h
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "VRCameraCatcher.h"
#import "VRImageTarget.h"

@interface VRVideoCatcher : VRCameraCatcher

@property (nonatomic, weak) id <VRImageTarget> imageTarget;
@property (nonatomic, getter=isRecording) BOOL recording;

- (void)startRecording;
- (void)stopRecording;

@end

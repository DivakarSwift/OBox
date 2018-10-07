//
//  VRCameraCatcher.h
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VRCameraCaptureDelegate.h"
#import "VRError.h"
#import <AVFoundation/AVFoundation.h>

extern NSString *const VRThumbnailCreatedNotification;
extern NSString *const VRMovieCreatedNotification;

@interface VRCameraCatcher : NSObject

@property (nonatomic, weak) id <VRCameraCaptureDelegate> delegate;
@property (nonatomic, readonly, strong) AVCaptureSession *session;
@property (nonatomic, readonly, strong) dispatch_queue_t dispatchQueue;

// Session Configuration
- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;
// Hooks
- (BOOL)setupSessionInputs:(NSError **)error;
- (BOOL)setupSessionOutputs:(NSError **)error;
- (NSString *)sessionPreset;

@end

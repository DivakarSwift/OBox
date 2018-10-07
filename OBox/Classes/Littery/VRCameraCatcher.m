//
//  VRCameraCatcher.m
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "VRCameraCatcher.h"
#import "NSFileManager+VRPath.h"
#import "VRAssetsLibrary.h"

NSString *const VRThumbnailCreatedNotification = @"VRThumbnailCreated";
NSString *const VRMovieCreatedNotification = @"VRMovieCreated";

@interface VRCameraCatcher ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *activeVideoInput;

@property (nonatomic, strong) NSURL *outputUrl;
@property (nonatomic, strong) VRAssetsLibrary *library;

@end

@implementation VRCameraCatcher

- (instancetype)init {
    self = [super init];
    if (self) {
        _library = [[VRAssetsLibrary alloc] init];
        _dispatchQueue = dispatch_queue_create("com.kegebai.captureDispatchQueue", NULL);
    }
    return self;
}

- (BOOL)setupSession:(NSError *__autoreleasing *)error {
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = [self sessionPreset];
    
    if (![self setupSessionInputs:error]) {
        return NO;
    }
    if (![self setupSessionOutputs:error]) {
        return NO;
    }
    return YES;
}

- (BOOL)setupSessionInputs:(NSError *__autoreleasing *)error {
    // Set up default camera device
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (!videoInput) {
        return NO;
    }
    
    if ([self.session canAddInput:videoInput]) {
        [self.session addInput:videoInput];
        self.activeVideoInput = videoInput;
    } else {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to add video input."};
        *error = [NSError errorWithDomain:VRCameraErrorDomain
                                     code:VRCameraErrorFailedToAddInput
                                 userInfo:userInfo];
        return NO;
    }
    
    // Setup default microphone
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (!audioInput) {
        return NO;
    }
    
    if ([self.session canAddInput:audioInput]) {
        [self.session addInput:audioInput];
    } else {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to add audio input."};
        *error = [NSError errorWithDomain:VRCameraErrorDomain
                                     code:VRCameraErrorFailedToAddInput
                                 userInfo:userInfo];
        return NO;
    }
    
    return YES;
}

- (BOOL)setupSessionOutputs:(NSError *__autoreleasing *)error {
    return NO;
}

- (NSString *)sessionPreset {
    return AVCaptureSessionPresetHigh;
}

- (void)startSession {
    dispatch_async(self.dispatchQueue, ^{
        if (![self.session isRunning]) {
            [self.session startRunning];
        }
    });
}

- (void)stopSession {
    dispatch_async(self.dispatchQueue, ^{
        if ([self.session isRunning]) {
            [self.session stopRunning];
        }
    });
}

#pragma mark - Device Configuration

@end

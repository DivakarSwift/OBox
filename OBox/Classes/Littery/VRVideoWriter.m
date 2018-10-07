//
//  VRVideoWriter.m
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "VRVideoWriter.h"
#import <AVFoundation/AVFoundation.h>
#import "VRContextManager.h"
#import "VRFouctions.h"
#import "VRPhotoFilter.h"
#import "VRNotifications.h"

static NSString *const VRVideoFilename = @"movie.mov";

@interface VRVideoWriter ()

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic, strong)
    AVAssetWriterInputPixelBufferAdaptor *assetWriterInputPixelBufferAdaptor;

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@property (nonatomic, weak) CIContext *ciContext;
@property (nonatomic) CGColorSpaceRef colorSpace;
@property (nonatomic, strong) CIFilter *activeFilter;

@property (nonatomic, copy) NSDictionary *videoSettings;
@property (nonatomic, copy) NSDictionary *audioSettings;

@property (nonatomic) BOOL firstSample;

@end

@implementation VRVideoWriter

- (void)dealloc {
    CGColorSpaceRelease(_colorSpace);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithVideoSettings:(NSDictionary *)videoSettings
              audioSettings:(NSDictionary *)audioSettings
              dispatchQueue:(dispatch_queue_t)dispatchQueue {
    self = [super init];
    if (self) {
        _videoSettings = [videoSettings copy];
        _audioSettings = [audioSettings copy];
        _dispatchQueue = dispatchQueue;
        
        _ciContext = [VRContextManager shareInstance].ciContext;
        _colorSpace = CGColorSpaceCreateDeviceRGB();
        _activeFilter = [VRPhotoFilter defaultFilter];
        
        _firstSample = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(filterChanged:)
                                                     name:VRFilterSelectionChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)startWriting {
    
    dispatch_async(self.dispatchQueue, ^{
        NSError *error = nil;
        NSString *fileType = AVFileTypeQuickTimeMovie;
        self.assetWriter = [AVAssetWriter assetWriterWithURL:[self outputUrl] fileType:fileType error:&error];
        if (!self.assetWriter || error) {
            NSLog(@"Could not create AVAssetWriter: %@", error);
            return ;
        }
        
        self.assetWriterVideoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                                                    outputSettings:self.videoSettings];
        self.assetWriterVideoInput.expectsMediaDataInRealTime = YES;
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        self.assetWriterVideoInput.transform = VRTransformDeviceOrientation(orientation);
        
        NSDictionary *attributes = @{
            (id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),
            (id)kCVPixelBufferWidthKey:self.videoSettings[AVVideoWidthKey],
            (id)kCVPixelBufferHeightKey:self.videoSettings[AVVideoHeightKey],
            (id)kCVPixelFormatOpenGLESCompatibility:(id)kCFBooleanTrue
        };
        self.assetWriterInputPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc]
                                                   initWithAssetWriterInput:self.assetWriterVideoInput
                                                   sourcePixelBufferAttributes:attributes];
        if ([self.assetWriter canAddInput:self.assetWriterVideoInput]) {
            [self.assetWriter addInput:self.assetWriterVideoInput];
        } else {
            NSLog(@"Unable to add video input.");
            return ;
        }
        
        self.assetWriterAudioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio
                                                                    outputSettings:self.audioSettings];
        self.assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        if ([self.assetWriter canAddInput:self.assetWriterAudioInput]) {
            [self.assetWriter addInput:self.assetWriterAudioInput];
        } else {
            NSLog(@"Unable to add audio input.");
            return ;
        }
        
        self.isWriting = YES;
        self.firstSample = YES;
    });
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (!self.isWriting) {
        return ;
    }
    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDesc);
    if (mediaType == kCMMediaType_Video) {
        CMTime timeStemp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        if (self.firstSample) {
            if ([self.assetWriter startWriting]) {
                [self.assetWriter startSessionAtSourceTime:timeStemp];
            } else {
                NSLog(@"Failed to start writing.");
            }
            self.firstSample = NO;
        }
        CVPixelBufferRef outputRenderBuffer = NULL;
        CVPixelBufferPoolRef pixelBufferPool = self.assetWriterInputPixelBufferAdaptor.pixelBufferPool;
        OSStatus error = CVPixelBufferPoolCreatePixelBuffer(NULL, pixelBufferPool, &outputRenderBuffer);
        if (error) {
            NSLog(@"Unable to obtain a pixel buffer from the pool.");
            return ;
        }
        
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer options:nil];
        [self.activeFilter setValue:sourceImage forKey:kCIInputImageKey];
        CIImage *filterImage = self.activeFilter.outputImage;
        if (!filterImage) {
            filterImage = sourceImage;
        }
        [self.ciContext render:filterImage
               toCVPixelBuffer:outputRenderBuffer
                        bounds:filterImage.extent
                    colorSpace:self.colorSpace];
        
        if (self.assetWriterVideoInput.readyForMoreMediaData) {
            if (![self.assetWriterInputPixelBufferAdaptor appendPixelBuffer:outputRenderBuffer withPresentationTime:timeStemp]) {
                NSLog(@"Error appending pixel buffer.");
            }
        }
        CVPixelBufferRelease(outputRenderBuffer);
    }
    else if (!self.firstSample && mediaType == kCMMediaType_Audio) {
        if (self.assetWriterAudioInput.isReadyForMoreMediaData) {
            if (![self.assetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
                NSLog(@"Error appending audio sample buffer.");
            }
        }
    }
}

- (void)stopWriting {
    self.isWriting = NO;
    dispatch_async(self.dispatchQueue, ^{
        [self.assetWriter finishWritingWithCompletionHandler:^{
            if (self.assetWriter.status == AVAssetWriterStatusCompleted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate didWriteVideoAtURL:self.assetWriter.outputURL];
                });
            } else {
                NSLog(@"Failed to write movie: %@", self.assetWriter.error);
            }
        }];
    });
}

#pragma mark - action

- (void)filterChanged:(NSNotification *)notification {
    
}

#pragma mark - private

- (NSURL *)outputUrl {
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:VRVideoFilename];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    return url;
}

@end

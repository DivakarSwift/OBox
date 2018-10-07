//
//  VRVideoCatcher.m
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "VRVideoCatcher.h"
#import "VRVideoWriter.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface VRVideoCatcher () <AVCaptureVideoDataOutputSampleBufferDelegate,
                              AVCaptureAudioDataOutputSampleBufferDelegate,
                              VRVideoWriterDelegate>

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;

@property (nonatomic, strong) VRVideoWriter *videoWriter;

@end

@implementation VRVideoCatcher

- (NSString *)sessionPreset {
    return AVCaptureSessionPreset1280x720;
}

- (BOOL)setupSessionOutputs:(NSError *__autoreleasing *)error {
    
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
    self.videoDataOutput.videoSettings = outputSettings;
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.dispatchQueue];
    if ([self.session canAddOutput:self.videoDataOutput]) {
        [self.session addOutput:self.videoDataOutput];
    } else {
        return NO;
    }
    
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.dispatchQueue];
    if ([self.session canAddOutput:self.audioDataOutput]) {
        [self.session addOutput:self.audioDataOutput];
    } else {
        return NO;
    }
    
    NSString *fileType = AVFileTypeQuickTimeMovie;
    NSDictionary *videoSettings = [self.videoDataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:fileType];
    NSDictionary *audioSettings = [self.audioDataOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:fileType];
    self.videoWriter = [[VRVideoWriter alloc] initWithVideoSettings:videoSettings
                                                      audioSettings:audioSettings
                                                      dispatchQueue:self.dispatchQueue];
    self.videoWriter.delegate = self;
    
    return YES;
}

- (void)startRecording {
    [self.videoWriter startWriting];
    self.recording = YES;
}

- (void)stopRecording {
    [self.videoWriter stopWriting];
    self.recording = NO;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    [self.videoWriter processSampleBuffer:sampleBuffer];
    
    if (output == self.videoDataOutput) {
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer options:nil];
        [self.imageTarget setImage:sourceImage];
    }
}

#pragma mark - VRVideoWriterDelegate

- (void)didWriteVideoAtURL:(NSURL *)outputURL {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
        ALAssetsLibraryWriteVideoCompletionBlock completionBlock;
        completionBlock = ^(NSURL *assetURL, NSError *error){
            if (error) {
                [self.delegate assetLibraryWriteFailedWithError:error];
            }
        };
        [library writeVideoAtPathToSavedPhotosAlbum:outputURL
                                    completionBlock:completionBlock];
    }
}

@end

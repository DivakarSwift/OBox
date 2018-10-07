//
//  SampleDataProvider.m
//  Waveform
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "SampleDataProvider.h"

@implementation SampleDataProvider

+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset
                       completion:(SampleDataCompletionBlock)completion {
    
    NSString *tracks = @"tracks";
    [asset loadValuesAsynchronouslyForKeys:@[tracks] completionHandler:^{
        AVKeyValueStatus status = [asset statusOfValueForKey:tracks error:nil];
        NSData *sampleData = nil;
        if (status == AVKeyValueStatusLoaded) {
            sampleData = [self readAudioSamplesFromAsset:asset];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(sampleData);
        });
    }];
}

+ (NSData *)readAudioSamplesFromAsset:(AVAsset *)asset {
    
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if (!reader) {
        NSLog(@"Error creating asset reader: %@", error.localizedDescription);
        return nil;
    }
    
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    NSDictionary *settings = @{
        AVFormatIDKey:@(kAudioFormatLinearPCM),
        AVLinearPCMIsBigEndianKey:@NO,
        AVLinearPCMIsFloatKey:@NO,
        AVLinearPCMBitDepthKey:@(16)
    };
    AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:settings];
    [reader addOutput:output];
    [reader startReading];
    
    NSMutableData *sampleData = [NSMutableData data];
    while (reader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
        if (sampleBuffer) {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer);
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            SInt16 sampleBytes[length];
            CMBlockBufferCopyDataBytes(blockBufferRef,
                                       0,
                                       length,
                                       sampleBytes);
            [sampleData appendBytes:sampleBytes length:length];
            CMSampleBufferInvalidate(sampleBuffer);
            CFRelease(sampleBuffer);
        }
    }
    
    if (reader.status == AVAssetReaderStatusCompleted) {
        return sampleData;
    } else {
        NSLog(@"Failed to read audio samples from asset!");
        return nil;
    }
}

@end

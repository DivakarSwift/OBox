//
//  GICompositionExporter.m
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GICompositionExporter.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface GICompositionExporter ()
@property (nonatomic, strong) id <GIComposition> composition;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@end

@implementation GICompositionExporter

- (instancetype)initWithComposition:(id<GIComposition>)composition {
    self = [super init];
    if (self) {
        _composition = composition;
    }
    return self;
}

- (void)beginExport {
    self.exportSession = [self.composition makeExportable];
    self.exportSession.outputURL = [self outputUrl];
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAssetExportSessionStatus status = self.exportSession.status;
            if (status == AVAssetExportSessionStatusCompleted) {
                [self writeExportedVideoToAssetsLibrary];
            } else {
                NSLog(@"The requested export failed.");
            }
        });
    }];
    self.exporting = YES;
    [self monitorExportProgress];
}

- (void)writeExportedVideoToAssetsLibrary {
    NSURL *exportUrl = self.exportSession.outputURL;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportUrl]) {
        [library writeVideoAtPathToSavedPhotosAlbum:exportUrl completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"Unable to write to Photos library.");
            }
            [[NSFileManager defaultManager] removeItemAtURL:exportUrl error:nil];
        }];
    } else {
        NSLog(@"Video could not be exported to the assets library.");
    }
}

- (void)monitorExportProgress {
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AVAssetExportSessionStatus status = self.exportSession.status;
        if (status == AVAssetExportSessionStatusExporting) {
            self.progress = self.exportSession.progress;
            [self monitorExportProgress];
        } else {
            self.exporting = NO;
        }
    });
     */
    
    double delayInSeconds = 0.1;
    int64_t delta = (int64_t)delayInSeconds * NSEC_PER_SEC;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delta);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        AVAssetExportSessionStatus status = self.exportSession.status;
        if (status == AVAssetExportSessionStatusExporting) {
            self.progress = self.exportSession.progress;
            [self monitorExportProgress];
        } else {
            self.exporting = NO;
        }
    });
}

- (NSURL *)outputUrl {
    NSString *filePath = nil;
    NSUInteger count = 0;
    do {
        filePath = NSTemporaryDirectory();
        NSString *numberStr = count > 0 ? [NSString stringWithFormat:@"-%li", count] : @"";
        NSString *fileStr = [NSString stringWithFormat:@"Masterpiece-%@.m4v", numberStr];
        filePath = [filePath stringByAppendingPathComponent:fileStr];
        count++;
    } while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    
    return [NSURL fileURLWithPath:filePath];
}

@end

//
//  VRAssetsLibrary.m
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "VRAssetsLibrary.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

static NSString *const VRThumbnailCreatedNotification = @"VRThumbnailCreated";

@interface VRAssetsLibrary ()
@property (nonatomic, strong) ALAssetsLibrary *library;
@end

@implementation VRAssetsLibrary

- (instancetype)init {
    self = [super init];
    if (self) {
        _library = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

- (void)writeImage:(UIImage *)image completionHandler:(VRAssetsLibraryWriteCompletionHandler)completionHandler {
    [self.library writeImageToSavedPhotosAlbum:image.CGImage
                                   orientation:(NSInteger)image.imageOrientation
                               completionBlock:^(NSURL *assetURL, NSError *error) {
                                   if (!error) {
                                       [self postThumbnailNotifification:image];
                                       completionHandler(YES, nil);
                                   } else {
                                       completionHandler(NO, error);
                                   }
                               }];
}

- (void)writeVideoAtURL:(NSURL *)videoURL completionHandler:(VRAssetsLibraryWriteCompletionHandler)completionHandler {
    if ([self.library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {
        ALAssetsLibraryWriteVideoCompletionBlock completionBlock;
        completionBlock = ^(NSURL *assetURL, NSError *error){
            if (error) {
                completionHandler(NO, error);
            } else {
                [self generateThumbnailForVideoAtURL:videoURL];
                completionHandler(YES, nil);
            }
        };
        [self.library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:completionBlock];
    }
}

- (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        imageGenerator.maximumSize = CGSizeMake(100.0f, 0.0f);
        imageGenerator.appliesPreferredTrackTransform = YES;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero
                                                     actualTime:NULL
                                                          error:nil];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        [self postThumbnailNotifification:image];
    });
}

- (void)postThumbnailNotifification:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:VRThumbnailCreatedNotification object:image];
    });
}

@end

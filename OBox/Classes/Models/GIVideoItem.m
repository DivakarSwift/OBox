//
//  GIVideoItem.m
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIVideoItem.h"

#define thumbnailCount 4
#define thumbnailSize  CGSizeMake(227.0f, 128.0f)

@interface GIVideoItem ()
@property (nonatomic, strong) AVAssetImageGenerator *generator;
@property (nonatomic, strong) NSMutableArray *images;
@end

@implementation GIVideoItem

+ (id)videoItemWithURL:(NSURL *)url {
    return [[self alloc] initWithURL:url];
}

- (id)initWithURL:(NSURL *)url {
    self = [super initWithURL:url];
    if (self) {
        _generator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
        _generator.maximumSize = thumbnailSize;
        _thumbnails = @[];
        _images = [NSMutableArray arrayWithCapacity:thumbnailCount];
    }
    return self;
}

- (void)performPostPrepareActions:(GIPreparationCompletionBlock)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CMTime duration = self.asset.duration;
        CMTimeValue intervalSeconds = duration.value / thumbnailCount;
        CMTime time = kCMTimeZero;
        NSMutableArray *times = [NSMutableArray array];
        
        for (NSUInteger i = 0; i < thumbnailCount; i++) {
            [times addObject:[NSValue valueWithCMTime:time]];
            time = CMTimeAdd(time, CMTimeMake(intervalSeconds, duration.timescale));
        }
        [self.generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime,
                                                                                         CGImageRef  _Nullable cgImage,
                                                                                         CMTime actualTime,
                                                                                         AVAssetImageGeneratorResult result,
                                                                                         NSError * _Nullable error) {
            if (cgImage) {
                UIImage *image = [UIImage imageWithCGImage:cgImage];
                [self.images addObject:image];
            } else {
                [self.images addObject:[UIImage imageNamed:@"video_thumbnail"]];
            }
            
            if (self.images.count == thumbnailCount) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.thumbnails = [NSArray arrayWithArray:self.images];
                    completion(YES);
                });
            }
        }];
    });
}

#pragma mark - getter

- (NSString *)mediaType {
    // This is actually muxed, but treat as video for our purposes
    return AVMediaTypeVideo;
}

// Always pass back valid time range.
// If no start or end transition playthroughTimeRange equals the media item timeRange.
- (CMTimeRange)playthroughTimeRange {
    CMTimeRange range = self.timeRange;
    if (self.startTransition && self.startTransition.type != GIVideoTransitionTypeNone) {
        range.start = CMTimeAdd(range.start, self.startTransition.duration);
        range.duration = CMTimeSubtract(range.duration, self.startTransitionTimeRange.duration);
    }
    if (self.endTransition && self.endTransition.type != GIVideoTransitionTypeNone) {
        range.duration = CMTimeSubtract(range.duration, self.endTransition.duration);
    }
    return range;
}

- (CMTimeRange)startTransitionTimeRange {
    if (self.startTransition && self.startTransition.type != GIVideoTransitionTypeNone) {
        return CMTimeRangeMake(kCMTimeZero, self.startTransition.duration);
    }
    return CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
}

- (CMTimeRange)endTransitionTimeRange {
    if (self.endTransition && self.endTransition.type != GIVideoTransitionTypeNone) {
        CMTime beginTransitionTime = CMTimeSubtract(self.timeRange.duration, self.endTransition.duration);
        return CMTimeRangeMake(beginTransitionTime, self.endTransition.duration);
    }
    return CMTimeRangeMake(self.timeRange.duration, kCMTimeZero);
}

@end

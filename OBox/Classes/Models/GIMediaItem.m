//
//  GIMediaItem.m
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIMediaItem.h"

static NSString *const AVAssetTracksKey = @"tracks";
static NSString *const AVAssetDurationKey = @"duration";
static NSString *const AVAssetCommonMetadataKey = @"commonMetadata";

@interface GIMediaItem ()
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, strong) NSURL *url;
@end

@implementation GIMediaItem

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
        _filename = [url.lastPathComponent copy];
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
        _asset = [AVURLAsset URLAssetWithURL:url options:options];
    }
    return self;
}

- (BOOL)isTrimmed {
    if (!self.prepared) {
        return NO;
    }
    return CMTIME_COMPARE_INLINE(self.timeRange.duration, <, self.asset.duration);
}

- (void)prepare:(GIPreparationCompletionBlock)completion {
    NSArray *keys = @[AVAssetTracksKey, AVAssetDurationKey, AVAssetCommonMetadataKey];
    [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        // Production code should be more robust.  Specifically, should capture error in failure case.
        AVKeyValueStatus tracksStatus = [self.asset statusOfValueForKey:AVAssetTracksKey error:nil];
        AVKeyValueStatus durationStatus = [self.asset statusOfValueForKey:AVAssetDurationKey error:nil];
        self->_prepared = (tracksStatus == AVKeyValueStatusLoaded) && (durationStatus == AVKeyValueStatusLoaded);
        if (self.prepared) {
            self.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
            [self performPostPrepareActions:completion];
        } else {
            if (completion) {
                completion(NO);
            }
        }
    }];
}

- (void)performPostPrepareActions:(GIPreparationCompletionBlock)completion {
    if (completion) {
        completion(self.prepared);
    }
}

- (AVPlayerItem *)makePlayable {
    return [AVPlayerItem playerItemWithAsset:self.asset];
}

#pragma mark - getter

- (NSString *)mediaType {
    NSAssert(NO, @"Must be overridden in subclass.");
    return nil;
}

- (NSString *)title {
    if (!_title) {
        for (AVMetadataItem *metaItem in self.asset.commonMetadata) {
            if ([metaItem.commonKey isEqualToString:AVMetadataCommonKeyTitle]) {
                _title = [metaItem stringValue];
                break;
            }
        }
    }
    if (!_title) {
        _title = self.filename;
    }
    return _title;
}

#pragma mark - isEqual

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (!object || [object isKindOfClass:self.class]) {
        return NO;
    }
    return [self.url isEqual:[object url]];
}

#pragma mark - hash

- (NSUInteger)hash {
    return [self.url hash];
}

@end

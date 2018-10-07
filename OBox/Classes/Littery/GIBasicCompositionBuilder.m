//
//  GICompositionBuilder.m
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIBasicCompositionBuilder.h"
#import "GIBasicComposition.h"
#import "GIFunctions.h"
#import "GIMediaItem.h"

@interface GIBasicCompositionBuilder ()
@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) GITimeline *timeline;
@end

@implementation GIBasicCompositionBuilder

- (id)initWithTimeline:(GITimeline *)timeline {
    self = [super init];
    if (self) {
        _timeline = timeline;
    }
    return self;
}

- (id<GIComposition>)buildComposition {
    self.composition = [AVMutableComposition composition];
    [self addCompositionTrackOfMediaType:AVMediaTypeVideo mediaItem:self.timeline.videos];
    [self addCompositionTrackOfMediaType:AVMediaTypeAudio mediaItem:self.timeline.voiceOvers];
    [self addCompositionTrackOfMediaType:AVMediaTypeAudio mediaItem:self.timeline.musicItems];
    // Create and return the GIComposition
    return [GIBasicComposition composition:self.composition];
}

- (void)addCompositionTrackOfMediaType:(NSString *)mediaType
                             mediaItem:(NSArray *)mediaItems {
    //
    if (!GI_IS_EMPTY(mediaItems)) {
        CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
        AVMutableCompositionTrack *track = [self.composition addMutableTrackWithMediaType:mediaType
                                                                         preferredTrackID:trackID];
        // Set insert cursor to 0
        CMTime cursorTime = kCMTimeZero;
        for (GIMediaItem *item in mediaItems) {
            if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline, !=, kCMTimeInvalid)) {
                cursorTime = item.startTimeInTimeline;
            }
            AVAssetTrack *assetTrack = [item.asset tracksWithMediaType:mediaType].firstObject;
            [track insertTimeRange:item.timeRange
                           ofTrack:assetTrack
                            atTime:cursorTime
                             error:nil];
            // Move cursor to next item time
            cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
        }
    }
}

@end

//
//  GITimelineBuilder.m
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GITimelineBuilder.h"
#import "GITimeline.h"
#import "GITimelineItemViewModel.h"
#import "GIVideoTransition.h"
#import "GIVideoItem.h"

@implementation GITimelineBuilder

+ (GITimeline *)buildTimelineWithMediaItems:(NSArray *)mediaItems
                         transitionsEnabled:(BOOL)transitionsEnabled {
    
    GITimeline *timeline = [[GITimeline alloc] init];
    timeline.videos = [self buildVideoItems:mediaItems[GIVideoTrack]];
    
    if (transitionsEnabled) {
        for (GIVideoItem *item in timeline.videos) {
            // Expand the duration to accomodate the overlaps
            CMTime expandedDuration = CMTimeMake(5666666667, 1000000000);
            item.timeRange = CMTimeRangeMake(kCMTimeZero, expandedDuration);
        }
    }
    timeline.transitions = [self buildTransitions:mediaItems[GIVideoTrack]];
    timeline.voiceOvers  = [self buildMediaItems:mediaItems[GICommentaryTrack]];
    timeline.musicItems  = [self buildMediaItems:mediaItems[GIMusicTrack]];
    timeline.titles      = [self buildMediaItems:mediaItems[GITitleTrack]];
    return timeline;
}

+ (NSArray *)buildMediaItems:(NSArray *)adaptedItems {
    NSMutableArray *items = [NSMutableArray array];
    for (GITimelineItemViewModel *adapter in adaptedItems) {
        [adapter updateTimelineItem];
        [items addObject:adapter.timelineItem];
    }
    return items;
}

+ (NSArray *)buildTransitions:(NSArray *)viewModels {
    NSMutableArray *items = [NSMutableArray array];
    for (id item in viewModels) {
        if ([item isKindOfClass:[GIVideoTransition class]]) {
            [items addObject:item];
        }
    }
    return items;
}

+ (NSArray *)buildVideoItems:(NSArray *)viewModels {
    NSMutableArray *items = [NSMutableArray array];
    for (GITimelineItemViewModel *model in viewModels) {
        if ([model isKindOfClass:[GITimelineItemViewModel class]] &&
            [model.timelineItem isKindOfClass:[GIMediaItem class]]) {
            [model updateTimelineItem];
            [items addObject:model.timelineItem];
        }
    }
    return items;
}

+ (NSArray *)buildVideoTrackModels:(NSArray *)viewModels {
    NSMutableArray *items = [NSMutableArray array];
    for (id item in viewModels) {
        if ([item isKindOfClass:[GITimelineItemViewModel class]] &&
            [[item timelineItem] isKindOfClass:[GIMediaItem class]]) {
            [item updateTimelineItem];
            [items addObject:[item timelineItem]];
        } else {
            [items addObject:item];
        }
    }
    return items;
}

@end

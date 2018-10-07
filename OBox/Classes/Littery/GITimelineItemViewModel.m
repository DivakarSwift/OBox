//
//  GITimelineItemViewModel.m
//  AudioBox
//
//  Created by kegebai on 2018/9/11.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GITimelineItemViewModel.h"

@implementation GITimelineItemViewModel

+ (id)modelWithTimelineItem:(GITimelineItem *)timelineItem {
    return [[self alloc] initWithTimelineItem:timelineItem];
}

- (id)initWithTimelineItem:(GITimelineItem *)timelineItem {
    self = [super init];
    if (self) {
        _timelineItem = timelineItem;
        CMTimeRange maxTimeRange = CMTimeRangeMake(kCMTimeZero, timelineItem.timeRange.duration);
        _maxWidthInTimeline = GIGetWidthForTimeRange(maxTimeRange, TIMELINE_WIDTH / TIMELINE_SECONDS);
    }
    return self;
}

- (CGFloat)widthInTimeline {
    if (_widthInTimeline == 0.0f) {
        _widthInTimeline = GIGetWidthForTimeRange(self.timelineItem.timeRange, TIMELINE_WIDTH / TIMELINE_SECONDS);
    }
    return _widthInTimeline;
}

- (void)updateTimelineItem {
    
    // Only care about position if user explicitly positioned media item.
    // This can only happen on the title and commentary tracks.
    if (self.positionInTimeline.x > 0.0f) {
        CMTime startTime = GIGetTimeForOrigin(self.positionInTimeline.x, TIMELINE_WIDTH / TIMELINE_SECONDS);
        self.timelineItem.startTimeInTimeline = startTime;
    }
    
    self.timelineItem.timeRange = GIGetTimeRangeForWidth(self.widthInTimeline, TIMELINE_WIDTH / TIMELINE_SECONDS);
}

@end

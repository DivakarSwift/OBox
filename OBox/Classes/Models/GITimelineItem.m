//
//  GITimelineItem.m
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GITimelineItem.h"

@implementation GITimelineItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeRange = kCMTimeRangeInvalid;
        _startTimeInTimeline = kCMTimeInvalid;
    }
    return self;
}

@end

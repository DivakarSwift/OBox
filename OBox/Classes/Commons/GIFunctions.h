//
//  GIFunctions.h
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#ifndef GIFunctions_h
#define GIFunctions_h

#import "GIConstants.h"

static inline BOOL GI_IS_EMPTY(id value) {
    return value == nil || value == [NSNull null] ||
    ([value isKindOfClass:[NSString class]] && [value length] == 0) ||
    ([value respondsToSelector:@selector(count)] && [value count] == 0);
}

static inline CGFloat GIGetWidthForTimeRange(CMTimeRange timeRange, CGFloat scaleFactor) {
    return CMTimeGetSeconds(timeRange.duration) * scaleFactor;
}

static inline CGPoint GIGetOriginForTime(CMTime time) {
    CGFloat seconds = CMTimeGetSeconds(time);
    return CGPointMake(seconds * (TIMELINE_WIDTH / TIMELINE_SECONDS), 0);
}

static inline CMTimeRange GIGetTimeRangeForWidth(CGFloat width, CGFloat scaleFactor) {
    CGFloat duration = width / scaleFactor;
    return CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(duration, NSEC_PER_SEC));
}

static inline CMTime GIGetTimeForOrigin(CGFloat origin, CGFloat scaleFactor) {
    CGFloat seconds = origin / scaleFactor;
    return CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC);
}

static inline CGFloat GIDegreesToRadians(CGFloat degrees) {
    return (degrees * M_PI / 180);
}

static inline NSIndexPath * GIIndexPathForButton(UITableView *tableView, UIButton *button) {
    CGPoint point = [button convertPoint:button.bounds.origin toView:tableView];
    return [tableView indexPathForRowAtPoint:point];
}

#endif /* GIFunctions_h */

//
//  GITimelineBuilder.h
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GITimeline;

@interface GITimelineBuilder : NSObject

+ (GITimeline *)buildTimelineWithMediaItems:(NSArray *)mediaItems
                         transitionsEnabled:(BOOL)enabled;

@end

//
//  GIVolumeAutomation.m
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIVolumeAutomation.h"

@implementation GIVolumeAutomation

+ (id)volumeAutomationWithTimeRange:(CMTimeRange)timeRange
                        startVolume:(CGFloat)startVolume
                          endVolume:(CGFloat)endVolume {
    GIVolumeAutomation *automation = [[GIVolumeAutomation alloc] init];
    automation.timeRange = timeRange;
    automation.startVolume = startVolume;
    automation.endVolume = endVolume;
    return automation;
}

@end

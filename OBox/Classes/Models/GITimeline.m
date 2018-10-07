//
//  GITimeline.m
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GITimeline.h"
#import "GIAudioItem.h"

@implementation GITimeline

- (BOOL)isSimpleTimeline {
    for (GIAudioItem *item in self.musicItems) {
        if (item.volumeAutomation.count > 0) {
            return NO;
        }
    }
    if (self.transitions.count > 0 || self.titles.count > 0) {
        return NO;
    }
    return YES;
}

@end

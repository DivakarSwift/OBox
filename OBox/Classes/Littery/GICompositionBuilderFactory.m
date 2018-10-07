//
//  GICompositionBuilderFactory.m
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GICompositionBuilderFactory.h"
#import "GIBasicCompositionBuilder.h"
#import "GIMediaCompositionBuilder.h"

@implementation GICompositionBuilderFactory

- (id<GICompositionBuilder>)buildForTimeline:(GITimeline *)timeline {
    if ([timeline isSimpleTimeline]) {
        return [[GIBasicCompositionBuilder alloc] initWithTimeline:timeline];
    } else {
        return [[GIMediaCompositionBuilder alloc] initWithTimeline:timeline];
    }
}

@end

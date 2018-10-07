//
//  GIMediaCompositionBuilder.h
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GICompositionBuilder.h"
#import "GITimeline.h"

@interface GIMediaCompositionBuilder : NSObject <GICompositionBuilder>

- (id)initWithTimeline:(GITimeline *)timeline;

@end

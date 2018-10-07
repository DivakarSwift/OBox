//
//  GIBasicCompositionBuilder.h
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GICompositionBuilder.h"
#import "GITimeline.h"

@interface GIBasicCompositionBuilder : NSObject <GICompositionBuilder>

- (id)initWithTimeline:(GITimeline *)timeline;

@end

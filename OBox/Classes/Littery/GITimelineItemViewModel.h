//
//  GITimelineItemViewModel.h
//  AudioBox
//
//  Created by kegebai on 2018/9/11.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITimelineItem.h"

@interface GITimelineItemViewModel : NSObject

@property (nonatomic) CGFloat widthInTimeline;
@property (nonatomic) CGFloat maxWidthInTimeline;
@property (nonatomic) CGPoint positionInTimeline;
@property (nonatomic) GITimelineItem *timelineItem;

+ (id)modelWithTimelineItem:(GITimelineItem *)timelineItem;
- (void)updateTimelineItem;

@end

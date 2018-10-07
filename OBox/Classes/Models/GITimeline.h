//
//  GITimeline.h
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIMediaItem.h"

typedef NS_ENUM(NSInteger, GITrack) {
    GIVideoTrack = 0,
    GITitleTrack,
    GICommentaryTrack,
    GIMusicTrack,
};

@interface GITimeline : NSObject

@property (nonatomic, copy) NSArray *videos;
@property (nonatomic, copy) NSArray *transitions;
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, copy) NSArray *voiceOvers;
@property (nonatomic, copy) NSArray *musicItems;

- (BOOL)isSimpleTimeline;

@end

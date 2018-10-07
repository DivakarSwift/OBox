//
//  GIPlaybackMediator.h
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITimeline.h"

@protocol GIPlaybackMediator <NSObject>

- (void)loadMediaItem:(GIMediaItem *)mediaItem;
- (void)previewMediaItem:(GIMediaItem *)mediaItem;
- (void)addMediaItem:(GIMediaItem *)item toTimelineTrack:(GITrack)track;
- (void)prepareTimelineForPlayback;
- (void)stopPlayback;

@end

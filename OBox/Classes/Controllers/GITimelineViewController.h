//
//  GITimelineViewController.h
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITimeline.h"

@interface GITimelineViewController : UIViewController

@property (nonatomic) BOOL transitionsEnabled;
@property (nonatomic) BOOL volumeFadesEnabled;
@property (nonatomic) BOOL duckingEnabled;
@property (nonatomic) BOOL titlesEnabled;

@property (nonatomic, readonly) UICollectionView *collectionView;

- (GITimeline *)currentTimeline;
- (void)addTimelineItem:(GITimelineItem *)timelineItem toTrack:(GITrack)track;
- (void)clearTimeline;
- (void)updateMusicTrackVolumeAutomation;
- (void)synchronizePlayheadWithPlayerItem:(AVPlayerItem *)playerItem;
- (void)addTitleItems;

@end

//
//  GITimelineViewController.m
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GITimelineViewController.h"
#import "GITimelineDataSource.h"
#import "GIPlayheadView.h"
#import "GITimelineBuilder.h"
#import "GITimelineLayout.h"
#import "GITimelineItemViewModel.h"
#import "GIVideoTransition.h"
#import "GIAudioItem.h"
#import "GIVolumeAutomation.h"
#import "GITitleItem.h"

@interface GITimelineViewController ()

//@property (nonatomic, strong) UIPopoverController *transitionPopoverController;
//@property (nonatomic, copy) NSArray *cellIDs;
@property (nonatomic, strong) GITimelineDataSource *dataSource;
@property (nonatomic, strong) GIPlayheadView *playheadView;

@end

@implementation GITimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.transitionsEnabled = [THAppSettings sharedSettings].transitionsEnabled;
//    self.volumeFadesEnabled = [THAppSettings sharedSettings].volumeFadesEnabled;
//    self.duckingEnabled     = [THAppSettings sharedSettings].volumeDuckingEnabled;
//    self.titlesEnabled      = [THAppSettings sharedSettings].titlesEnabled;
    
    // Register for notifications sent from the "Settings" menu
    [self registerForNotifications];
    // Set up UICollectionView data source and delegate
    self.dataSource = [GITimelineDataSource dataSourceWithController:self];
    self.collectionView.delegate = self.dataSource;
    self.collectionView.dataSource = self.dataSource;
    
    // Set dark stone background view on UICollectionView instance.
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    UIImage *patternImage = [UIImage imageNamed:@"app_black_background"];
    
    // Fix for my broken tiled images.  Fix this correctly in Photoshop.
    CGRect insetRect = CGRectMake(2.0f, 2.0f, patternImage.size.width - 2.0f, patternImage.size.width - 2.0f);
    CGImageRef image = CGImageCreateWithImageInRect(patternImage.CGImage, insetRect);
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithCGImage:image]];
    CGImageRelease(image);
    
    self.collectionView.backgroundView = backgroundView;
    
    self.playheadView = [[GIPlayheadView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.playheadView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public 

- (GITimeline *)currentTimeline {
    NSArray *timelineItems = self.dataSource.timelineItems;
    return [GITimelineBuilder buildTimelineWithMediaItems:timelineItems
                                       transitionsEnabled:self.transitionsEnabled];
}

- (void)addTimelineItem:(GITimelineItem *)timelineItem toTrack:(GITrack)track {
    NSMutableArray *items = self.dataSource.timelineItems[track];
    
    // Enforce 15 second-ness
    if (track == GIVideoTrack) {
        if ([self countOfVideosInTimeline] == 3) {
            return;
        }
        timelineItem.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(5, 1));
    } else if (track == GIMusicTrack) {
        if (items.count == 1) {
            return;
        }
        timelineItem.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(15, 1));
    } else if (track == GICommentaryTrack) {
        if (items.count == 1) {
            return;
        }
    }
    
    GITimelineItemViewModel *model = [GITimelineItemViewModel modelWithTimelineItem:timelineItem];
    if (track == GICommentaryTrack) {
        CMTime startTime = CMTimeAdd(GIDefaultFadeInOutTime, GIDefaultDuckingFadeInOutTime);
        model.positionInTimeline = GIGetOriginForTime(startTime);
        [model updateTimelineItem];
    }
    
    if (track == GITitleTrack) {
        CMTime startTime = timelineItem.startTimeInTimeline;
        model.positionInTimeline = GIGetOriginForTime(startTime);
        [model updateTimelineItem];
    }
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    
    // insert transition between items
    if (track == GIVideoTrack && self.transitionsEnabled && items.count > 0) {
        GIVideoTransition *transition = [GIVideoTransition disolveTransitionWithDuration:CMTimeMake(1, 2)];
        [items addObject:transition];
        NSIndexPath *path = [NSIndexPath indexPathForItem:(items.count - 1) inSection:track];
        [indexPaths addObject:path];
    }
    
    if (track == GIMusicTrack) {
        GIAudioItem *audioItem = (GIAudioItem *)timelineItem;
        audioItem.volumeAutomation = [self buildVolumeFadesForMusicItem:audioItem];
    }
    
    [items addObject:model];
    NSIndexPath *path = [NSIndexPath indexPathForItem:(items.count - 1) inSection:track];
    [indexPaths addObject:path];
    
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
}

- (void)clearTimeline {
    [self.playheadView reset];
    __weak typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSArray *items = weakSelf.dataSource.timelineItems;
        for (NSUInteger i = 0; i < items.count; i++) {
            for (NSUInteger j = 0; j < [items[i] count]; j++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:j inSection:i]];
            }
        }
        [weakSelf.collectionView deleteItemsAtIndexPaths:indexPaths];
        [weakSelf.dataSource resetTimeline];
        
    } completion:^(BOOL complete) {
        [weakSelf.collectionView reloadData];
    }];
}

- (void)updateMusicTrackVolumeAutomation {
    NSArray *items = self.dataSource.timelineItems[GIMusicTrack];
    if (items.count > 0) {
        GITimelineItemViewModel *musicViewModel = [items firstObject];
        GIAudioItem *musicItem = (GIAudioItem *)musicViewModel.timelineItem;
        musicItem.volumeAutomation = [self buildVolumeFadesForMusicItem:musicItem];
    }
}

- (void)synchronizePlayheadWithPlayerItem:(AVPlayerItem *)playerItem {
    [self.playheadView synchronizedPlayerItem:playerItem];
}

- (void)addTitleItems {
    if (self.titlesEnabled) {
        GITitleItem *tapHarmonicItem = [GITitleItem titleItemWithText:@"TapHarmonic Films Presents"
                                                                image:[UIImage imageNamed:@"tapharmonic_logo"]];
        tapHarmonicItem.identifier = @"TapHarmonic Layer";
        tapHarmonicItem.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(3, 1));
        tapHarmonicItem.startTimeInTimeline = CMTimeMake(1, 1);
        
        GITitleItem *bookItem = [GITitleItem titleItemWithText:@"Learning AV Foundation"
                                                         image:[UIImage imageNamed:@"lavf_cover"]];
        bookItem.identifier = @"LAVF Book Layer";
        bookItem.useLargeFont = YES;
        bookItem.animateImage = YES;
        bookItem.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(4, 1));
        bookItem.startTimeInTimeline = CMTimeMake(55, 10);
        
        [self addTimelineItem:tapHarmonicItem toTrack:GITitleTrack];
        [self addTimelineItem:bookItem toTrack:GITitleTrack];
    }
    else {
        NSMutableArray *items = self.dataSource.timelineItems[GITitleTrack];
        [items removeAllObjects];
        [self.collectionView reloadData];
    }
}

#pragma mark - private

- (void)registerForNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(toggleTransitionsEnabledState:)
                               name:GITransitionsEnabledStateChangeNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(toggleVolumeFadesEnabledState:)
                               name:GIVolumeFadesEnabledStateChangeNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(toggleVolumeDuckingEnabledState:)
                               name:GIVolumeDuckingEnabledStateChangeNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(toggleShowTitlesEnabledState:)
                               name:GIShowTitlesEnabledStateChangeNotification
                             object:nil];
}

- (void)toggleTransitionsEnabledState:(NSNotification *)notification {
    BOOL state = [[notification object] boolValue];
    if (self.transitionsEnabled != state) {
        self.transitionsEnabled = state;
        GITimelineLayout *layout = (GITimelineLayout *)self.collectionView.collectionViewLayout;
        layout.reorderingAllowed = !state;
        [self.collectionView reloadData];
    }
}

- (void)toggleVolumeFadesEnabledState:(NSNotification *)notification {
    self.volumeFadesEnabled = [[notification object] boolValue];
    [self rebuildVolumeAndDuckingState];
}

- (void)toggleVolumeDuckingEnabledState:(NSNotification *)notification {
    self.duckingEnabled = [[notification object] boolValue];
    [self rebuildVolumeAndDuckingState];
}

- (void)toggleShowTitlesEnabledState:(NSNotification *)notification {
    self.titlesEnabled = [[notification object] boolValue];
    [self addTitleItems];
    [self.collectionView reloadData];
}

- (NSArray *)buildVolumeFadesForMusicItem:(GIAudioItem *)item {
    // 1.5 second fade
    CMTime fadeTime = GIDefaultFadeInOutTime;
    NSMutableArray *automation = [NSMutableArray array];
    CMTimeRange startRange = CMTimeRangeMake(kCMTimeZero, fadeTime);
    if (self.volumeFadesEnabled) {
        [automation addObject:[GIVolumeAutomation volumeAutomationWithTimeRange:startRange
                                                                    startVolume:0.0f
                                                                      endVolume:1.0f]];
    }
    
    if (self.duckingEnabled) {
        NSArray *voiceOvers = self.dataSource.timelineItems[GICommentaryTrack];
        for (GITimelineItemViewModel *model in voiceOvers) {
            GITimelineItem *mediaItem = model.timelineItem;
            CMTimeRange timeRange = mediaItem.timeRange;
            CMTime halfSecond = GIDefaultDuckingFadeInOutTime;
            CMTime startTime = CMTimeSubtract(mediaItem.startTimeInTimeline, halfSecond);
            CMTime endRangeStartTime = CMTimeAdd(mediaItem.startTimeInTimeline, timeRange.duration);
            CMTimeRange endRange = CMTimeRangeMake(endRangeStartTime, halfSecond);
            
            [automation addObject:[GIVolumeAutomation volumeAutomationWithTimeRange:CMTimeRangeMake(startTime, halfSecond)
                                                                        startVolume:1.0f
                                                                          endVolume:0.2f]];
            [automation addObject:[GIVolumeAutomation volumeAutomationWithTimeRange:endRange
                                                                        startVolume:0.2f
                                                                          endVolume:1.0f]];
        }
    }
    
    // Add fade out over 2 seconds at the end of the music track
    // The start time will potentially be adjusted if the music track is trimmed
    // to the video track duration when the composition is built.
    CMTime endRangeStartTime = CMTimeSubtract(item.timeRange.duration, fadeTime);
    CMTimeRange endRange = CMTimeRangeMake(endRangeStartTime, fadeTime);
    if (self.volumeFadesEnabled) {
        [automation addObject:[GIVolumeAutomation volumeAutomationWithTimeRange:endRange
                                                                    startVolume:1.0f
                                                                      endVolume:0.0f]];
    }
    return automation.count > 0 ? automation : nil;
}

- (void)rebuildVolumeAndDuckingState {
    [self updateMusicTrackVolumeAutomation];
    [self.collectionView reloadData];
}

- (NSUInteger)countOfVideosInTimeline {
    NSUInteger count = 0;
    for (id item in self.dataSource.timelineItems[GIVideoTrack]) {
        if (![item isKindOfClass:[GIVideoTransition class]]) {
            count++;
        }
    }
    return count;
}

#pragma mark - setter

- (void)setTransitionsEnabled:(BOOL)enabled {
    _transitionsEnabled = enabled;
    NSMutableArray *items = [NSMutableArray array];
    for (id item in self.dataSource.timelineItems[GIVideoTrack]) {
        if ([item isKindOfClass:[GITimelineItemViewModel class]]) {
            GITimelineItemViewModel *model = (GITimelineItemViewModel *)item;
            if ([model.timelineItem isKindOfClass:[GIMediaItem class]]) {
                [items addObject:model];
                if (enabled && (items.count % 2 != 0)) {
                    [items addObject:[GIVideoTransition disolveTransitionWithDuration:CMTimeMake(1, 2)]];
                }
            }
        }
    }
    if ([[items lastObject] isKindOfClass:[GIVideoTransition class]]) {
        [items removeLastObject];
    }
    self.dataSource.timelineItems[GIVideoTrack] = items;
}

@end

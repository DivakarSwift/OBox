//
//  GITimelineDataSource.m
//  AudioBox
//
//  Created by kegebai on 2018/9/11.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GITimelineDataSource.h"
#import "GITimelineViewController.h"
#import "GIAudioItemCollectionViewCell.h"
#import "GITransitionCollectionViewCell.h"
#import "GITimelineItemCollectionViewCell.h"
#import "GIVideoItemCollectionViewCell.h"
#import "GIModels.h"
#import "GITimelineItemViewModel.h"
#import "GITransitionViewController.h"

static NSString * const GIVideoItemCollectionViewCellID  = @"GIVideoItemCollectionViewCell";
static NSString * const GITransitionCollectionViewCellID = @"GITransitionCollectionViewCell";
static NSString * const GITitleItemCollectionViewCellID  = @"GITitleItemCollectionViewCell";
static NSString * const GIAudioItemCollectionViewCellID  = @"GIAudioItemCollectionViewCell";

@interface GITimelineDataSource () <GITransitionViewControllerDelegate>

@property (nonatomic, weak) GITimelineViewController *controller;
@property (nonatomic) UIPopoverController *transitionPopoverController;

@end

@implementation GITimelineDataSource

+ (id)dataSourceWithController:(UIViewController *)controller {
    return [[self alloc] initWithController:controller];
}

- (id)initWithController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        _controller = (GITimelineViewController *)controller;
        [self resetTimeline];
    }
    return self;
}

- (void)resetTimeline {
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[NSMutableArray array]];
    [items addObject:[NSMutableArray array]];
    [items addObject:[NSMutableArray array]];
    [items addObject:[NSMutableArray array]];
    self.timelineItems = items;
}

- (void)clearTimeline {
    self.timelineItems = [NSMutableArray array];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.timelineItems.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.timelineItems[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = [self cellIDForIndexPath:indexPath];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.contentView.frame = cell.bounds;
    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleHeight |
                                        UIViewAutoresizingFlexibleBottomMargin;
    
    if ([cellID isEqualToString:GIVideoItemCollectionViewCellID]) {
        [self configureVideoItemCell:(GIVideoItemCollectionViewCell *)cell withItemAtIndexPath:indexPath];
    }
    else if ([cellID isEqualToString:GIAudioItemCollectionViewCellID]) {
        [self configureAudioItemCell:(GIAudioItemCollectionViewCell *)cell withItemAtIndexPath:indexPath];
    }
    else if ([cellID isEqualToString:GITransitionCollectionViewCellID]) {
        GITransitionCollectionViewCell *transitionCell = (GITransitionCollectionViewCell *)cell;
        GIVideoTransition *transition = self.timelineItems[indexPath.section][indexPath.row];
        transitionCell.button.transitionType = transition.type;
    }
    else if ([cellID isEqualToString:GITitleItemCollectionViewCellID]) {
        [self configureTitleItemCell:(GITimelineItemCollectionViewCell *)cell withItemAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateTimelineLayout

- (void)collectionView:(UICollectionView *)collectionView
      didAdjustToWidth:(CGFloat)width
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GITimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
    if (width <= model.maxWidthInTimeline) {
        model.widthInTimeline = width;
    }
}

- (void)collectionView:(UICollectionView *)collectionView
   didAdjustToPosition:(CGPoint)position
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == GICommentaryTrack || indexPath.section == GITitleTrack) {
        GITimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
        model.positionInTimeline = position;
        [model updateTimelineItem];
        if (indexPath.section == GICommentaryTrack) {
            [self.controller updateMusicTrackVolumeAutomation];
        }
        [self.controller.collectionView reloadData];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView widthForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.controller.transitionsEnabled && indexPath.section == 0 && indexPath.item > 0) {
        if (indexPath.item % 2 != 0) {
            return 32.0f;
        }
    }
    GITimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
    return model.widthInTimeline;
}

- (CGPoint)collectionView:(UICollectionView *)collectionView positionForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == GICommentaryTrack || indexPath.section == GITitleTrack) {
        GITimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
        return model.positionInTimeline;
    }
    return CGPointZero;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
   canAdjustToPosition:(CGPoint)point
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == GICommentaryTrack) {
        CMTime time = GIGetTimeForOrigin(point.x, TIMELINE_WIDTH / TIMELINE_SECONDS);
        CMTime fadeInEnd = CMTimeAdd(GIDefaultFadeInOutTime, GIDefaultDuckingFadeInOutTime);
        CMTime fadeOutBegin = CMTimeSubtract(CMTimeMake((int64_t)TIMELINE_SECONDS, 1), fadeInEnd);
        return CMTIME_COMPARE_INLINE(time, >=, fadeInEnd) && CMTIME_COMPARE_INLINE(time, <=, fadeOutBegin);
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id selectedItem = self.timelineItems[indexPath.section][indexPath.item];
    if ([selectedItem isKindOfClass:[GIVideoTransition class]]) {
        [self configureTransition:selectedItem atIndexPath:indexPath];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 && !self.controller.transitionsEnabled;
}

- (void)collectionView:(UICollectionView *)collectionView
didMoveMediaItemAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    
    NSMutableArray *items = self.timelineItems[fromIndexPath.section];
    if (fromIndexPath.item == toIndexPath.item) {
        NSLog(@"FUBAR:  Attempting to move: %li to %li.", (long)fromIndexPath.item, (long)toIndexPath.item);
        NSAssert(NO, @"Attempting to make invalid move.");
    }
    [items exchangeObjectAtIndex:fromIndexPath.item withObjectAtIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)theCollectionView
                layout:(UICollectionViewLayout *)theLayout
       itemAtIndexPath:(NSIndexPath *)theFromIndexPath
 shouldMoveToIndexPath:(NSIndexPath *)theToIndexPath {
    
    return theFromIndexPath.section == theToIndexPath.section;
}

- (void)collectionView:(UICollectionView *)collectionView willDeleteItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.timelineItems[indexPath.section] removeObjectAtIndex:indexPath.row];
}

#pragma mark - GITransitionViewControllerDelegate

- (void)transitionSelected {
    [self.transitionPopoverController dismissPopoverAnimated:YES];
    self.transitionPopoverController = nil;
    [self.controller.collectionView reloadData];
}

#pragma mark - private

- (NSString *)cellIDForIndexPath:(NSIndexPath *)indexPath {
    if (self.controller.transitionsEnabled && indexPath.section == 0) {
        // Video items are at odd indexes, transitions are at even indexes
        return (indexPath.item % 2 == 0) ? GIVideoItemCollectionViewCellID : GITransitionCollectionViewCellID;
    }
    else if (indexPath.section == 0) {
        return GIVideoItemCollectionViewCellID;
    }
    else if (indexPath.section == 1) {
        return GITitleItemCollectionViewCellID;
    }
    else if (indexPath.section == 2 || indexPath.section == 3) {
        return GIAudioItemCollectionViewCellID;
    }
    return nil;
}

- (void)configureVideoItemCell:(GIVideoItemCollectionViewCell *)cell withItemAtIndexPath:(NSIndexPath *)indexPath {
    GITimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
    GIVideoItem *item = (GIVideoItem *)model.timelineItem;
    cell.maxTimeRange = item.timeRange;
    cell.itemView.label.text = item.title;
    cell.itemView.backgroundColor = [UIColor colorWithRed:0.523 green:0.641 blue:0.851 alpha:1.000];
}

- (void)configureAudioItemCell:(GIAudioItemCollectionViewCell *)cell withItemAtIndexPath:(NSIndexPath *)indexPath {
    GITimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
    if (indexPath.section == GIMusicTrack) {
        GIAudioItem *item = (GIAudioItem *)model.timelineItem;
        cell.volumeAutomationView.audioRamps = item.volumeAutomation;
        cell.volumeAutomationView.duration = item.timeRange.duration;
        cell.itemView.backgroundColor = [UIColor colorWithRed:0.361 green:0.724 blue:0.366 alpha:1.000];
    } else {
        cell.volumeAutomationView.audioRamps = nil;
        cell.volumeAutomationView.duration = kCMTimeZero;
        cell.itemView.backgroundColor = [UIColor colorWithRed:0.992 green:0.785 blue:0.106 alpha:1.000];
    }
}

- (void)configureTitleItemCell:(GITimelineItemCollectionViewCell *)cell withItemAtIndexPath:(NSIndexPath *)indexPath {
    GITimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
    GITitleItem *layer = (GITitleItem *)model.timelineItem;
    cell.itemView.label.text = layer.identifier;
    cell.itemView.backgroundColor = [UIColor colorWithRed:0.741 green:0.556 blue:1.000 alpha:1.000];
}

- (void)configureTransition:(GIVideoTransition *)transition atIndexPath:(NSIndexPath *)indexPath {
    GITransitionViewController *transitionController = [GITransitionViewController controllerWithTransition:transition];
    transitionController.delegate = self;
    self.transitionPopoverController = [[UIPopoverController alloc] initWithContentViewController:transitionController];
    
    UICollectionViewCell *cell = [self.controller.collectionView cellForItemAtIndexPath:indexPath];
    [self.transitionPopoverController presentPopoverFromRect:cell.frame
                                                      inView:self.controller.view
                                    permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

@end

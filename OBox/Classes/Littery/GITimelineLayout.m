//
//  GITimelineLayout.m
//  AudioBox
//
//  Created by kegebai on 2018/8/20.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GITimelineLayout.h"
#import "GIVideoItemCollectionViewCell.h"

@implementation GITimelineLayoutAttributes

@end

typedef NS_ENUM(NSUInteger, GIPanDirection) {
    GIPanDirectionLeft = 0,
    GIPanDirectionRight
};

//typedef enum {
//    GIPanDirectionLeft = 0,
//    GIPanDirectionRight
//} GIPanDirection;

typedef NS_ENUM(NSUInteger, GIDragMode) {
    GIDragModeNone = 0,
    GIDragModeMove,
    GIDragModeTrim
};

//typedef enum {
//    GIDragModeNone = 0,
//    GIDragModeMove,
//    GIDragModeTrim
//} GIDragMode;

#define DEFAULT_TRACK_HEIGHT         80.0f
#define DEFAULT_CLIP_SPACING         0.0f
#define TRANSITION_ITEM_HEIGHT_WIDTH 32.0f
#define VERTICAL_PADDING             4.0f
#define DEFAULT_INSETS               UIEdgeInsetsMake(4.0f, 5.0f, 5.0f, 5.0f)

@interface GITimelineLayout () <UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSDictionary *initialLayout;
@property (nonatomic, copy) NSDictionary *caculatedLayout;
@property (nonatomic, copy) NSArray *updates;

@property (nonatomic) CGSize contentSize;
@property (nonatomic) CGFloat scaleUnit;
@property (nonatomic) BOOL swapInProgress;
@property (nonatomic) BOOL trimming;

@property (nonatomic) GIPanDirection panDirection;
@property (nonatomic) GIDragMode dragMode;

@property (nonatomic, weak) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, weak) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIImageView *draggableImageView;

@end

@implementation GITimelineLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _trackHeight = DEFAULT_TRACK_HEIGHT;
    _trackInsets = DEFAULT_INSETS;
    _clipSpacing = DEFAULT_CLIP_SPACING;
    _reorderingAllowed = YES;
    _dragMode = GIDragModeTrim;
}

#pragma mark - setter

- (void)setTrackHeight:(CGFloat)trackHeight {
    _trackHeight = trackHeight;
    [self invalidateLayout];
}

- (void)setTrackInsets:(UIEdgeInsets)trackInsets {
    _trackInsets = trackInsets;
    [self invalidateLayout];
}

- (void)setClipSpacing:(CGFloat)clipSpacing {
    _clipSpacing = clipSpacing;
    [self invalidateLayout];
}

- (void)setReorderingAllowed:(BOOL)reorderingAllowed {
    _reorderingAllowed = reorderingAllowed;
    self.panGestureRecognizer.enabled = reorderingAllowed;
    self.longPressGestureRecognizer.enabled = reorderingAllowed;
    [self invalidateLayout];
}

#pragma mark - overrides

+ (Class)layoutAttributesClass {
    return GITimelineLayoutAttributes.class;
}

- (void)prepareLayout {
    NSMutableDictionary *layoutDict = [NSMutableDictionary dictionary];
    CGFloat xPos = self.trackInsets.left;
    CGFloat yPos = 0;
    CGFloat maxTrackWidth = 0.0f;
    
    id<UICollectionViewDelegateTimelineLayout> delegate = (id<UICollectionViewDelegateTimelineLayout>)self.collectionView.delegate;
    NSUInteger sections = [self.collectionView numberOfSections];
    
    for (NSInteger section = 0; section < sections; section++) {
        for (NSInteger item = 0, items = [self.collectionView numberOfItemsInSection:section]; item < items; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            GITimelineLayoutAttributes *attributes = (GITimelineLayoutAttributes *)[UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            CGFloat width    = [delegate collectionView:self.collectionView widthForItemAtIndexPath:indexPath];
            CGPoint position = [delegate collectionView:self.collectionView positionForItemAtIndexPath:indexPath];
            
            if (position.x > 0.0f) {
                xPos = position.x;
            }
            
            attributes.frame = CGRectMake(xPos, yPos + self.trackInsets.top, width, self.trackHeight - self.trackInsets.bottom);
            
            if (width == TRANSITION_ITEM_HEIGHT_WIDTH) {
                CGRect rect = attributes.frame;
                rect.origin.y += ((rect.size.height - TRANSITION_ITEM_HEIGHT_WIDTH) / 2) + VERTICAL_PADDING;
                rect.origin.x -= (TRANSITION_ITEM_HEIGHT_WIDTH / 2);
                attributes.frame  = rect;
                attributes.zIndex = 1;
            }
            
            if ([self.selectedIndexPath isEqual:indexPath]) {
                attributes.hidden = YES;
            }
            
            layoutDict[indexPath] = attributes;
            
            if (width != TRANSITION_ITEM_HEIGHT_WIDTH) {
                xPos += (width + self.clipSpacing);
            }
        }
        
        if (xPos > maxTrackWidth) {
            maxTrackWidth = xPos;
        }
        
        xPos = self.trackInsets.left;
        yPos += self.trackHeight;
    }
    
    self.contentSize = CGSizeMake(maxTrackWidth, self.trackHeight * sections);
    self.caculatedLayout = layoutDict;
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.caculatedLayout.count];
    
    for (NSIndexPath *indexPath in self.caculatedLayout) {
        UICollectionViewLayoutAttributes *attributes = self.caculatedLayout[indexPath];
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [allAttributes addObject:attributes];
        }
    }
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.caculatedLayout[indexPath];
}

#pragma mark - Set up Gesture Recognizers

- (void)awakeFromNib {
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.minimumPressDuration = 0.5f;
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    tapRecognizer.numberOfTapsRequired    = 2;
    
    // Set up dependencies with built-in recognizers
    for (UIGestureRecognizer *recognizer in self.collectionView.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            [recognizer requireGestureRecognizerToFail:panRecognizer];
        }
        else if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [recognizer requireGestureRecognizerToFail:longPressRecognizer];
        }
    }
    
    self.longPressGestureRecognizer = longPressRecognizer;
    self.panGestureRecognizer = panRecognizer;
    self.tapGestureRecognizer = tapRecognizer;
    
    self.longPressGestureRecognizer.delegate = self;
    self.panGestureRecognizer.delegate = self;
    self.tapGestureRecognizer.delegate = self;
    
    [self.collectionView addGestureRecognizer:longPressRecognizer];
    [self.collectionView addGestureRecognizer:panRecognizer];
    [self.collectionView addGestureRecognizer:tapRecognizer];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherRecognizer {
    return YES;
}

#pragma mark - Handler UIGestureRecognizer

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.dragMode = GIDragModeMove;
        CGPoint location = [recognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
        
        if (!indexPath) {
            return;
        }
        
        self.selectedIndexPath = indexPath;
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        cell.highlighted = YES;
        
//        self.draggableImageView =
        self.draggableImageView.frame = cell.frame;
        [self.collectionView addSubview:self.draggableImageView];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:self.selectedIndexPath];
        [UIView animateWithDuration:0.15 animations:^{
            self.draggableImageView.frame = attributes.frame;
        } completion:^(BOOL finished) {
            [self invalidateLayout];
            
            [UIView animateWithDuration:0.2 animations:^{
                self.draggableImageView.layer.opacity = 0.0f;
            } completion:^(BOOL finished) {
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
                cell.selected = YES;
                [self.draggableImageView removeFromSuperview];
                self.draggableImageView = nil;
            }];
            
            self.selectedIndexPath = nil;
            self.dragMode = GIDragModeTrim;
        }];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    id<UICollectionViewDelegateTimelineLayout> delegate = (id<UICollectionViewDelegateTimelineLayout>)self.collectionView.delegate;
    [delegate collectionView:self.collectionView willDeleteItemAtIndexPath:indexPath];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

- (void)handleDrag:(UIPanGestureRecognizer *)recognizer {
    CGPoint location       = [recognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    CGPoint translation    = [recognizer translationInView:self.collectionView];
    self.panDirection      = translation.x > 0 ? GIPanDirectionRight : GIPanDirectionLeft;
    
    GIVideoItemCollectionViewCell *cell = (GIVideoItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self invalidateLayout];
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        
        if (self.dragMode == GIDragModeMove) {
            CGPoint center = self.draggableImageView.center;
            
            if (self.selectedIndexPath.section == 0) {
                self.draggableImageView.center = CGPointMake(center.x + translation.x, center.y + translation.y);
                if (!self.swapInProgress) {
                    [self swapClip];
                }
            } else {
                CGPoint constrainedPoint = self.draggableImageView.center;
                CGPoint newCenter  = CGPointMake(constrainedPoint.x + translation.x, constrainedPoint.y);
                id<UICollectionViewDelegateTimelineLayout> delegate = (id<UICollectionViewDelegateTimelineLayout>)self.collectionView.delegate;
                
                CGPoint originLeft = CGPointMake(newCenter.x - self.draggableImageView.width / 2, 0.0f);
                if (![delegate collectionView:self.collectionView canAdjustToPosition:originLeft forItemAtIndexPath:self.selectedIndexPath]) {
                    return;
                }
                
                CGPoint originRight = CGPointMake(newCenter.x + self.draggableImageView.width / 2, 0.0f);
                if (![delegate collectionView:self.collectionView canAdjustToPosition:originRight forItemAtIndexPath:self.selectedIndexPath]) {
                    return;
                }
                
                self.draggableImageView.center = newCenter;
                [delegate collectionView:self.collectionView didAdjustToPosition:originLeft forItemAtIndexPath:self.selectedIndexPath];
            }
        }
        else {
            if (indexPath.section != 0) {
                return;
            }
            
            CMTimeRange timeRange = cell.maxTimeRange;
            self.scaleUnit = CMTimeGetSeconds(timeRange.duration) / cell.width;
            
            NSArray *selectedIndexPaths = [self.collectionView indexPathsForSelectedItems];
            if (selectedIndexPaths && selectedIndexPaths.count > 0) {
                NSIndexPath *selectIndexPath = selectedIndexPaths[0];
                if (selectIndexPath) {
                    cell = (GIVideoItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:selectIndexPath];
                    if (cell && [cell respondsToSelector:@selector(isPointInDragHandle:)]) {
                        if ([cell isPointInDragHandle:[self.collectionView convertPoint:location toView:cell]]) {
                            self.trimming = YES;
                        }
                        
                        if (self.trimming) {
                            CGFloat newWidth = cell.width + translation.x;
                            [self adjustedToWidth:newWidth];
                        }
                    }
                }
            }
        }
        // Reset translation point as translation amounts are cumulative
        [recognizer setTranslation:CGPointZero inView:self.collectionView];
    }
    // User Ended Gesture
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        self.trimming = NO;
    }
}

- (BOOL)shouldSwapSelectedIndexPath:(NSIndexPath *)selected withIndexPath:(NSIndexPath *)hovered {
    if (self.panDirection == GIPanDirectionRight) {
        return selected.row < hovered.row;
    } else {
        return selected.row > hovered.row;
    }
}

- (void)swapClip {
    NSIndexPath *hoverIndexPath = [self.collectionView indexPathForItemAtPoint:self.draggableImageView.center];
    id<UICollectionViewDelegateTimelineLayout> delegate = (id<UICollectionViewDelegateTimelineLayout>)self.collectionView.delegate;
    
    if (hoverIndexPath && [self shouldSwapSelectedIndexPath:self.selectedIndexPath withIndexPath:hoverIndexPath]) {
        
        if (![delegate collectionView:self.collectionView canMoveItemAtIndexPath:hoverIndexPath]) {
            return;
        }
        
        self.swapInProgress = YES;
        NSIndexPath *lastSelectedIndexPath = self.selectedIndexPath;
        self.selectedIndexPath = hoverIndexPath;
        
        [delegate collectionView:self.collectionView didMoveMediaItemAtIndexPath:lastSelectedIndexPath toIndexPath:self.selectedIndexPath];
        
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:@[lastSelectedIndexPath]];
            [self.collectionView insertItemsAtIndexPaths:@[self.selectedIndexPath]];
        } completion:^(BOOL finished) {
            self.swapInProgress = NO;
            [self invalidateLayout];
        }];
    }
}

- (void)adjustedToWidth:(CGFloat)width {
    id<UICollectionViewDelegateTimelineLayout> delegate = (id<UICollectionViewDelegateTimelineLayout>)self.collectionView.delegate;
    NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
    [delegate collectionView:self.collectionView didAdjustToWidth:width forItemAtIndexPath:indexPath];
    [self invalidateLayout];
}

@end

//
//  GIPlayheadView.m
//  VRMicro
//
//  Created by kegebai on 2018/5/10.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIPlayheadView.h"

#define X_OFFSET 5.0f

static inline NSNumber *xPositionForTime(CMTime time) {
    return @(GIGetOriginForTime(time).x + X_OFFSET);
}

@implementation GIPlayheadView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearPlayhead:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
    }
    return self;
}

- (void)synchronizedPlayerItem:(AVPlayerItem *)item {
    // Remove existing sublayers
    [self reset];
    
    // Red line is 4 pts wide
    CGRect lineRect = CGRectMake(0, 0, 4.f, self.layer.bounds.size.height);
    CAShapeLayer *redline = [CAShapeLayer layer];
    redline.path  = [UIBezierPath bezierPathWithRect:lineRect].CGPath;
    redline.frame = lineRect;
    redline.fillColor = [UIColor colorWithRed:1.f green:0 blue:0 alpha:0.4f].CGColor;
    
    // White line is 1 pt wide
    lineRect.origin.x = 0;
    lineRect.size.width = 1;
    
    // Position the white line layer of the timeMarker at the center of the red band layer
    CAShapeLayer *whiteline = [CAShapeLayer layer];
    whiteline.path  = [UIBezierPath bezierPathWithRect:lineRect].CGPath;
    whiteline.frame = lineRect;
    whiteline.position  = CGPointMake(2.f, self.bH / 2);
    whiteline.fillColor = [UIColor whiteColor].CGColor;
    
    // Add the white line layer to red line layer
    [redline addSublayer:whiteline];
    
    // Configure basic animation to animate the x position of the playhead
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animation.fromValue = xPositionForTime(kCMTimeZero);
    animation.toValue   = xPositionForTime(item.duration);
    animation.removedOnCompletion = NO;
    animation.beginTime = AVCoreAnimationBeginTimeAtZero;
    animation.duration  = CMTimeGetSeconds(item.duration);
    animation.fillMode  = kCAFillModeBoth;
    [redline addAnimation:animation forKey:nil];
    
    // Create AVSynchronizedLayer to synchronize with player's timing
    AVSynchronizedLayer *syncLayer = [AVSynchronizedLayer synchronizedLayerWithPlayerItem:item];
    [syncLayer  addSublayer:redline];
    [self.layer addSublayer:syncLayer];
    // Trigger redraw to update UI
    [self.layer setNeedsDisplay];
}

- (void)reset {
    self.layer.sublayers = nil;
}

#pragma mark - action

- (void)clearPlayhead:(NSNotification *)notification {
    [self reset];
}

@end

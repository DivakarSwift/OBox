//
//  VRCaptureButton.m
//  VRMicro
//
//  Created by kegebai on 2018/5/3.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "VRCaptureButton.h"

@interface VRPhotoCaptureButton : VRCaptureButton

@end

@interface VRVideoCaptureButton : VRPhotoCaptureButton

@end

#define DEFAULT_FRAME CGRectMake(0.0f, 0.0f, 68.0f, 68.0f)
#define LINE_WIDTH    6.0f

@interface VRCaptureButton ()
@property (nonatomic, strong) CALayer *circleLayer;
@end

@implementation VRCaptureButton

+ (id)captureButtonWithMode:(VRCaptureMode)captureMode {
    return [[self alloc] initWithCaptureMode:captureMode];
}

+ (id)captureButton {
    return [self captureButtonWithMode:VRCaptureModeVideo];
}

- (id)initWithCaptureMode:(VRCaptureMode)captureMode {
    self = [super initWithFrame:DEFAULT_FRAME];
    if (self) {
        _captureMode = captureMode;
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = [UIColor clearColor];
        
        UIColor *circleColor = (self.captureMode == VRCaptureModeVideo) ? [UIColor redColor] : [UIColor whiteColor];
        _circleLayer = [CALayer layer];
        _circleLayer.backgroundColor = circleColor.CGColor;
        _circleLayer.bounds = CGRectInset(self.bounds, 8.0, 8.0);
        _circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        _circleLayer.cornerRadius = _circleLayer.bounds.size.width / 2.0f;
        [self.layer addSublayer:_circleLayer];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, LINE_WIDTH);
    CGContextStrokeEllipseInRect(context, CGRectInset(rect, LINE_WIDTH / 2.0f, LINE_WIDTH / 2.0f));
}

#pragma mark - setter

- (void)setCaptureMode:(VRCaptureMode)captureMode {
    _captureMode = captureMode;
    UIColor *toColor = (_captureMode == VRCaptureModeVideo) ? [UIColor redColor] : [UIColor whiteColor];
    self.circleLayer.backgroundColor = toColor.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    fadeAnimation.duration = 0.2f;
    if (highlighted) {
        fadeAnimation.toValue = @0.0f;
    } else {
        fadeAnimation.toValue = @1.0f;
    }
    self.circleLayer.opacity = [fadeAnimation.toValue floatValue];
    [self.circleLayer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.captureMode == VRCaptureModeVideo) {
        [CATransaction disableActions];
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        CABasicAnimation *radiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        if (selected) {
            scaleAnimation.toValue = @0.6f;
            radiusAnimation.toValue = @(self.circleLayer.bounds.size.width / 4.0f);
        } else {
            scaleAnimation.toValue = @1.0f;
            radiusAnimation.toValue = @(self.circleLayer.bounds.size.width / 2.0f);
        }
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[scaleAnimation, radiusAnimation];
        animationGroup.beginTime = CACurrentMediaTime() + 0.2f;
        animationGroup.duration = 0.35f;
        
        [self.circleLayer setValue:radiusAnimation.toValue forKeyPath:@"cornerRadius"];
        [self.circleLayer setValue:scaleAnimation.toValue forKeyPath:@"transform.scale"];
        
        [self.circleLayer addAnimation:animationGroup forKey:@"scaleAndRadiusAnimation"];
    }
}

@end

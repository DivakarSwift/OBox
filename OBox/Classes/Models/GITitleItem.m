//
//  GITitleItem.m
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GITitleItem.h"
#import "GIConstants.h"

static inline CATransform3D GIMakePerspectiveTransform(CGFloat eyePosition) {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / eyePosition;
    return transform;
}

@interface GITitleItem ()
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGRect bounds;
@end

@implementation GITitleItem

+ (id)titleItemWithText:(NSString *)text image:(UIImage *)image {
    return [[self alloc] initWithText:text image:image];
}

- (id)initWithText:(NSString *)text image:(UIImage *)image {
    self = [super init];
    if (self) {
        _text = [text copy];
        _image = image;
        _bounds = GI720pVideoBounds;
    }
    return self;
}

- (CALayer *)buildLayer {
    // Build layers
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = self.bounds;
    parentLayer.opacity = 0.0f;
    
    CALayer *imageLayer = [self makeImageLayer];
    [parentLayer addSublayer:imageLayer];
    
    CALayer *textLayer = [self makeTextLayer];
    [parentLayer addSublayer:textLayer];
    
    // Build and attach animation
    CAAnimation *fadeInFadeOutAnimation = [self makeFadeInFadeOutAnimation];
    [parentLayer addAnimation:fadeInFadeOutAnimation forKey:nil];
    
    if (self.animateImage) {
        parentLayer.sublayerTransform = GIMakePerspectiveTransform(1000);
        CAAnimation *spinAnimation = [self make3DSpinAnimation];
        NSTimeInterval offset = spinAnimation.beginTime + spinAnimation.duration - 0.5f;
        CAAnimation *popAnimation = [self makePopAnimationWithTimingOffset:offset];
        [imageLayer addAnimation:spinAnimation forKey:nil];
        [imageLayer addAnimation:popAnimation  forKey:nil];
    }
    
    return parentLayer;
}

#pragma mark - private - animation

- (CAAnimation *)makeFadeInFadeOutAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.values    = @[@0.f, @1.f, @1.f, @0.f];
    animation.keyTimes  = @[@0.f, @0.2f, @0.8f, @1.f];
    animation.beginTime = CMTimeGetSeconds(self.startTimeInTimeline);
    animation.duration  = CMTimeGetSeconds(self.timeRange.duration);
    animation.removedOnCompletion = NO;
    return animation;
}

- (CAAnimation *)make3DSpinAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    animation.toValue   = @((4 * M_PI) * -1);
    animation.beginTime = CMTimeGetSeconds(self.startTimeInTimeline) + 0.2;
    animation.duration  = CMTimeGetSeconds(self.timeRange.duration) * 0.4;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}

- (CAAnimation *)makePopAnimationWithTimingOffset:(NSTimeInterval)offset {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.toValue      = @1.3f;
    animation.beginTime    = offset;
    animation.duration     = 0.35f;
    animation.autoreverses = YES;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}

#pragma mark - private - layer

- (CALayer *)makeImageLayer {
    CALayer *layer = [CALayer layer];
    CGSize imageSize = self.image.size;
    layer.contents = (id)self.image.CGImage;
    layer.allowsEdgeAntialiasing = YES;
    layer.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    layer.position = CGPointMake(CGRectGetMidX(self.bounds) - 20.f, 270.f);
    return layer;
}

- (CALayer *)makeTextLayer {
    CATextLayer *layer = [CATextLayer layer];
    CGFloat fontSize = self.useLargeFont ? 64.f : 54.f;
    UIFont *font = [UIFont fontWithName:@"GillSans-Bold" size:fontSize];
    NSDictionary *attrs = @{
        NSFontAttributeName:font,
        NSForegroundColorAttributeName:(id)[UIColor whiteColor].CGColor
    };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.text attributes:attrs];
    CGSize textSize = [self.text sizeWithAttributes:attrs];
    layer.string = attrString;
    layer.bounds = CGRectMake(0, 0, textSize.width, textSize.height);
    layer.position = CGPointMake(CGRectGetMidX(self.bounds), 470.f);
    layer.backgroundColor = [UIColor clearColor].CGColor;
    return layer;
}

@end

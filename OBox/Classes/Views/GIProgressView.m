//
//  GIProgressView.m
//  VRMicro
//
//  Created by kegebai on 2018/5/10.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIProgressView.h"

#define kPROGRESS_BAR_W 160.f
#define kPROGRESS_BAR_H 22.f

@implementation GIProgressView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _innerColor = [UIColor colorWithWhite:0.906 alpha:1.000];
        _outerColor = [UIColor colorWithWhite:0.906 alpha:1.000];
        _emptyColor = [UIColor clearColor];
        
        if (self.width == 0.f) {
            self.width = kPROGRESS_BAR_W;
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // save the context
    CGContextSaveGState(context);
    
    // allow antialiasing
    CGContextSetAllowsAntialiasing(context, TRUE);
    
    // first, draw the outter rounded rectangle
    rect = CGRectInset(rect, 1.f, 1.f);
    CGFloat radius = 0.5 * rect.size.height;
    
    [self.outerColor setStroke];
    CGContextSetLineWidth(context, 2.f);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);
    
    // draw the empty rounded rectangle (shown for the "unfilled" portions of the progress
    rect = CGRectInset(rect, 3.0f, 3.0f);
    radius = 0.5f * rect.size.height;
    [self.emptyColor setFill];
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    // draw the inside moving filled rounded rectangle
    radius = 0.5f * rect.size.height;
    // make sure the filled rounded rectangle is not smaller than 2 times the radius
    rect.size.width *= self.progress;
    if (rect.size.width < 2 * radius) {
        rect.size.width = 2 * radius;
    }
    [self.innerColor setFill];
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    // restore the context
    CGContextRestoreGState(context);
}

#pragma mark - setter

- (void)setProgress:(CGFloat)progress {
    // make sure the user does not try to set the progress outside of the bounds
    if (progress > 1.0f) {
        progress = 1.0f;
    }
    if (progress < 0.0f) {
        progress = 0.0f;
    }
    
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame {
    // we set the height ourselves since it is fixed
    frame.size.height = kPROGRESS_BAR_H;
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
    // we set the height ourselves since it is fixed
    bounds.size.height = kPROGRESS_BAR_H;
    [super setBounds:bounds];
}

@end

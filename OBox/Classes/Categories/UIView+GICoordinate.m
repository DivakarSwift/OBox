//
//  UIView+GICoordinate.m
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "UIView+GICoordinate.h"

@implementation UIView (GICoordinate)

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y {
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

- (CGFloat)bX {
    return self.bounds.origin.x;
}

- (void)setBX:(CGFloat)bX {
    self.bounds = CGRectMake(bX, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
}

- (CGFloat)bY {
    return self.bounds.origin.y;
}

- (void)setBY:(CGFloat)bY{
    self.bounds = CGRectMake(self.bounds.origin.x, bY, self.bounds.size.width, self.bounds.size.height);
}

- (CGFloat)bW {
    return self.bounds.size.width;
}

- (void)setBW:(CGFloat)bW {
    self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, bW, self.bounds.size.height);
}

- (CGFloat)bH {
    return self.bounds.size.height;
}

- (void)setBH:(CGFloat)bH {
    self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, bH);
}

- (CGFloat)cX {
    return self.center.x;
}

- (void)setCX:(CGFloat)cX {
    self.center = CGPointMake(cX, self.center.y);
}

- (CGFloat)cY {
    return self.center.y;
}

- (void)setCY:(CGFloat)cY {
    self.center = CGPointMake(self.center.x, cY);
}

@end

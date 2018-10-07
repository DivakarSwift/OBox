//
//  UIView+GICoordinate.h
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GICoordinate)
// frame
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
// origin
@property (nonatomic) CGPoint origin;
// size
@property (nonatomic) CGSize  size;
// bounds
@property (nonatomic) CGFloat bX;
@property (nonatomic) CGFloat bY;
@property (nonatomic) CGFloat bW;
@property (nonatomic) CGFloat bH;
// center
@property (nonatomic) CGFloat cX;
@property (nonatomic) CGFloat cY;

@end

//
//  GIVideoTransition.h
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

//typedef NS_ENUM(NSInteger, GIVideoTransitionType) {
//    GIVideoTransitionTypeNone = 0,
//    GIVideoTransitionTypeDissolve,
//    GIVideoTransitionTypePush,
//    GIVideoTransitionTypeWipe,
//};

typedef enum {
    GIVideoTransitionTypeNone = 0,
    GIVideoTransitionTypeDissolve,
    GIVideoTransitionTypePush,
    GIVideoTransitionTypeWipe,
} GIVideoTransitionType;

//typedef NS_ENUM(NSInteger, GIPushTransitionDirection) {
//    GIPushTransitionDirectionLeftToRight = 0,
//    GIPushTransitionDirectionRightToLeft,
//    GIPushTransitionDirectionTopToBottom,
//    GIPushTransitionDirectionBottomToTop,
//    GIPushTransitionDirectionInvalid = INT_MAX,
//};

typedef enum {
    GIPushTransitionDirectionLeftToRight = 0,
    GIPushTransitionDirectionRightToLeft,
    GIPushTransitionDirectionTopToBottom,
    GIPushTransitionDirectionBottomToTop,
    GIPushTransitionDirectionInvalid = INT_MAX,
} GIPushTransitionDirection;


@interface GIVideoTransition : NSObject

+ (id)videoTransition;

@property (nonatomic) GIVideoTransitionType type;
@property (nonatomic) GIPushTransitionDirection direction;
@property (nonatomic) CMTimeRange timeRange;
@property (nonatomic) CMTime duration;

#pragma mark - Convenience initializers for stock transitions

+ (id)disolveTransitionWithDuration:(CMTime)duration;

+ (id)pushTransitionWithDuration:(CMTime)duration
                       direction:(GIPushTransitionDirection)direction;

@end

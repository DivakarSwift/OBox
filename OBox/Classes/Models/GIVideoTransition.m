//
//  GIVideoTransition.m
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIVideoTransition.h"

@implementation GIVideoTransition

+ (id)videoTransition {
    return [[[self class] alloc] init];
}

+ (id)disolveTransitionWithDuration:(CMTime)duration {
    GIVideoTransition *transition = [self videoTransition];
    transition.type = GIVideoTransitionTypeDissolve;
    transition.duration = duration;
    return transition;
}

+ (id)pushTransitionWithDuration:(CMTime)duration direction:(GIPushTransitionDirection)direction {
    GIVideoTransition *transition = [self videoTransition];
    transition.type = GIVideoTransitionTypeDissolve;
    transition.duration = duration;
    transition.direction = direction;
    return transition;
}

- (id)init {
    self = [super init];
    if (self) {
        _timeRange = kCMTimeRangeInvalid;
        _type = GIVideoTransitionTypeDissolve;
    }
    return self;
}

#pragma mark - setter

- (void)setDirection:(GIPushTransitionDirection)direction {
    if (self.type == GIVideoTransitionTypePush) {
        _direction = direction;
    } else {
        _direction = GIPushTransitionDirectionInvalid;
        NSAssert(NO, @"Direction can only be specified for a type == GIVideoTransitionTypePush.");
    }
}

@end

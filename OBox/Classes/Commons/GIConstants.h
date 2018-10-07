//
//  GIConstants.h
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

static const CGFloat TIMELINE_SECONDS = 15.0f;
static const CGFloat TIMELINE_WIDTH   = 1014.0f;

static const CGRect GI1080pVideoBounds = {{0.0f, 0.0f}, {1920.0f, 1080.f}};
static const CGRect GI720pVideoBounds  = {{0.0f, 0.0f}, {1280.0f, 720.0f}};

static const CGSize GI1080pVideoSize = {1920.0f, 1080.0f};
static const CGSize GI720pVideoSize  = {1280.0f, 720.0f};

static const CMTime GIDefaultFadeInOutTime        = {3, 2, 1, 0}; // 1.5 seconds
static const CMTime GIDefaultDuckingFadeInOutTime = {1, 2, 1, 0}; // 0.5 seconds
static const CMTime GIDefaultTransitionDuration   = {1, 1, 1, 0}; // 1 second

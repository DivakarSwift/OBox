//
//  GIVideoItem.h
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIMediaItem.h"
#import "GIVideoTransition.h"

@interface GIVideoItem : GIMediaItem

@property (nonatomic, copy) NSArray *thumbnails;

+ (id)videoItemWithURL:(NSURL *)url;

@property (nonatomic, strong) GIVideoTransition *startTransition;
@property (nonatomic, strong) GIVideoTransition *endTransition;

@property (nonatomic, readonly) CMTimeRange playthroughTimeRange;
@property (nonatomic, readonly) CMTimeRange startTransitionTimeRange;
@property (nonatomic, readonly) CMTimeRange endTransitionTimeRange;

@end

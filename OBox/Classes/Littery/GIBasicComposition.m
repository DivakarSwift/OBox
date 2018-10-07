//
//  GIBasicComposition.m
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIBasicComposition.h"

@interface GIBasicComposition ()
@property (nonatomic, readwrite, copy) AVComposition *composition;
@end

@implementation GIBasicComposition

+ (id)composition:(AVComposition *)composition {
    return [[self alloc] initWithComposition:composition];
}

- (id)initWithComposition:(AVComposition *)composition {
    self = [super init];
    if (self) {
        _composition = [composition copy];
    }
    return self;
}

- (AVPlayerItem *)makePlayable {
    return [AVPlayerItem playerItemWithAsset:self.composition];
}

- (AVAssetExportSession *)makeExportable {
    return [AVAssetExportSession exportSessionWithAsset:self.composition
                                             presetName:AVAssetExportPresetHighestQuality];
}

@end

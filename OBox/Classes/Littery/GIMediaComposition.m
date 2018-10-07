//
//  GIMediaComposition.m
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIMediaComposition.h"
#import "AVPlayerItem+GISync.h"
#import "GIConstants.h"

@implementation GIMediaComposition

- (id)initWithComposition:(AVComposition *)composition
         videoComposition:(AVVideoComposition *)videoComposition
                 audioMix:(AVAudioMix *)audioMix
               titleLayer:(CALayer *)titleLayer {
    self = [super init];
    if (self) {
        _composition = [composition copy];
        _videoComposition = [videoComposition copy];
        _audioMix = [audioMix copy];
        _titleLayer = titleLayer;
    }
    return self;
}

- (AVPlayerItem *)makePlayable {
    AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:self.composition];
    playItem.videoComposition = self.videoComposition;
    playItem.audioMix = self.audioMix;
    if (self.titleLayer) {
        AVSynchronizedLayer *syncLayer = [AVSynchronizedLayer synchronizedLayerWithPlayerItem:playItem];
        [syncLayer addSublayer:self.titleLayer];
        // WARNING: This the 'titleLayer' property is NOT part of AV Foundation
        // Provided by AVPlayerItem+GISync category.
        playItem.syncLayer = syncLayer;
    }
    return playItem;
}

- (AVAssetExportSession *)makeExportable {
    if (self.titleLayer) {
        CALayer *animationLayer = [CALayer layer];
        animationLayer.frame = GI720pVideoBounds;
        
        CALayer *videoLayer = [CALayer layer];
        videoLayer.frame = GI720pVideoBounds;
        
        [animationLayer addSublayer:videoLayer];
        [animationLayer addSublayer:self.titleLayer];
        animationLayer.geometryFlipped = YES;
        
        AVVideoCompositionCoreAnimationTool *animationTool =
        [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
                                                                                                     inLayer:animationLayer];
        AVMutableVideoComposition *mvc = [self.videoComposition mutableCopy];
        mvc.animationTool = animationTool;
    }
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:self.composition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    session.videoComposition = self.videoComposition;
    session.audioMix = self.audioMix;
    return session;
}

@end

//
//  AVPlayerItem+GISync.m
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "AVPlayerItem+GISync.h"
#import <objc/runtime.h>

static id GISynchronizedLayerKey;

@implementation AVPlayerItem (GISync)

- (BOOL)hasValidDuration {
    return self.status==AVPlayerItemStatusReadyToPlay && !CMTIME_IS_INVALID(self.duration);
}

- (void)muteAudioTracks:(BOOL)value {
    for (AVPlayerItemTrack *track in self.tracks) {
        if ([track.assetTrack.mediaType isEqualToString:AVMediaTypeAudio]) {
            track.enabled = !value;
        }
    }
}

- (AVSynchronizedLayer *)syncLayer {
    return objc_getAssociatedObject(self, &GISynchronizedLayerKey);
}

- (void)setSyncLayer:(AVSynchronizedLayer *)syncLayer {
    objc_setAssociatedObject(self,
                             &GISynchronizedLayerKey,
                             syncLayer,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

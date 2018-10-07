//
//  AVPlayerItem+GISync.h
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVPlayerItem (GISync)

@property (nonatomic, strong) AVSynchronizedLayer *syncLayer;

- (BOOL)hasValidDuration;
- (void)muteAudioTracks:(BOOL)value;

@end

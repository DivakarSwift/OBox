//
//  GIPlaybackView.m
//  VRMicro
//
//  Created by kegebai on 2018/5/10.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIPlaybackView.h"

@implementation GIPlaybackView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)self.layer player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [(AVPlayerLayer *)self.layer setPlayer:player];
}

@end

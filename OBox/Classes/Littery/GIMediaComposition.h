//
//  GIMediaComposition.h
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GIComposition.h"

@interface GIMediaComposition : NSObject <GIComposition>

@property (nonatomic, readonly, copy) AVComposition *composition;
@property (nonatomic, readonly, copy) AVVideoComposition *videoComposition;
@property (nonatomic, readonly, copy) AVAudioMix *audioMix;
@property (nonatomic, readonly, strong) CALayer *titleLayer;

- (id)initWithComposition:(AVComposition *)composition
         videoComposition:(AVVideoComposition *)videoComposition
                 audioMix:(AVAudioMix *)audioMix
               titleLayer:(CALayer *)titleLayer;

@end

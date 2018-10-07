//
//  GIComposition.h
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GIComposition <NSObject>

- (AVPlayerItem *)makePlayable;

- (AVAssetExportSession *)makeExportable;

@end

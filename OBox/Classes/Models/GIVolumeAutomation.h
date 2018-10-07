//
//  GIVolumeAutomation.h
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

@interface GIVolumeAutomation : NSObject

@property (nonatomic) CMTimeRange timeRange;
@property (nonatomic) CGFloat startVolume;
@property (nonatomic) CGFloat endVolume;

+ (id)volumeAutomationWithTimeRange:(CMTimeRange)timeRange
                        startVolume:(CGFloat)startVolume
                          endVolume:(CGFloat)endVolume;

@end

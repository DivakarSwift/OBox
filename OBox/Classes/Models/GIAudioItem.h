//
//  GIAudioItem.h
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIMediaItem.h"

@interface GIAudioItem : GIMediaItem

@property (nonatomic, copy) NSArray *volumeAutomation;

+ (id)audioItemWithURL:(NSURL *)url;

@end

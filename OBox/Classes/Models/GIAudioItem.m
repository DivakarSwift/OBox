//
//  GIAudioItem.m
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIAudioItem.h"

@implementation GIAudioItem

+ (id)audioItemWithURL:(NSURL *)url {
    return [[self alloc] initWithURL:url];
}

- (NSString *)mediaType {
    return AVMediaTypeAudio;
}

@end

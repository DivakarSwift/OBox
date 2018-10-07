//
//  VRPhotoFilter.m
//  VRMicro
//
//  Created by kegebai on 2018/5/3.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "VRPhotoFilter.h"
#import "NSString+VRRegex.h"

@implementation VRPhotoFilter

+ (NSArray *)filterNames {
    
    return @[
        @"CIPhotoEffectChrome",
        @"CIPhotoEffectFade",
        @"CIPhotoEffectInstant",
        @"CIPhotoEffectMono",
        @"CIPhotoEffectNoir",
        @"CIPhotoEffectProcess",
        @"CIPhotoEffectTonal",
        @"CIPhotoEffectTransfer"
    ];
}

+ (NSArray *)filterDisplayNames {
    
    NSMutableArray *displayNames = [NSMutableArray array];
    
    for (NSString *filterName in [self filterNames]) {
        [displayNames addObject:[filterName stringByMatchingRegex:@"CIPhotoEffect(.*)" capture:1]];
    }
    
    return displayNames;
}

+ (CIFilter *)defaultFilter {
    return [CIFilter filterWithName:[[self filterNames] firstObject]];
}

+ (CIFilter *)filterForDisplayName:(NSString *)displayName {
    for (NSString *name in [self filterNames]) {
        if ([name containsString:displayName]) {
            return [CIFilter filterWithName:name];
        }
    }
    return nil;
}

@end

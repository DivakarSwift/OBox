//
//  VRPhotoFilter.h
//  VRMicro
//
//  Created by kegebai on 2018/5/3.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRPhotoFilter : NSObject

+ (NSArray *)filterNames;
+ (NSArray *)filterDisplayNames;
+ (CIFilter *)filterForDisplayName:(NSString *)displayName;
+ (CIFilter *)defaultFilter;

@end

//
//  NSString+VRRegex.h
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (VRRegex)

- (NSString *)stringByMatchingRegex:(NSString *)regex capture:(NSUInteger)capture;

@end

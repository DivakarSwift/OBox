//
//  VRImageTarget.h
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@protocol VRImageTarget <NSObject>

- (void)setImage:(CIImage *)image;

@end

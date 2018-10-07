//
//  GIBasicComposition.h
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GIComposition.h"

@interface GIBasicComposition : NSObject <GIComposition>

@property (nonatomic, readonly, copy) AVComposition *composition;

+ (id)composition:(AVComposition *)composition;
- (id)initWithComposition:(AVComposition *)composition;

@end

//
//  GITitleItem.h
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GITimelineItem.h"

@interface GITitleItem : GITimelineItem

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic) BOOL animateImage;
@property (nonatomic) BOOL useLargeFont;

+ (id)titleItemWithText:(NSString *)text image:(UIImage *)image;
- (id)initWithText:(NSString *)text image:(UIImage *)image;

- (CALayer *)buildLayer;

@end

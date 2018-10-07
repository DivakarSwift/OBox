//
//  GIThumbnailView.m
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIThumbnailView.h"

#define ThumbnailSize CGSizeMake(48.0f, 24.0f)

@interface GIThumbnailView ()
@property (nonatomic, copy) NSArray<UIImage *> *thumbnails;
@end

@implementation GIThumbnailView

- (void)bindData:(id)data {
    if (self.thumbnails != data) {
        self.thumbnails = [data copy];
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGFloat xPos = 0.0f;
    for (UIImage *image in self.thumbnails) {
        [image drawInRect:CGRectMake(xPos, 0.0f, ThumbnailSize.width, ThumbnailSize.height)];
        xPos += ThumbnailSize.width;
    }
}

@end

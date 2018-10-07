//
//  VRVideoPreviewView.m
//  VRMicro
//
//  Created by kegebai on 2018/5/3.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "VRVideoPreviewView.h"
#import "VRNotifications.h"
#import "VRFouctions.h"

@interface VRVideoPreviewView ()
@property (nonatomic) CGRect drawableBounds;
@end

@implementation VRVideoPreviewView

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
    self = [super initWithFrame:frame context:context];
    if (self) {
        self.enableSetNeedsDisplay = NO;
        self.backgroundColor = [UIColor blackColor];
        self.opaque = YES;
        
        // because the native video image from the back camera is in
        // UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right),
        // we need to apply a clockwise 90 degree transform so that we can draw
        // the video preview as if we were in a landscape-oriented view;
        // if you're using the front camera and you want to have a mirrored
        // preview (so that the user is seeing themselves in the mirror), you
        // need to apply an additional horizontal flip (by concatenating
        // CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.frame = frame;
        
        [self bindDrawable];
        _drawableBounds = self.bounds;
        _drawableBounds.size.width = self.drawableWidth;
        _drawableBounds.size.height = self.drawableHeight;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(filterChanged:)
                                                     name:VRFilterSelectionChangedNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - VRImageTarget

- (void)setImage:(CIImage *)image {
    [self bindDrawable];
    [self.filter setValue:image forKey:kCIInputImageKey];
    
    CIImage *filterImage = self.filter.outputImage;
    if (filterImage) {
        CGRect cropRect = VRCenterCropImageRect(image.extent, self.drawableBounds);
        [self.ciContext drawImage:filterImage inRect:self.drawableBounds fromRect:cropRect];
    }
    
    [self display];
    [self.filter setValue:nil forKey:kCIInputImageKey];
}

#pragma mark - action

- (void)filterChanged:(NSNotification *)notification {
    self.filter = notification.object;
}

@end

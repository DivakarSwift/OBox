//
//  VRFouctions.m
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "VRFouctions.h"

CGRect VRCenterCropImageRect(CGRect sourceRect, CGRect previewRect) {
    
    CGFloat sourceAspectRatio = sourceRect.size.width / sourceRect.size.height;
    CGFloat previewAspectRatio = previewRect.size.width  / previewRect.size.height;
    
    // we want to maintain the aspect radio of the screen size, so we clip the video image
    CGRect drawRect = sourceRect;
    
    if (sourceAspectRatio > previewAspectRatio) {
        // use full height of the video image, and center crop the width
        CGFloat scaledHeight = drawRect.size.height * previewAspectRatio;
        drawRect.origin.x += (drawRect.size.width - scaledHeight) / 2.0;
        drawRect.size.width = scaledHeight;
    } else {
        // use full width of the video image, and center crop the height
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspectRatio) / 2.0;
        drawRect.size.height = drawRect.size.width / previewAspectRatio;
    }
    
    return drawRect;
}


CGAffineTransform VRTransformDeviceOrientation(UIDeviceOrientation orientation) {
    CGAffineTransform result;
    
    switch (orientation) {
            
        case UIDeviceOrientationLandscapeRight:
            result = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            result = CGAffineTransformMakeRotation((M_PI_2 * 3));
            break;
            
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            result = CGAffineTransformMakeRotation(M_PI_2);
            break;
            
        default: // Default orientation of landscape left
            result = CGAffineTransformIdentity;
            break;
    }
    return result;
}

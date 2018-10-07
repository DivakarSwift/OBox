//
//  VRCaptureButton.h
//  VRMicro
//
//  Created by kegebai on 2018/5/3.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VRCaptureMode) {
    VRCaptureModeVideo = 0, // default
    VRCaptureModePhoto = 1,
};

@interface VRCaptureButton : UIButton

@property (nonatomic, assign) VRCaptureMode captureMode;

+ (id)captureButtonWithMode:(VRCaptureMode)captureMode;
+ (id)captureButton;

@end

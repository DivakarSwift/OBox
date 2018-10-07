//
//  VRError.h
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

FOUNDATION_EXPORT NSString *const VRCameraErrorDomain;

typedef NS_ENUM(NSInteger, VRCameraErrorCode) {
    VRCameraErrorFailedToAddInput = 1000,
    VRCameraErrorFailedToAddOutput,
    VRCameraErrorHighFrameRateCaptureNotSupported
};

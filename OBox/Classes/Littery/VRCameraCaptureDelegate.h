//
//  VRCameraCaptureDelegate.h
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VRCameraCaptureDelegate <NSObject>

- (void)deviceConfigurationFailedWithError:(NSError *)error;
- (void)mediaCaptureFailedWithError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;

@end

//
//  VRAssetsLibrary.h
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

typedef void(^VRAssetsLibraryWriteCompletionHandler)(BOOL success, NSError *error);

#import <Foundation/Foundation.h>

@interface VRAssetsLibrary : NSObject

- (void)writeImage:(UIImage *)image
 completionHandler:(VRAssetsLibraryWriteCompletionHandler)completionHandler;

- (void)writeVideoAtURL:(NSURL *)videoURL
      completionHandler:(VRAssetsLibraryWriteCompletionHandler)completionHandler;

@end

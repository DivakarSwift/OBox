//
//  VRVideoWriter.h
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol VRVideoWriterDelegate <NSObject>
- (void)didWriteVideoAtURL:(NSURL *)outputURL;
@end

@interface VRVideoWriter : NSObject

@property (nonatomic, weak) id <VRVideoWriterDelegate> delegate;
@property (nonatomic) BOOL isWriting;

- (id)initWithVideoSettings:(NSDictionary *)videoSettings
              audioSettings:(NSDictionary *)audioSettings
              dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)startWriting;
- (void)stopWriting;

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

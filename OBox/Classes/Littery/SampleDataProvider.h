//
//  SampleDataProvider.h
//  Waveform
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^SampleDataCompletionBlock)(NSData *);

@interface SampleDataProvider : NSObject

+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset
                       completion:(SampleDataCompletionBlock)completion;
@end

//
//  GIMediaItem.h
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GITimelineItem.h"

typedef void(^GIPreparationCompletionBlock)(BOOL complete);

@interface GIMediaItem : GITimelineItem

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, readonly) BOOL prepared;
@property (nonatomic, readonly, copy) NSString *mediaType;
@property (nonatomic, readonly, copy) NSString *title;

- (id)initWithURL:(NSURL *)url;
- (BOOL)isTrimmed;
- (void)prepare:(GIPreparationCompletionBlock)completion;
- (void)performPostPrepareActions:(GIPreparationCompletionBlock)completion;

- (AVPlayerItem *)makePlayable;

@end

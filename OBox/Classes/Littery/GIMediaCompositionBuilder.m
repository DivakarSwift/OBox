//
//  GIMediaCompositionBuilder.m
//  VRMicro
//
//  Created by kegebai on 2018/5/7.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIMediaCompositionBuilder.h"
#import "GIMediaComposition.h"
#import "GIFunctions.h"
#import "GIAudioItem.h"
#import "GIVolumeAutomation.h"
#import "GIVideoItem.h"
#import "GITransitionInstructions.h"
#import "GITitleItem.h"

@interface GIMediaCompositionBuilder ()
@property (nonatomic, strong) GITimeline *timeline;
@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, weak) AVMutableCompositionTrack *musicTrack;
@end

@implementation GIMediaCompositionBuilder

- (id)initWithTimeline:(GITimeline *)timeline {
    self = [super init];
    if (self) {
        _timeline = timeline;
    }
    return self;
}

- (id<GIComposition>)buildComposition {
    self.composition = [AVMutableComposition composition];
    [self buildCompositionTracks];
    AVVideoComposition *videoComposition = [self buildVideoComposition];
    AVAudioMix *audioMix = [self buildAudioMix];
    CALayer *titleLayer = [self buildTitleLayer];
    
    // Create and return the GIOverlayComposition
    return [[GIMediaComposition alloc] initWithComposition:self.composition
                                            videoComposition:videoComposition
                                                    audioMix:audioMix
                                                  titleLayer:titleLayer];
}

#pragma mark - private

- (void)buildCompositionTracks {
    CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
    AVMutableCompositionTrack *trackA = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                      preferredTrackID:trackID];
    AVMutableCompositionTrack *trackB = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                      preferredTrackID:trackID];
    NSArray *videoTracks = @[trackA, trackB];
    
    CMTime cursorTime = kCMTimeZero;
    CMTime transitionDuration = kCMTimeZero;
    
    if (!GI_IS_EMPTY(self.timeline.transitions)) {
        // 1 second transition duration
        transitionDuration = GIDefaultTransitionDuration;
    }
    
    NSArray *videos = self.timeline.videos;
    
    for (NSUInteger i = 0; i < videos.count; i++) {
        NSUInteger trackIndex = i % 2;
        GIVideoItem *item = videos[i];
        AVMutableCompositionTrack *currentTrack = videoTracks[trackIndex];
        AVAssetTrack *assetTrack = [item.asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        [currentTrack insertTimeRange:item.timeRange
                              ofTrack:assetTrack
                               atTime:cursorTime
                                error:nil];
        // Overlap clips by transition duration
        cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
        cursorTime = CMTimeSubtract(cursorTime, transitionDuration);
    }
    // Add voice overs
    [self addCompositionTrackOfMediaType:AVMediaTypeAudio mediaItem:self.timeline.voiceOvers];
    // Add music track
    self.musicTrack =  [self addCompositionTrackOfMediaType:AVMediaTypeAudio
                                                  mediaItem:self.timeline.musicItems];
}

- (AVVideoComposition *)buildVideoComposition {
    AVVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.composition];
    NSArray *transitionInstructions = [self transitionInstructionsInVideoComposition:videoComposition];
    for (GITransitionInstructions *instructions in transitionInstructions) {
        CMTimeRange timeRange = instructions.compositionInstructions.timeRange;
        AVMutableVideoCompositionLayerInstruction *fromLayer = instructions.fromLayerInstruction;
        AVMutableVideoCompositionLayerInstruction *toLayer = instructions.toLayerInstruction;
        GIVideoTransitionType type = instructions.transition.type;
        
        // Apply video transition effects
        if (type == GIVideoTransitionTypeDissolve) {
            [fromLayer setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:timeRange];
        }
        
        if (type == GIVideoTransitionTypePush) {
            // Define starting and ending transforms
            CGAffineTransform transform = CGAffineTransformIdentity;
            CGFloat width = videoComposition.renderSize.width;
            CGAffineTransform fromDestTransform = CGAffineTransformMakeTranslation(-width, 0.0);
            CGAffineTransform toStartTransform = CGAffineTransformMakeTranslation(width, 0.0);
            [fromLayer setTransformRampFromStartTransform:transform
                                           toEndTransform:fromDestTransform
                                                timeRange:timeRange];
            [toLayer setTransformRampFromStartTransform:toStartTransform
                                         toEndTransform:transform
                                              timeRange:timeRange];
        }
        
        if (type == GIVideoTransitionTypeWipe) {
            CGFloat width = videoComposition.renderSize.width;
            CGFloat height = videoComposition.renderSize.height;
            [fromLayer setCropRectangleRampFromStartCropRectangle:CGRectMake(0, 0, width, height)
                                               toEndCropRectangle:CGRectMake(0, height, width, 0)
                                                        timeRange:timeRange];
        }
        //
        instructions.compositionInstructions.layerInstructions = @[fromLayer, toLayer];
    }
    return videoComposition;
}

// Extract the composition and layer instructions out of the
// prebuilt AVVideoComposition. Make the association between the instructions
// and the GIVideoTransition the user configured in the timeline.
- (NSArray *)transitionInstructionsInVideoComposition:(AVVideoComposition *)videoComposition {
    NSMutableArray *transitionInstructions = [NSMutableArray array];
    int layerInstructionIndex = 1;
    NSArray *compositionInstructions = videoComposition.instructions;
    
    for (AVMutableVideoCompositionInstruction *instruction in compositionInstructions) {
        if (instruction.layerInstructions.count == 2) {
            GITransitionInstructions *instructions = [[GITransitionInstructions alloc] init];
            instructions.compositionInstructions = instruction;
            instructions.fromLayerInstruction = [instruction.layerInstructions[1 - layerInstructionIndex] mutableCopy];
            instructions.toLayerInstruction = [instruction.layerInstructions[layerInstructionIndex] mutableCopy];
            [transitionInstructions addObject:instructions];
            layerInstructionIndex = layerInstructionIndex == 1 ? 0 : 1;
        }
    }
    NSArray *transitions = self.timeline.transitions;
    // Transitions are disabled
    if (GI_IS_EMPTY(transitions)) {
        return transitionInstructions;
    }
    NSAssert(transitionInstructions.count == transitions.count, @"Instruction count and transition count do not match.");
    
    for (NSUInteger i = 0; i < transitionInstructions.count; i++) {
        GITransitionInstructions *instructions = transitionInstructions[i];
        instructions.transition = self.timeline.transitions[i];
    }
    
    return transitionInstructions;
}

- (AVMutableCompositionTrack *)addCompositionTrackOfMediaType:(NSString *)mediaType
                                                    mediaItem:(NSArray *)mediaItems {
    AVMutableCompositionTrack *compositionTrack = nil;
    if (!GI_IS_EMPTY(mediaItems)) {
        CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
        compositionTrack = [self.composition addMutableTrackWithMediaType:mediaType
                                                         preferredTrackID:trackID];
        // Set insert cursor to 0
        CMTime cursorTime = kCMTimeZero;
        for (GIMediaItem *item in mediaItems) {
            if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline, !=, kCMTimeInvalid)) {
                cursorTime = item.startTimeInTimeline;
            }
            AVAssetTrack *assetTrack = [item.asset tracksWithMediaType:mediaType].firstObject;
            [compositionTrack insertTimeRange:item.timeRange
                                      ofTrack:assetTrack
                                       atTime:cursorTime
                                        error:nil];
            // Move cursor to next item time
            cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
        }
    }
    return compositionTrack;
}

- (AVAudioMix *)buildAudioMix {
    NSArray *items = self.timeline.musicItems;
    // Only one allowed
    if (items.count == 1) {
        GIAudioItem *item = self.timeline.musicItems.firstObject;
        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
        AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:self.musicTrack];
        
        for (GIVolumeAutomation *automation in item.volumeAutomation) {
            [parameters setVolumeRampFromStartVolume:automation.startVolume
                                         toEndVolume:automation.endVolume
                                           timeRange:automation.timeRange];
        }
        audioMix.inputParameters = @[parameters];
        return audioMix;
    }
    return nil;
}

- (CALayer *)buildTitleLayer {
    if (!GI_IS_EMPTY(self.timeline.titles)) {
        CALayer *titleLayer = [CALayer layer];
        titleLayer.bounds = GI720pVideoBounds;
        titleLayer.position = CGPointMake(CGRectGetMidX(GI720pVideoBounds), CGRectGetMidY(GI720pVideoBounds));
        
        for (GITitleItem *compositionLayer in self.timeline.titles) {
            [titleLayer addSublayer:[compositionLayer buildLayer]];
        }
        return titleLayer;
    }
    return nil;
}

@end

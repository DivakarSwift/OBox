//
//  GIPlayerViewController.m
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIPlayerViewController.h"
#import "AVPlayerItem+GISync.h"

#define STATUS_KEYPATH @"status"

// Define this constant for the key-value observation context.
static const NSString *PlayerItemStatusContext;

@interface GIPlayerViewController ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVAudioMix *mutingAudioMix;
@property (nonatomic, strong) AVAudioMix *lastAudioMix;

@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) UIView *titleView;

@property (nonatomic) CGFloat lastPlaybackRate;
@property (nonatomic) BOOL scrubbing;
@property (nonatomic) BOOL autoplayContent;
@property (nonatomic) BOOL readyForDisplay;

@property (nonatomic, strong) UIPopoverPresentationController *settingsPopover;
@end

@implementation GIPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.autoplayContent = YES;
    [self.view bringSubviewToFront:self.loadingView];
    
    [self.scrubberSlider setThumbImage:[UIImage imageNamed:@"knob"] forState:UIControlStateNormal];
    [self.scrubberSlider setThumbImage:[UIImage imageNamed:@"knob_highlighted"] forState:UIControlStateHighlighted];
    [self.scrubberSlider addTarget:self
                            action:@selector(scrubbingDidStart)
                  forControlEvents:UIControlEventTouchDown];
    [self.scrubberSlider addTarget:self
                            action:@selector(scrubbedToTime:)
                  forControlEvents:UIControlEventValueChanged];
    [self.scrubberSlider addTarget:self
                            action:@selector(scrubbingDidEnd)
                  forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadInitialPlayerItem:(AVPlayerItem *)playerItem {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        self.autoplayContent = NO;
        self.playerItem = playerItem;
        [self prepareToPlay];
    });
}

- (void)stopPlayback {
    self.playButton.selected = NO;
    self.player.rate = 0.f;
    [self.player seekToTime:kCMTimeZero];
}

// Only called when previewing
- (void)playWithPlayerItem:(AVPlayerItem *)playerItem {
    [self.titleView removeFromSuperview];
    self.autoplayContent = YES;
    self.playButton.selected = YES;
    self.playerItem = playerItem;
    self.player.rate = 0.0f;
    if (playerItem) {
        [self prepareToPlay];
    } else {
        NSLog(@"Player item is nil. Nothing to play.");
    }
}

- (void)prepareToPlay {
    if (!self.player) {
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playbackView.player = self.player;
    } else {
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    }
    
    [self.playerItem addObserver:self forKeyPath:STATUS_KEYPATH options:0 context:&PlayerItemStatusContext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    if (self.playerItem.syncLayer) {
        [self addSynchronizedLayer:self.playerItem.syncLayer];
        self.playerItem.syncLayer = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (context == &PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addPlayerTimeObserver];
            self.scrubberSlider.maximumValue = CMTimeGetSeconds(self.playerItem.duration);
            self.scrubberSlider.minimumValue = 0.0f;
            self.scrubberSlider.value = 0.0f;
            
            if (self.autoplayContent) {
                [self.player play];
            } else {
                [self stopPlayback];
            }
            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];
            //
            [self prepareAudioMixes];
            
            if (!self.readyForDisplay) {
                [UIView animateWithDuration:0.35 animations:^{
                    self.loadingView.alpha = 0.0f;
                } completion:^(BOOL complete) {
                    [self.view sendSubviewToBack:self.loadingView];
                }];
            }
        });
    }
}

- (void)prepareAudioMixes {
    self.mutingAudioMix = [self buildAudioMixForPlayerItem:self.playerItem level:0.05];
    if (!self.playerItem.audioMix) {
        self.playerItem.audioMix = [self buildAudioMixForPlayerItem:self.playerItem level:1.0];
    }
}

#pragma mark - Attach AVSynchronizedLayer to layer tree

- (void)addSynchronizedLayer:(AVSynchronizedLayer *)syncLayer {
    // Remove old if it still exists
    [self.titleView removeFromSuperview];
    
    syncLayer.bounds = GI720pVideoBounds;
    self.titleView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.titleView.layer addSublayer:syncLayer];
    
    CGFloat scale = fminf(self.view.bW / GI720pVideoSize.width, self.view.bH / GI720pVideoSize.height);
    CGRect videoRect = AVMakeRectWithAspectRatioInsideRect(GI720pVideoSize, self.view.bounds);
    self.titleView.center = CGPointMake(CGRectGetMidX(videoRect), CGRectGetMidY(videoRect));
    self.titleView.transform = CGAffineTransformMakeScale(scale, scale);
    
    [self.view addSubview:self.titleView];
}

- (void)addPlayerTimeObserver {
    // Create 0.5 second refresh interval - REFRESH_INTERVAL == 0.5
    CMTime interval = CMTimeMakeWithSeconds(0.25, NSEC_PER_SEC);
    __weak GIPlayerViewController *wself = self;
    // Add observer and store pointer for future use
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:^(CMTime time) {
                                                                 NSTimeInterval curTime = CMTimeGetSeconds(time);
                                                                 wself.scrubberSlider.value = curTime;
                                                             }];
}

- (AVAudioMix *)buildAudioMixForPlayerItem:(AVPlayerItem *)playerItem level:(CGFloat)level {
    NSMutableArray *params = [NSMutableArray array];
    for (AVPlayerItemTrack *track in playerItem.tracks) {
        if ([track.assetTrack.mediaType isEqualToString:AVMediaTypeAudio]) {
            AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track.assetTrack];
            [parameters setVolume:level atTime:kCMTimeZero];
            [params addObject:parameters];
        }
    }
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = params;
    return audioMix;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self stopPlayback];
    [[NSNotificationCenter defaultCenter] postNotificationName:GIPlaybackEndedNotification
                                                        object:nil];
}

#pragma mark - action

- (void)scrubbingDidStart {
    self.lastPlaybackRate = self.player.rate;
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver];
}

- (void)scrubbedToTime:(UISlider *)slider {
    [self.playerItem cancelPendingSeeks];
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, NSEC_PER_SEC)
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero];
}

- (void)scrubbingDidEnd {
    [self addPlayerTimeObserver];
    if (self.lastPlaybackRate > 0.0f) {
        [self.player play];
    }
}

#pragma mark - setter
// display or hide export view
- (void)setExporting:(BOOL)exporting {
    if (exporting) {
        self.exportProgressView.progress = 0.0f;
        self.exportProgressView.alpha = 0.0f;
        [self.view bringSubviewToFront:self.exportProgressView];
        [UIView animateWithDuration:0.4f animations:^{
            self.exportProgressView.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.4 animations:^{
            self.exportProgressView.alpha = 0.0f;
        } completion:^(BOOL complete) {
            [self.view bringSubviewToFront:self.exportProgressView];
        }];
    }
}

@end

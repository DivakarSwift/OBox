//
//  GIPlayerViewController.h
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIPlaybackMediator.h"
#import "GIPlaybackView.h"
#import "GIProgressView.h"

@interface GIPlayerViewController : UIViewController

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, weak) id <GIPlaybackMediator> playbackMediator;
@property (nonatomic, strong) UIView *loadingView;

@property (nonatomic, strong) GIPlaybackView *playbackView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UISlider *scrubberSlider;
@property (nonatomic, strong) GIProgressView *exportProgressView;

@property (nonatomic) BOOL exporting;

- (void)loadInitialPlayerItem:(AVPlayerItem *)playerItem;

- (void)playWithPlayerItem:(AVPlayerItem *)playerItem;
- (void)stopPlayback;

@end

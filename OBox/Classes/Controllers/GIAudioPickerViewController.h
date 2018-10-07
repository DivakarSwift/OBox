//
//  GIAudioPickerViewController.h
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIPlaybackMediator.h"

@class GIAudioItem;

@interface GIAudioPickerViewController : UITableViewController

@property (nonatomic, weak) id <GIPlaybackMediator> playbackMediator;

@property (nonatomic, readonly, strong) GIAudioItem *defaultVioceOver;
@property (nonatomic, readonly, strong) GIAudioItem *defaultMusicTrack;

@end

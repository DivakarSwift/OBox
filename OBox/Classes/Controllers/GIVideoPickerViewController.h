//
//  GIVideoPickerViewController.h
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIPlaybackMediator.h"

@class GIVideoItem;

@interface GIVideoPickerViewController : UITableViewController

@property (nonatomic, weak) id <GIPlaybackMediator> playbackMediator;

@property (nonatomic, readonly, copy) NSArray<GIVideoItem *> *defaultVideoItems;

@end

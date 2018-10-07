//
//  GIAudioItemCollectionViewCell.h
//  AudioBox
//
//  Created by kegebai on 2018/9/11.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITimelineItemView.h"
#import "GIVolumeAutomationView.h"

@interface GIAudioItemCollectionViewCell : UICollectionViewCell

@property (nonatomic) GITimelineItemView *itemView;
@property (nonatomic) GIVolumeAutomationView *volumeAutomationView;

@end

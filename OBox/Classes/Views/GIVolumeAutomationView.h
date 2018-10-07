//
//  GIVolumeAutomationView.h
//  AudioBox
//
//  Created by kegebai on 2018/9/11.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIVolumeAutomationView : UIView

@property (nonatomic, copy) NSArray *audioRamps;
@property (nonatomic) CMTime duration;

@end

//
//  GIVideoPickerOverlayView.m
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIVideoPickerOverlayView.h"

#define PLAY_INSETS UIEdgeInsetsMake(0, 2, 0, 0)
#define BTN_W 24.f
#define BTN_H 24.f

@implementation GIVideoPickerOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _addButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_addButton  setBackgroundImage:[UIImage imageNamed:@"dark_button_background"] forState:UIControlStateNormal];
        [_playButton setBackgroundImage:[UIImage imageNamed:@"dark_button_background"] forState:UIControlStateNormal];
        
        [_addButton  setImage:[UIImage imageNamed:@"tp_add_media_icon"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"tp_play_icon"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"tp_stop_icon"] forState:UIControlStateSelected];
        [_playButton setImageEdgeInsets:PLAY_INSETS];
        
        [self addSubview:_addButton];
        [self addSubview:_playButton];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat yPos = (self.bounds.size.height - BTN_H) / 2;
    self.addButton.frame  = CGRectMake(CGRectGetMidX(self.bounds) - 10 - BTN_W, yPos, BTN_W, BTN_H);
    self.playButton.frame = CGRectMake(CGRectGetMidX(self.bounds) + 10, yPos, BTN_W, BTN_H);
}

@end

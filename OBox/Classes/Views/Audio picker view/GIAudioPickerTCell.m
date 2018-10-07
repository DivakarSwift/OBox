//
//  GIAudioPickerTCell.m
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIAudioPickerTCell.h"
#import "GIAudioItem.h"

@interface GIAudioPickerTCell ()
@property (nonatomic, strong) GIAudioItem *item;
@property (nonatomic, readwrite, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *titleLab;
@end

@implementation GIAudioPickerTCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, self.cY, 250, 21)];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.font = [UIFont systemFontOfSize:14];
        _titleLab.textColor = [UIColor whiteColor];
        [self addSubview:_titleLab];
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(self.width-30-20, self.cY, 30, 30);
        [_playButton setBackgroundImage:[UIImage imageNamed:@"pv_play_button"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"pv_play_icon"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"pv_stop_icon"] forState:UIControlStateSelected];
        [self addSubview:_playButton];
    }
    return self;
}

- (void)bindData:(id)data {
    if (self.item != data) {
        self.item = data;
    }
    self.titleLab.text = self.item.title;
    self.playButton.selected = NO;
}

@end

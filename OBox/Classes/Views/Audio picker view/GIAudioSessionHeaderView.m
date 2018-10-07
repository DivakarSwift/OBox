//
//  GIAudioSessionHeaderView.m
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIAudioSessionHeaderView.h"

@interface GIAudioSessionHeaderView ()
@property (nonatomic, strong) UILabel *titleLab;
@end

@implementation GIAudioSessionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.298 alpha:1.000];
        
        CGRect lFrame = frame;
        lFrame.origin.x = 10.f;
        _titleLab = [[UILabel alloc] initWithFrame:lFrame];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textColor = [UIColor whiteColor];
        [self addSubview:_titleLab];
    }
    return self;
}

- (void)bindData:(id)data {
    self.titleLab.text = [data copy];
}

@end

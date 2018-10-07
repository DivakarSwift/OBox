//
//  GIVideoPickerTCell.m
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIVideoPickerTCell.h"
#import "GIVideoPickerOverlayView.h"
#import "GIThumbnailView.h"
#import "GIVideoItem.h"

@interface GIVideoPickerTCell ()
@property (nonatomic, strong) GIVideoItem *videoItem;
@property (nonatomic, strong) GIVideoPickerOverlayView *overlayView;
@end

@implementation GIVideoPickerTCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[GIThumbnailView alloc] initWithFrame:self.bounds];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _overlayView = [[GIVideoPickerOverlayView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_overlayView];
    }
    return self;
}

- (void)bindData:(id)data {
    if (self.videoItem != data) {
        self.videoItem = data;
    }
    [(GIThumbnailView *)self.backgroundView bindData:self.videoItem.thumbnails];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.overlayView.hidden = !selected;
    if (!selected) {
        self.overlayView.playButton.selected = NO;
    }
}

#pragma mark - getter

- (UIButton *)playButton {
    return self.overlayView.playButton;
}

- (UIButton *)addButton {
    return self.overlayView.addButton;
}

@end

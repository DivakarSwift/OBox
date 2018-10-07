//
//  GIVideoItemCollectionViewCell.h
//  AudioBox
//
//  Created by kegebai on 2018/9/11.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITimelineItemView.h"

@interface GIVideoItemCollectionViewCell : UICollectionViewCell

@property (nonatomic) GITimelineItemView *itemView;
@property (nonatomic) CMTimeRange maxTimeRange;

- (BOOL)isPointInDragHandle:(CGPoint)point;

@end

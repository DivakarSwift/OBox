//
//  GITimelineLayout.h
//  AudioBox
//
//  Created by kegebai on 2018/8/20.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionViewDelegateTimelineLayout.h"

@interface GITimelineLayoutAttributes: UICollectionViewLayoutAttributes

@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) CGFloat scaleUnit;

@end

@interface GITimelineLayout : UICollectionViewLayout

@property (nonatomic) CGFloat trackHeight;
@property (nonatomic) CGFloat clipSpacing;
@property (nonatomic) UIEdgeInsets trackInsets;
@property (nonatomic) BOOL reorderingAllowed;

@end

//
//  GITimelineDataSource.h
//  AudioBox
//
//  Created by kegebai on 2018/9/11.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICollectionViewDelegateTimelineLayout.h"

@interface GITimelineDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegateTimelineLayout>

@property (nonatomic, strong) NSMutableArray *timelineItems;

+ (id)dataSourceWithController:(UIViewController *)controller;

- (void)resetTimeline;
- (void)clearTimeline;

@end

//
//  GITransitionViewController.h
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIVideoTransition.h"

@protocol GITransitionViewControllerDelegate <NSObject>

- (void)transitionSelected;

@end

@interface GITransitionViewController : UITableViewController

@property (nonatomic, weak) id<GITransitionViewControllerDelegate> delegate;

+ (id)controllerWithTransition:(GIVideoTransition *)transition;

@end

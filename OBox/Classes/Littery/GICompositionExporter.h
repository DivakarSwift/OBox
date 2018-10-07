//
//  GICompositionExporter.h
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GIComposition.h"

@interface GICompositionExporter : NSObject

@property (nonatomic) BOOL exporting;
@property (nonatomic) CGFloat progress;

- (instancetype)initWithComposition:(id <GIComposition>)composition;

- (void)beginExport;

@end

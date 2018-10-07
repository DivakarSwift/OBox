//
//  GITransitionInstructions.h
//  VRMicro
//
//  Created by kegebai on 2018/5/6.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIVideoTransition.h"

@interface GITransitionInstructions : NSObject

@property (nonatomic, strong) GIVideoTransition *transition;
@property (nonatomic, strong) AVMutableVideoCompositionInstruction *compositionInstructions;
@property (nonatomic, strong) AVMutableVideoCompositionLayerInstruction *fromLayerInstruction;
@property (nonatomic, strong) AVMutableVideoCompositionLayerInstruction *toLayerInstruction;

@end

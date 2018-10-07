//
//  SampleDataFilter.h
//  Waveform
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SampleDataFilter : NSObject

- (instancetype)initWithData:(NSData *)sampleData;
- (NSArray *)samplesForFilterSize:(CGSize)size;

@end

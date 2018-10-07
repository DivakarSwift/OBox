//
//  SampleDataFilter.m
//  Waveform
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "SampleDataFilter.h"

@interface SampleDataFilter ()
@property (nonatomic, copy) NSData *sampleData;
@end

@implementation SampleDataFilter

- (instancetype)initWithData:(NSData *)sampleData {
    self = [super init];
    if (self) {
        _sampleData = [sampleData copy];
    }
    return self;
}

- (NSArray *)samplesForFilterSize:(CGSize)size {
    NSMutableArray *samples = [NSMutableArray array];
    NSUInteger sampleCount = self.sampleData.length / sizeof(SInt16);
    NSUInteger binSize = sampleCount / size.width;
    
    SInt16 *bytes = (SInt16 *)self.sampleData.bytes;
    SInt16 maxSample = 0;
    for (NSUInteger i = 0; i < sampleCount; i += binSize) {
        
        SInt16 sampleBin[binSize];
        for (NSUInteger j = 0; j < binSize; j++) {
            sampleBin[j] = CFSwapInt16LittleToHost(bytes[i+j]);
        }
        
        SInt16 value = [self maxValueInArray:sampleBin ofSize:binSize];
        [samples addObject:@(value)];
        
        if (value > maxSample) {
            maxSample = value;
        }
    }
    
    CGFloat scaleFactor = (size.height / 2) / maxSample;
    for (NSUInteger i = 0; i < samples.count; i++) {
        samples[i] = @([samples[i] integerValue] * scaleFactor);
    }
    
    return samples;
}

- (SInt16)maxValueInArray:(SInt16 [])values ofSize:(NSUInteger)size {
    SInt16 maxValue = 0;
    for (int i = 0; i < size; i++) {
        if (abs(values[i]) > maxValue) {
            maxValue = abs(values[i]);
        }
    }
    return maxValue;
}

@end

//
//  GIWaveformView.m
//  Waveform
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIWaveformView.h"
#import "SampleDataProvider.h"
#import "SampleDataFilter.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat WidthScale  = 0.95;
static const CGFloat HeightScale = 0.85;

@interface GIWaveformView ()
@property (nonatomic, strong) SampleDataFilter *filter;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation GIWaveformView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.waveColor = [UIColor whiteColor];
        self.layer.cornerRadius = 2.0f;
        self.layer.masksToBounds = YES;
        
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGSize size = _loadingView.frame.size;
        CGFloat x = (self.bounds.size.width - size.width) / 2;
        CGFloat y = (self.bounds.size.height - size.height) / 2;
        _loadingView.frame = CGRectMake(x, y, size.width, size.height);
        [self addSubview:_loadingView];
        [_loadingView startAnimating];
    }
    return self;
}

- (void)initialize {
    
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(context, WidthScale, HeightScale);
    CGFloat xOffSet = self.bounds.size.width - self.bounds.size.width * WidthScale;
    CGFloat yOffSet = self.bounds.size.height - self.bounds.size.height * HeightScale;
    CGContextTranslateCTM(context, xOffSet / 2, yOffSet / 2);
    NSArray *samples = [self.filter samplesForFilterSize:self.bounds.size];
    CGFloat midY = CGRectGetMidY(rect);
    
    CGMutablePathRef halfPath = CGPathCreateMutable();
    CGPathMoveToPoint(halfPath, NULL, 0.0f, midY);
    
    for (NSUInteger i = 0; i < samples.count; i++) {
        float sample = [samples[i] floatValue];
        CGPathAddLineToPoint(halfPath, NULL, i, midY - sample);
    }
    CGPathAddLineToPoint(halfPath, NULL, samples.count, midY);
    
    CGMutablePathRef fullPath = CGPathCreateMutable();
    CGPathAddPath(fullPath, NULL, halfPath);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight(rect));
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    CGPathAddPath(fullPath, &transform, halfPath);
    
    CGContextAddPath(context, fullPath);
    CGContextSetFillColorWithColor(context, self.waveColor.CGColor);
    CGContextDrawPath(context, kCGPathFill);
    
    CGPathRelease(fullPath);
    CGPathRelease(halfPath);
}

#pragma mark - setter

- (void)setAsset:(AVAsset *)asset {
    _asset = asset;
    [SampleDataProvider loadAudioSamplesFromAsset:_asset completion:^(NSData *data) {
        self.filter = [[SampleDataFilter alloc] initWithData:data];
        [self.loadingView stopAnimating];
        [self setNeedsDisplay];
    }];
}

- (void)setWaveColor:(UIColor *)waveColor {
    _waveColor = waveColor;
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = waveColor.CGColor;
    [self setNeedsDisplay];
}

@end

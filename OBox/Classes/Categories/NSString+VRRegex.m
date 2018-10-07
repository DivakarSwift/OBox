//
//  NSString+VRRegex.m
//  VRMicro
//
//  Created by kegebai on 2018/5/2.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "NSString+VRRegex.h"

@implementation NSString (VRRegex)

- (NSString *)stringByMatchingRegex:(NSString *)regex capture:(NSUInteger)capture {
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
    NSTextCheckingResult *result = [expression firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    
    if (capture < [result numberOfRanges]) {
        NSRange range = [result rangeAtIndex:capture];
        return [self substringWithRange:range];
    }
    return nil;
}

@end

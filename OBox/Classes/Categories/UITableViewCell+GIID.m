//
//  UITableViewCell+GIID.m
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "UITableViewCell+GIID.h"

@implementation UITableViewCell (GIID)

+ (NSString *)giid {
    return NSStringFromClass([self class]);
}

@end

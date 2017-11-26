//
//  UIColor+Quick.m
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "UIColor+Quick.h"

@implementation UIColor (Quick)

+ (instancetype)colorWithR:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

+ (instancetype)colorWithR:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue {
    return [self colorWithR:red g:green b:blue alpha:1.0];
}

@end

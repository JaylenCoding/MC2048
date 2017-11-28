//
//  MCAppearanceManager.m
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCAppearanceManager.h"
#import "UIColor+Quick.h"

@implementation MCAppearanceManager

- (UIColor *)blockColorForValue:(NSUInteger)value {
    switch (value) {
        case 2:
            return [UIColor colorWithR:238 g:228 b:218];
        case 4:
            return [UIColor colorWithR:237 g:224 b:200];
        case 8:
            return [UIColor colorWithR:242 g:177 b:121];
        case 16:
            return [UIColor colorWithR:245 g:149 b:99];
        case 32:
            return [UIColor colorWithR:246 g:124 b:95];
        case 64:
            return [UIColor colorWithR:246 g:94 b:59];
        case 128:
        case 256:
        case 512:
        case 1024:
        case 2048:
            return [UIColor colorWithR:237 g:207 b:114];
        default:
            return [UIColor whiteColor];
    }
}

- (UIColor *)numberColorForValue:(NSUInteger)value {
    switch (value) {
        case 2:
        case 4:
            return [UIColor colorWithR:119 g:110 b:101];
        default:
            return [UIColor whiteColor];
    }
}

- (UIFont *)fontForNumbers {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
}

@end

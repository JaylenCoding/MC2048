//
//  UIDevice+QucikJudge.m
//  2048
//
//  Created by Minecode on 2017/11/27.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "UIDevice+QucikJudge.h"

@implementation UIDevice (QucikJudge)

- (BOOL)isIphoneX {
    if ([UIScreen mainScreen].bounds.size.height == 812) {
        return true;
    }
    return false;
}

@end

//
//  MCBlockMergeItem.m
//  2048
//
//  Created by Minecode on 2017/11/25.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCBlockMergeItem.h"

@implementation MCBlockMergeItem

+ (instancetype)mergeItem {
    MCBlockMergeItem *item = [[self class] new];
    return item;
}

- (NSString *)description {
    NSString *str;
    switch (self.mode) {
        case MCBlockMergeModeEmpty:
            str = @"空指令";
            break;
        case MCBlockMergeModeStatic:
            str = @"位置不变";
            break;
        case MCBlockMergeModeMoveOnly:
            str = @"仅移动";
            break;
        case MCBlockMergeModeSingleCombine:
            str = @"单个移动并组合";
            break;
        case MCBlockMergeModeDoubleCombine:
            str = @"两个同时移动并组合";
    }
    return [NSString stringWithFormat:@"操作: %@, 索引1: %ld, 索引2: %ld, 值:%ld", str, (long)self.index1, self.index2, self.value];
}

@end

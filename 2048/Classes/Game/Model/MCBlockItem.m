//
//  MCBlockItem.m
//  2048
//
//  Created by Minecode on 2017/11/25.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCBlockItem.h"

@implementation MCBlockItem

+ (instancetype)blockOfEmpty {
    MCBlockItem *block = [[self class] new];
    block.empty = YES;
    block.value = 0;
    return block;
}

- (NSString *)description {
    if (self.empty) {
        return @"方块: (空)";
    }
    return [NSString stringWithFormat:@"方块: (%lu)", self.value];
}

@end

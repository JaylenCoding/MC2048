//
//  MCBlockMoveItem.m
//  2048
//
//  Created by Minecode on 2017/11/25.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCBlockMoveItem.h"

@implementation MCBlockMoveItem

+(instancetype)singleMoveWithSource:(NSInteger)source destination:(NSInteger)destination newValue:(NSInteger)value {
    MCBlockMoveItem *item = [[self class] new];
    item.doubleMove = NO;
    item.source1 = source;
    item.destination = destination;
    item.value = value;
    return item;
}

+ (instancetype)doubleMoveWithSource1:(NSInteger)source1 andSource2:(NSInteger)source2 destination:(NSInteger)destination newValue:(NSInteger)value {
    MCBlockMoveItem *item = [[self class] new];
    item.doubleMove = YES;
    item.source1 = source1;
    item.source2 = source2;
    item.destination = destination;
    item.value = value;
    return item;
}

- (NSString *)description {
    if (self.isDoubleMove) {
        return [NSString stringWithFormat:@"方块单步移动: (从 %ld 和 %ld 到 %ld , 新的值为: %ld)", (unsigned long)self.source1, self.source2, self.destination, self.value];
    }
    else {
        return [NSString stringWithFormat:@"方块同步移动: (从 %ld 到 %ld , 新的值为: %ld)", (unsigned long)self.source1, self.destination, self.value];
    }
}

@end

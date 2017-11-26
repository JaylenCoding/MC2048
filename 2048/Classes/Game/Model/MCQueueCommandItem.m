//
//  MCQueueCommandItem.m
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCQueueCommandItem.h"

@implementation MCQueueCommandItem

+ (instancetype)commandWithDirection:(MCMoveDirection)direction completion:(void (^)(BOOL))completion {
    MCQueueCommandItem *item = [[self class] new];
    item.direction = direction;
    item.completion = completion;
    return item;
}

@end

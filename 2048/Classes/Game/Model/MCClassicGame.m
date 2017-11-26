//
//  MCClassicGame.m
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCClassicGame.h"

#import "MCBlockItem.h"
#import "MCBlockMoveItem.h"
#import "MCBlockMergeItem.h"
#import "MCQueueCommandItem.h"

#if DEBUG
#define MCLOG(...) NSLog(__VA_ARGS__)
#else
#define MCLOG(...)
#endif

// 命令队列宏定义
#define MAX_COMMANDS        100
#define ANI_DELAY           0.3

@interface MCClassicGame ()

@property (nonatomic, weak) id<MCClassicGameDelegate> delegate;
// 游戏棋盘
@property (nonatomic, strong) NSMutableArray *boardState;
// 游戏属性数据
@property (nonatomic, assign) NSUInteger dimension;
@property (nonatomic, assign) NSUInteger threshold;
// 游戏操作队列数据
@property (nonatomic, strong) NSMutableArray *commandQueue;
@property (nonatomic, strong) NSTimer *queueTimer;
// 游戏数据
@property (nonatomic, assign) NSInteger score;

@end


@implementation MCClassicGame

+ (instancetype)gameWithDimension:(NSUInteger)dimension winThreshold:(NSUInteger)threshold delegate:(id<MCClassicGameDelegate>)delegate {
    MCClassicGame *game = [[self class] new];
    game.dimension = dimension;
    game.threshold = threshold;
    game.delegate = delegate;
    [game reset];
    return game;
}

// 游戏重置方法
- (void)reset {
    self.score = 0;
    self.boardState = nil;
    [self.commandQueue removeAllObjects];
    [self.queueTimer invalidate];
    self.queueTimer = nil;
}

#pragma mark - 添加方块API

- (void)addBlockWithValue:(NSUInteger)value atIndexPath:(NSIndexPath *)indexPath {
    if (![self blockForIndexPath:indexPath].empty) {
        return;
    }
    MCBlockItem *block = [self blockForIndexPath:indexPath];
    block.empty = NO;
    block.value = value;
    if (self.delegate!=nil && [(NSObject *)self.delegate respondsToSelector:@selector(addBlockAtIndexPath:value:)]) {
        [self.delegate addBlockAtIndexPath:indexPath value:value];
    } else {
        MCLOG(@"(addBlockAtIndexPath:value:) 方法未实现");
    }
}

- (void)addBlockRandomWithVlue:(NSUInteger)value {
    // 判断棋盘是否为空
    BOOL emptySpotFound = NO;
    for (NSInteger i = 0; i < [self.boardState count]; ++i) {
        if (((MCBlockItem *)self.boardState).empty) {
            emptySpotFound = YES;
            break;
        }
    }
    if (!emptySpotFound) {
        return;
    }
    // 棋盘不为空的情况
    NSInteger row = 0;
    BOOL canExit = NO;
    // 随机生成新方块的行位置，并判断该列有没有空位
    while (YES) {
        row = arc4random_uniform((uint32_t)self.dimension);
        for (NSInteger i = 0; i < self.dimension; ++i) {
            NSIndexPath *idx = [NSIndexPath indexPathForRow:row inSection:i];
            if ([self blockForIndexPath:idx].empty) {
                canExit = YES;
                break;
            }
        }
        if (canExit) break;
    }
    // 随机生成新方块的列位置，并判断该行有没有空位
    NSInteger column = 0;
    canExit = NO;
    while (YES) {
        column = arc4random_uniform((uint32_t)self.dimension);
        NSIndexPath *idx = [NSIndexPath indexPathForRow:row inSection:column];
        if ([self blockForIndexPath:idx].empty) {
            canExit = YES;
            break;
        }
        if (canExit) break;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:column];
    [self addBlockWithValue:value atIndexPath: indexPath];
}

#pragma mark - 位移API
// 向指定位置位移并回调
- (void)performMoveInDirection:(MCMoveDirection *)direction completion:(void (^)(BOOL))completion {
    MCQueueCommandItem *command = [MCQueueCommandItem commandWithDirection:direction completion:completion];
    [self queueComamnd:command];
}

- (BOOL)performMoveUp {
    BOOL blockMoved = NO;
    // 处理每一列
    for (NSInteger column = 0; column < self.dimension; ++column) {
        NSMutableArray *currentColumnBlocks = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger row = 0; row < self.dimension; ++row) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:column];
            [currentColumnBlocks addObject:[self blockForIndexPath: indexPath]];
        }
        NSArray *mergedArray = [self mergeGroup:currentColumnBlocks];
        if ([mergedArray count] > 0) {
            blockMoved = YES;
            for (NSInteger i = 0; i < [mergedArray count]; ++i) {
                MCBlockMoveItem *moveItem = mergedArray[i];
                if (moveItem.doubleMove) {
                    NSIndexPath *source1Idx = [NSIndexPath indexPathForRow:moveItem.source1 inSection:column];
                    NSIndexPath *source2Idx = [NSIndexPath indexPathForRow:moveItem.source2 inSection:column];
                    NSIndexPath *destinationIdx = [NSIndexPath indexPathForRow:moveItem.destination inSection:column];
                    
                    MCBlockItem *source1Block = [self blockForIndexPath: source1Idx];
                    source1Block.empty = YES;
                    MCBlockItem *source2Block = [self blockForIndexPath: source2Idx];
                    source2Block.empty = YES;
                    MCBlockItem *destinationBlock = [self blockForIndexPath: destinationIdx];
                    destinationBlock.empty = NO;
                    destinationBlock.value = moveItem.value;
                    
                    // 构造完成，移动方块
                    if (self.delegate!=nil && [(NSObject *)self.delegate respondsToSelector:@selector(moveBlockFromIndexPath1:andIndexPath2:toIndexPath:newValue:)]) {
                        [self.delegate moveBlockFromIndexPath1:source1Idx
                                                 andIndexPath2:source2Idx
                                                   toIndexPath:destinationIdx
                                                      newValue:moveItem.value];
                    } else {
                        MCLOG(@"(moveBlockFromIndexPath1:andIndexPath2:toIndexPath:newValue:) 方法未实现");
                    }
                }
                else {
                    NSIndexPath *sourceIdx = [NSIndexPath indexPathForRow:moveItem.source1 inSection:column];
                    NSIndexPath *destinationIdx = [NSIndexPath indexPathForRow:moveItem.destination inSection:column];
                    
                    MCBlockItem *sourceBlock = [self blockForIndexPath: sourceIdx];
                    sourceBlock.empty = YES;
                    MCBlockItem *destinationBlock = [self blockForIndexPath: destinationIdx];
                    destinationBlock.empty = NO;
                    destinationBlock.value = moveItem.value;
                    
                    // 构造完成，移动方块
                    if (self.delegate!=nil && [(NSObject *)self.delegate respondsToSelector:@selector(moveBlockFromIndexPath:toIndexPath:newValue:)]) {
                        [self.delegate moveBlockFromIndexPath:sourceIdx
                                                  toIndexPath:destinationIdx
                                                     newValue:moveItem.value];
                    } else {
                        MCLOG(@"(moveBlockFromIndexPath:toIndexPath:newValue:) 方法未实现");
                    }
                }
            }
        }
    }
    return blockMoved;
}

- (BOOL)performMoveDown {
    BOOL blockMoved = NO;
    // 处理每一列
    for (NSInteger column = 0; column < self.dimension; ++column) {
        NSMutableArray *currentColumnBlocks = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger row = (self.dimension-1); row >= 0; --row) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:column];
            [currentColumnBlocks addObject:[self blockForIndexPath: indexPath]];
        }
        NSArray *mergedArray = [self mergeGroup:currentColumnBlocks];
        if ([mergedArray count] > 0) {
            blockMoved = YES;
            NSInteger idxDimension = self.dimension-1;
            for (NSInteger i = 0; i < [mergedArray count]; ++i) {
                MCBlockMoveItem *moveItem = mergedArray[i];
                if (moveItem.doubleMove) {
                    NSIndexPath *source1Idx = [NSIndexPath indexPathForRow:idxDimension-moveItem.source1 inSection:column];
                    NSIndexPath *source2Idx = [NSIndexPath indexPathForRow:idxDimension-moveItem.source2 inSection:column];
                    NSIndexPath *destinationIdx = [NSIndexPath indexPathForRow:idxDimension-moveItem.destination inSection:column];
                    
                    MCBlockItem *source1Block = [self blockForIndexPath: source1Idx];
                    source1Block.empty = YES;
                    MCBlockItem *source2Block = [self blockForIndexPath: source2Idx];
                    source2Block.empty = YES;
                    MCBlockItem *destinationBlock = [self blockForIndexPath: destinationIdx];
                    destinationBlock.empty = NO;
                    destinationBlock.value = moveItem.value;
                    
                    // 构造完成，移动方块
                    if (self.delegate!=nil && [(NSObject *)self.delegate respondsToSelector:@selector(moveBlockFromIndexPath1:andIndexPath2:toIndexPath:newValue:)]) {
                        [self.delegate moveBlockFromIndexPath1:source1Idx
                                                 andIndexPath2:source2Idx
                                                   toIndexPath:destinationIdx
                                                      newValue:moveItem.value];
                    } else {
                        MCLOG(@"(moveBlockFromIndexPath1:andIndexPath2:toIndexPath:newValue:) 方法未实现");
                    }
                }
                else {
                    NSIndexPath *sourceIdx = [NSIndexPath indexPathForRow:idxDimension-moveItem.source1 inSection:column];
                    NSIndexPath *destinationIdx = [NSIndexPath indexPathForRow:idxDimension-moveItem.destination inSection:column];
                    
                    MCBlockItem *sourceBlock = [self blockForIndexPath: sourceIdx];
                    sourceBlock.empty = YES;
                    MCBlockItem *destinationBlock = [self blockForIndexPath: destinationIdx];
                    destinationBlock.empty = NO;
                    destinationBlock.value = moveItem.value;
                    
                    // 构造完成，移动方块
                    if (self.delegate!=nil && [(NSObject *)self.delegate respondsToSelector:@selector(moveBlockFromIndexPath:toIndexPath:newValue:)]) {
                        [self.delegate moveBlockFromIndexPath:sourceIdx
                                                  toIndexPath:destinationIdx
                                                     newValue:moveItem.value];
                    } else {
                        MCLOG(@"(moveBlockFromIndexPath:toIndexPath:newValue:) 方法未实现");
                    }
                }
            }
        }
    }
    return blockMoved;
}

- (BOOL)performMoveLeft {
    BOOL blockMoved = NO;
    // 处理每一列
    for (NSInteger row = 0; row < self.dimension; ++row) {
        NSMutableArray *currentColumnBlocks = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger column = 0; column < self.dimension; ++column) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:column];
            [currentColumnBlocks addObject:[self blockForIndexPath: indexPath]];
        }
        NSArray *mergedArray = [self mergeGroup:currentColumnBlocks];
        if ([mergedArray count] > 0) {
            blockMoved = YES;
            for (NSInteger i = 0; i < [mergedArray count]; ++i) {
                MCBlockMoveItem *moveItem = mergedArray[i];
                if (moveItem.doubleMove) {
                    NSIndexPath *source1Idx = [NSIndexPath indexPathForRow:row inSection:moveItem.source1];
                    NSIndexPath *source2Idx = [NSIndexPath indexPathForRow:row inSection:moveItem.source2];
                    NSIndexPath *destinationIdx = [NSIndexPath indexPathForRow:row inSection:moveItem.destination];
                    
                    MCBlockItem *source1Block = [self blockForIndexPath: source1Idx];
                    source1Block.empty = YES;
                    MCBlockItem *source2Block = [self blockForIndexPath: source2Idx];
                    source2Block.empty = YES;
                    MCBlockItem *destinationBlock = [self blockForIndexPath: destinationIdx];
                    destinationBlock.empty = NO;
                    destinationBlock.value = moveItem.value;
                    
                    // 构造完成，移动方块
                    if (self.delegate!=nil && [(NSObject *)self.delegate respondsToSelector:@selector(moveBlockFromIndexPath1:andIndexPath2:toIndexPath:newValue:)]) {
                        [self.delegate moveBlockFromIndexPath1:source1Idx
                                                 andIndexPath2:source2Idx
                                                   toIndexPath:destinationIdx
                                                      newValue:moveItem.value];
                    } else {
                        MCLOG(@"(moveBlockFromIndexPath1:andIndexPath2:toIndexPath:newValue:) 方法未实现");
                    }
                }
                else {
                    NSIndexPath *sourceIdx = [NSIndexPath indexPathForRow:row inSection:moveItem.source1];
                    NSIndexPath *destinationIdx = [NSIndexPath indexPathForRow:row inSection:moveItem.destination];
                    
                    MCBlockItem *sourceBlock = [self blockForIndexPath: sourceIdx];
                    sourceBlock.empty = YES;
                    MCBlockItem *destinationBlock = [self blockForIndexPath: destinationIdx];
                    destinationBlock.empty = NO;
                    destinationBlock.value = moveItem.value;
                    
                    // 构造完成，移动方块
                    if (self.delegate!=nil && [(NSObject *)self.delegate respondsToSelector:@selector(moveBlockFromIndexPath:toIndexPath:newValue:)]) {
                        [self.delegate moveBlockFromIndexPath:sourceIdx
                                                  toIndexPath:destinationIdx
                                                     newValue:moveItem.value];
                    } else {
                        MCLOG(@"(moveBlockFromIndexPath:toIndexPath:newValue:) 方法未实现");
                    }
                }
            }
        }
    }
    return blockMoved;
}

- (BOOL)performMoveRight {
    BOOL blockMoved = NO;
    // 处理每一列
    for (NSInteger row = 0; row < self.dimension; ++row) {
        NSMutableArray *currentColumnBlocks = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger column = (self.dimension-1); column >= 0; --column) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:column];
            [currentColumnBlocks addObject:[self blockForIndexPath: indexPath]];
        }
        NSArray *mergedArray = [self mergeGroup:currentColumnBlocks];
        if ([mergedArray count] > 0) {
            blockMoved = YES;
            NSInteger idxDimension = self.dimension-1;
            for (NSInteger i = 0; i < [mergedArray count]; ++i) {
                MCBlockMoveItem *moveItem = mergedArray[i];
                if (moveItem.doubleMove) {
                    NSIndexPath *source1Idx = [NSIndexPath indexPathForRow:row inSection:idxDimension-moveItem.source1];
                    NSIndexPath *source2Idx = [NSIndexPath indexPathForRow:row inSection:idxDimension-moveItem.source2];
                    NSIndexPath *destinationIdx = [NSIndexPath indexPathForRow:row inSection:idxDimension-moveItem.destination];
                    
                    MCBlockItem *source1Block = [self blockForIndexPath: source1Idx];
                    source1Block.empty = YES;
                    MCBlockItem *source2Block = [self blockForIndexPath: source2Idx];
                    source2Block.empty = YES;
                    MCBlockItem *destinationBlock = [self blockForIndexPath: destinationIdx];
                    destinationBlock.empty = NO;
                    destinationBlock.value = moveItem.value;
                    
                    // 构造完成，移动方块
                    if (self.delegate!=nil && [(NSObject *)self.delegate respondsToSelector:@selector(moveBlockFromIndexPath1:andIndexPath2:toIndexPath:newValue:)]) {
                        [self.delegate moveBlockFromIndexPath1:source1Idx
                                                 andIndexPath2:source2Idx
                                                   toIndexPath:destinationIdx
                                                      newValue:moveItem.value];
                    } else {
                        MCLOG(@"(moveBlockFromIndexPath1:andIndexPath2:toIndexPath:newValue:) 方法未实现");
                    }
                }
                else {
                    NSIndexPath *sourceIdx = [NSIndexPath indexPathForRow:row inSection:idxDimension-moveItem.source1];
                    NSIndexPath *destinationIdx = [NSIndexPath indexPathForRow:row inSection:idxDimension-moveItem.destination];
                    
                    MCBlockItem *sourceBlock = [self blockForIndexPath: sourceIdx];
                    sourceBlock.empty = YES;
                    MCBlockItem *destinationBlock = [self blockForIndexPath: destinationIdx];
                    destinationBlock.empty = NO;
                    destinationBlock.value = moveItem.value;
                    
                    // 构造完成，移动方块
                    if (self.delegate!=nil && [(NSObject *)self.delegate respondsToSelector:@selector(moveBlockFromIndexPath:toIndexPath:newValue:)]) {
                        [self.delegate moveBlockFromIndexPath:sourceIdx
                                                  toIndexPath:destinationIdx
                                                     newValue:moveItem.value];
                    } else {
                        MCLOG(@"(moveBlockFromIndexPath:toIndexPath:newValue:) 方法未实现");
                    }
                }
            }
        }
    }
    return blockMoved;
}

#pragma mark - 游戏状态API

- (BOOL)isUserLost {
    for (NSInteger i = 0; i < [self.boardState count]; ++i) {
        if (((MCBlockItem *)self.boardState[i]).empty) {
            return NO;
        }
    }
    
    for (NSInteger i = 0; i < self.dimension; ++i) {
        for (NSInteger j = 0; j < self.dimension; ++j) {
            MCBlockItem *item = [self blockForIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            if (j != (self.dimension-1) && item.value==[self blockForIndexPath:[NSIndexPath indexPathForRow:i inSection:j+1]].value) {
                return NO;
            }
            if (i != (self.dimension-1) && item.value==[self blockForIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:j]].value) {
                return NO;
            }
        }
    }
    return YES;
}

- (NSIndexPath *)userHasWon {
    for (NSInteger i = 0; i < [self.boardState count]; ++i) {
        if (((MCBlockItem *)self.boardState[i]).value == self.threshold) {
            return [NSIndexPath indexPathForRow:i / self.dimension
                                      inSection:i % self.dimension];
        }
    }
    return nil;
}

#pragma mark - 支撑数据API

// 将命令加入队列
- (void)queueComamnd:(MCQueueCommandItem *)command {
    // 队列过载时丢弃
    if (!command || [self.commandQueue count] > MAX_COMMANDS) {
        return;
    }
    
    [self.commandQueue addObject:command];
    if (!self.commandQueue || ![self.queueTimer isValid]) {
        // 如果队列已空时加入，则重新开启计时器
        [self timerFired:nil];
    }
}

- (void)timerFired:(NSTimer *)timer {
    // 没有任务则不开启任务
    if ([self.commandQueue count] <= 0) return;
    
    BOOL blockMoved = NO;
    // 开启命令执行循环
    while ([self.commandQueue count] > 0) {
        MCQueueCommandItem *command = [self.commandQueue firstObject];
        [self.commandQueue removeObjectAtIndex:0];
        // 判断方向来执行任务动画
        switch (command.direction) {
            case MCMoveDirectionUp:
                blockMoved = [self performMoveUp];
                break;
            case MCMoveDirectionDown:
                blockMoved = [self performMoveDown];
                break;
            case MCMoveDirectionLeft:
                blockMoved = [self performMoveLeft];
                break;
            case MCMoveDirectionRight:
                blockMoved = [self performMoveRight];
                break;
        }
        // 执行回调block
        if (command.completion) {
            command.completion(blockMoved);
        }
        // FIXME: 此处略有不懂
        if (blockMoved) {
            break;
        }
    }
    
    // 开启时钟，递归调用方法
    self.queueTimer = [NSTimer scheduledTimerWithTimeInterval:ANI_DELAY
                                                       target:self
                                                     selector:@selector(timerFired:)
                                                     userInfo:nil
                                                      repeats:NO];
}

- (MCBlockItem *)blockForIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = (indexPath.row * self.dimension + indexPath.section);
    if (idx >= [self.boardState count]) {
        return nil;
    }
    return self.boardState[idx];
}

- (void)setBlock:(MCBlockItem *)block forIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = (indexPath.row * self.dimension + indexPath.section);
    if (!block || idx>=[self.boardState count]) {
        return;
    }
    self.boardState[idx] = block;
}

- (NSMutableArray *)commandQueue {
    if (!_commandQueue) {
        _commandQueue = [NSMutableArray array];
    }
    return _commandQueue;
}

- (NSMutableArray *)boardState {
    if (!_boardState) {
        _boardState = [NSMutableArray array];
        for (NSInteger i = 0; i < (self.dimension*self.dimension); ++i) {
            [_boardState addObject:[MCBlockItem blockOfEmpty]];
        }
    }
    return _boardState;
}

- (void)setScore:(NSInteger)score {
    _score = score;
    if (self.delegate!=nil && [(NSObject *)self.delegate respondsToSelector:@selector(scoreDidChange:)]) {
        [self.delegate scoreDidChange:score];
    } else {
        MCLOG(@"(scoreDidChange:) 方法未实现");
    }
}

- (void)setPeak:(NSInteger)peak {
    _peak = peak;
    if (self.delegate!=nil && [(NSObject *)self.delegate respondsToSelector:@selector(peakDidChange:)]) {
        [self.delegate peakDidChange:peak];
    } else {
        MCLOG(@"(peakDidChange:) 方法未实现");
    }
}

// 合并队列，处理方块的合并
- (NSArray *)mergeGroup:(NSArray *)group {
    NSInteger cnt = 0;
    // 第一次处理：将所有分散方块排列放置
    NSMutableArray *arr1 = [NSMutableArray array];
    for (NSInteger i = 0; i < self.dimension; ++i) {
        MCBlockItem *blockItem = group[i];
        if (blockItem.empty) {
            continue;
        }
        MCBlockMergeItem *mergeItem = [MCBlockMergeItem mergeItem];
        mergeItem.index1 = i;
        mergeItem.value = blockItem.value;
        if (i == cnt) {
            // 此时不用移动
            mergeItem.mode = MCBlockMergeModeStatic;
        }
        else {
            // 有空位，需要移动
            mergeItem.mode = MCBlockMergeModeMoveOnly;
        }
        [arr1 addObject:mergeItem];
        cnt++;
    }
    if ([arr1 count] == 0) {
        // 本行没有方块
        return nil;
    }
    else if ([arr1 count] == 1) {
        // 当本行只有一个方块: 若需要移动，直接让它移动即可。若不需要移动，直接返回空。
        if (((MCBlockMergeItem *)arr1[0]).mode == MCBlockMergeModeMoveOnly) {
            MCBlockMergeItem *mergeItem = (MCBlockMergeItem *)arr1[0];
            return @[[MCBlockMoveItem singleMoveWithSource:mergeItem.index1
                                               destination:0
                                                  newValue:mergeItem.value]];
        }
        else {
            return nil;
        }
    }
    
    // 如果本行的剩余方块大于一个，那么需要进行第二步处理
    // 第二次处理: 构造移动指令队列
    cnt = 0;
    BOOL hasPreMerge = NO;
    NSMutableArray *arr2 = [NSMutableArray array];
    while (cnt < [arr1 count] - 1) {
        MCBlockMergeItem *item1 = (MCBlockMergeItem *)arr1[cnt];
        MCBlockMergeItem *item2 = (MCBlockMergeItem *)arr1[cnt+1];
        if (item1.value == item2.value) {
            // 如果两方块可以合并
            if (item1.mode==MCBlockMergeModeStatic && !hasPreMerge) {
                // 如果item1不移动且之前没有发生过合并的话,item1不移动，item2合并到item1上
                hasPreMerge = YES;
                MCBlockMergeItem *mergeNewBlock = [MCBlockMergeItem mergeItem];
                mergeNewBlock.mode = MCBlockMergeModeSingleCombine;
                mergeNewBlock.index1 = item2.index1;
                mergeNewBlock.value = item1.value * 2;
                self.score += mergeNewBlock.value;
                self.peak = MAX(self.peak, mergeNewBlock.value);
                [arr2 addObject: mergeNewBlock];
            }
            else {
                // item1之前移动过了
                MCBlockMergeItem *mergeNewBlock = [MCBlockMergeItem mergeItem];
                mergeNewBlock.mode = MCBlockMergeModeDoubleCombine;
                mergeNewBlock.index1 = item1.index1;
                mergeNewBlock.index2 = item2.index1;
                mergeNewBlock.value = item1.value * 2;
                self.score += mergeNewBlock.value;
                self.peak = MAX(self.peak, mergeNewBlock.value);
                [arr2 addObject: mergeNewBlock];
            }
            cnt += 2;
        }
        else {
            // 两方块不能合并，实际上只是处理item1，因为item2可以继续与后面的进行合并
            [arr2 addObject: item1];
            if ([arr2 count]-1 != cnt) {
                item1.mode = MCBlockMergeModeMoveOnly;
            }
            cnt++;
        }
        // 判断: 如果item2后面没有方块的话，将item2也放入arr2中
        if (cnt == [arr1 count] - 1) {
            MCBlockMergeItem *mergeNewBlock = arr1[cnt];
            [arr2 addObject: mergeNewBlock];
            if ([arr2 count]-1 != cnt) {
                mergeNewBlock.mode = MCBlockMergeModeMoveOnly;
            }
        }
    }
    
    // 第三次处理: 将处理好的队列发送位移指令
    NSMutableArray *arr3 = [NSMutableArray array];
    for (NSInteger i = 0; i < [arr2 count]; ++i) {
        MCBlockMergeItem *mergeNewBlock = arr2[i];
        switch (mergeNewBlock.mode) {
            case MCBlockMergeModeEmpty:
            case MCBlockMergeModeStatic:
                continue;
            case MCBlockMergeModeMoveOnly:
            case MCBlockMergeModeSingleCombine:
                [arr3 addObject: [MCBlockMoveItem singleMoveWithSource:mergeNewBlock.index1
                                                           destination:i
                                                              newValue:mergeNewBlock.value]];
                break;
            case MCBlockMergeModeDoubleCombine:
                [arr3 addObject: [MCBlockMoveItem doubleMoveWithSource1:mergeNewBlock.index1
                                                             andSource2:mergeNewBlock.index2
                                                            destination:i
                                                               newValue:mergeNewBlock.value]];
                break;
        }
    }
    
    return [NSArray arrayWithArray:arr3];
}

@end

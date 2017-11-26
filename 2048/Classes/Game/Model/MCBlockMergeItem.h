//
//  MCBlockMergeItem.h
//  2048
//
//  Created by Minecode on 2017/11/25.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <Foundation/Foundation.h>

// 方块操作模式
typedef NS_ENUM(NSInteger, MCBlockMergeMode){
    MCBlockMergeModeEmpty,          // 空
    MCBlockMergeModeStatic,         // 静止不动
    MCBlockMergeModeMoveOnly,       // 仅移动
    MCBlockMergeModeSingleCombine,  // 单个移动并组合
    MCBlockMergeModeDoubleCombine   // 两个同时移动并组合
};

// 方块操作模型
@interface MCBlockMergeItem : NSObject

@property (nonatomic, assign) MCBlockMergeMode mode;
@property (nonatomic, assign) NSInteger index1;
@property (nonatomic, assign) NSInteger index2;
@property (nonatomic, assign) NSInteger value;

+ (instancetype)mergeItem;

@end

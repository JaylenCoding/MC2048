//
//  MCBlockMoveItem.h
//  2048
//
//  Created by Minecode on 2017/11/25.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCBlockMoveItem : NSObject

@property (nonatomic, assign) NSUInteger source1;
@property (nonatomic, assign) NSUInteger source2;
@property (nonatomic, assign) NSUInteger destination;
@property (nonatomic, assign, getter=isDoubleMove) BOOL doubleMove;
@property (nonatomic, assign) NSUInteger value;

// 只有一个方块位移
+ (instancetype)singleMoveWithSource:(NSInteger)source
                         destination:(NSInteger)destination
                            newValue:(NSInteger)value;
// 两个方块同时位移
+ (instancetype)doubleMoveWithSource1:(NSInteger)source1
                           andSource2:(NSInteger)source2
                         destination:(NSInteger)destination
                            newValue:(NSInteger)value;

@end

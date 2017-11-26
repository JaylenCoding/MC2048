//
//  MCQueueCommandItem.h
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCClassicGame.h"

@interface MCQueueCommandItem : NSObject

@property (nonatomic, assign) MCMoveDirection direction;
@property (nonatomic, copy) void(^completion)(BOOL blockMoved);

+ (instancetype)commandWithDirection:(MCMoveDirection)direction
                          completion:(void(^)(BOOL))completion;

@end

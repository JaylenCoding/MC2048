//
//  MCBlockItem.h
//  2048
//
//  Created by Minecode on 2017/11/25.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCBlockItem : NSObject

@property (nonatomic, assign) BOOL empty;
@property (nonatomic, assign) NSUInteger value;

+ (instancetype)blockOfEmpty;

@end

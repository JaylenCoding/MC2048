//
//  MCClassicGame.h
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 方块移动方向
typedef NS_ENUM(NSInteger, MCMoveDirection){
    MCMoveDirectionUp,
    MCMoveDirectionDown,
    MCMoveDirectionLeft,
    MCMoveDirectionRight
};

@class MCClassicGame;

// 经典模式委托方法
@protocol MCClassicGameDelegate

- (void)scoreDidChange:(NSInteger)newScore;

- (void)peakDidChange:(NSInteger)newPeak;

- (void)moveBlockFromIndexPath:(NSIndexPath *)from
                   toIndexPath:(NSIndexPath *)to
                      newValue:(NSUInteger)value;

- (void)moveBlockFromIndexPath1:(NSIndexPath *)from1
                  andIndexPath2:(NSIndexPath *)from2
                    toIndexPath:(NSIndexPath *)to
                       newValue:(NSUInteger)value;

- (void)addBlockAtIndexPath:(NSIndexPath *)indexPath
                      value:(NSUInteger)value;

@end

/* ------------------------------------- */

@interface MCClassicGame : NSObject

@property (nonatomic, readonly) NSInteger score;
@property (nonatomic, readonly) NSInteger peak;

+ (instancetype)gameWithDimension:(NSUInteger)dimension
                     winThreshold:(NSUInteger)value
                         delegate:(id<MCClassicGameDelegate>)delegate;

- (void)addBlockWithValue:(NSUInteger)value
              atIndexPath:(NSIndexPath *)indexPath;

- (void)addBlockRandomWithVlue:(NSUInteger)value;

- (void)performMoveInDirection:(MCMoveDirection *)direction
                    completion:(void(^)(BOOL))completion;

- (void)reset;

- (BOOL)isUserLost;

- (NSIndexPath *)userHasWon;

@end

//
//  MCClassicGameVC.h
//  2048
//
//  Created by Minecode on 2017/11/25.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <UIKit/UIKit.h>

// 经典模式游戏委托方法
@protocol MCClassicGameControllerDelegate <NSObject>

/**
 游戏结束调用
 
 @param didWin 是否胜利
 @param score 总分
 @param peak 最高方块分数
 */
- (void)gameFinishedWithWin:(BOOL)didWin score:(NSInteger)score peak:(NSInteger)peak;

@end

/* ------------------------------------------------ */

// 经典模式控制器
@interface MCClassicGameVC : UIViewController

@property (nonatomic, weak) id<MCClassicGameControllerDelegate> delegate;

+ (instancetype)gameWithDimension:(NSUInteger)dimension
                     winThreshold:(NSUInteger)threshold
                        gameTitle:(NSString *)gameTitle
                  backgroundColor:(UIColor *)backgroundColor
                    swipeControls:(BOOL)swipeEnabled;

@end



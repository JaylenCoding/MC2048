//
//  MCGameboardView.m
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCGameboardView.h"

#import "MCBlockView.h"
#import "MCAppearanceManager.h"

#if DEBUG
#define MCLOG(...) NSLog(__VA_ARGS__)
#else
#define MCLOG(...)
#endif

// 动画宏定义
#define PER_SQUARE_SLIDE_TIME       0.08

#define BLOCK_ADD_START_SCALE       0.1
#define BLOCK_ADD_MAX_SCALE         1.1
#define BLOCK_ADD_DELAY             0.05
#define BLOCK_ADD_EXPAND_TIME       0.18
#define BLOCK_ADD_REVERSE_TIME      0.08

#define BLOCK_MERGE_START_SCALE     1.0
#define BLOCK_MERGE_EXPAND_TIME     0.08
#define BLOCK_MERGE_REVERSE_TIME    0.08

@interface MCGameboardView ()

@property (nonatomic, strong) NSMutableDictionary *blocksDict;
// 游戏属性
@property (nonatomic, assign) NSUInteger dimension;
@property (nonatomic, assign) CGFloat blockWidth;
@property (nonatomic, assign) CGFloat blockPadding;
@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, strong) MCAppearanceManager *appearanceManager;

@end


@implementation MCGameboardView

+ (instancetype)gameboardWithDimension:(NSUInteger)dimension blockWidth:(CGFloat)width blockPadding:(CGFloat)padding cornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)backgroundColor foregroundColor:(UIColor *)foregroundColor {
    CGFloat boardWidth = dimension*(width+padding) + padding;
    MCGameboardView *view = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, boardWidth, boardWidth)];
    view.dimension = dimension;
    view.blockPadding = padding;
    view.blockWidth = width;
    view.layer.cornerRadius = cornerRadius;
    view.cornerRadius = cornerRadius;
    [view setBackgroundWithBackgroundColor:backgroundColor
                        andForegroundColor:foregroundColor];
    return view;
}

// 重置游戏棋盘场景
- (void)reset {
    for (NSString *key in self.blocksDict) {
        MCBlockView *view = self.blocksDict[key];
        [view removeFromSuperview];
    }
    [self.blocksDict removeAllObjects];
    self.userInteractionEnabled = YES;
}

- (void)setBackgroundWithBackgroundColor:(UIColor *)backgroundColor andForegroundColor:(UIColor *)foregroundColor {
    self.backgroundColor = backgroundColor;
    
    CGFloat xCursor = self.blockPadding;
    CGFloat yCursor;
    CGFloat cornerRadius = MAX(0, self.cornerRadius - 2);
    for (NSInteger i = 0; i < self.dimension; ++i) {
        yCursor = self.blockPadding;
        for (NSInteger j = 0; j < self.dimension; ++j) {
            UIView *blockBkg = [[UIView alloc] initWithFrame:CGRectMake(xCursor, yCursor, self.blockWidth, self.blockWidth)];
            blockBkg.backgroundColor = foregroundColor;
            blockBkg.layer.cornerRadius = cornerRadius;
            [self addSubview:blockBkg];
            yCursor += self.blockPadding + self.blockWidth;
        }
        xCursor += self.blockPadding + self.blockWidth;
    }
}

// 添加方块及添加动画
- (void)addBlockAtIndexPath:(NSIndexPath *)indexPath withValue:(NSUInteger)value {
    // 边界判断
    if (!indexPath || indexPath.row>=self.dimension || indexPath.section>=self.dimension || self.blocksDict[indexPath]) {
        return;
    }
    // 计算位置
    CGFloat xCursor = self.blockPadding + indexPath.section*(self.blockWidth+self.blockPadding);
    CGFloat yCursor = self.blockPadding + indexPath.row*(self.blockWidth + self.blockPadding);
    CGPoint blockPosition = CGPointMake(xCursor, yCursor);
    CGFloat cornerRadius = MAX(self.cornerRadius-2, 0);
    
    MCBlockView *blockView = [MCBlockView blockForPosition:blockPosition sideLength:self.blockWidth value:value cornerRadius:cornerRadius];
    blockView.delegate = self.appearanceManager;
    // 使用仿射变换设置初始大小
    blockView.layer.affineTransform = CGAffineTransformMakeScale(BLOCK_ADD_START_SCALE, BLOCK_ADD_START_SCALE);
    [self addSubview:blockView];
    self.blocksDict[indexPath] = blockView;
    // 添加方块弹出动画
    [UIView animateWithDuration:BLOCK_ADD_EXPAND_TIME
                          delay:BLOCK_ADD_DELAY
                        options:0
                     animations:^{
                         blockView.layer.affineTransform = CGAffineTransformMakeScale(BLOCK_ADD_MAX_SCALE, BLOCK_ADD_MAX_SCALE);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:BLOCK_ADD_REVERSE_TIME animations:^{
                             blockView.layer.affineTransform = CGAffineTransformIdentity;
                         }];
                     }];
}

- (void)moveBlockFromIndexPath:(NSIndexPath *)srcIdx toIndexPath:(NSIndexPath *)desIdx withValue:(NSUInteger)value {
    if (!srcIdx || !desIdx || !self.blocksDict[srcIdx] || desIdx.row>=self.dimension || desIdx.section>=self.dimension) {
        return;
    }
    // 计算位置
    MCBlockView *srcView = self.blocksDict[srcIdx];
    MCBlockView *desView = self.blocksDict[desIdx];
    BOOL shouldPop = desView != nil;
    
    CGFloat xCursor = self.blockPadding + desIdx.section*(self.blockWidth+self.blockPadding);
    CGFloat yCursor = self.blockPadding + desIdx.row*(self.blockWidth+self.blockPadding);
    CGRect finalFrame = srcView.frame;
    finalFrame.origin.x = xCursor;
    finalFrame.origin.y = yCursor;
    
    // 更新棋盘
    [self.blocksDict removeObjectForKey:srcIdx];
    self.blocksDict[desIdx] = srcView;
    // 执行移动动画
    [UIView animateWithDuration:(PER_SQUARE_SLIDE_TIME)
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         // PER_SQUARE_SLIDE_TIME时间之后方块完成位移
                         srcView.frame = finalFrame;
                     } completion:^(BOOL finished) {
                         srcView.blockValue = value;
                         if (!shouldPop || !finished) {
                             return;
                         }
                         srcView.layer.affineTransform = CGAffineTransformMakeScale(BLOCK_MERGE_START_SCALE, BLOCK_MERGE_START_SCALE);
                         // 完成，移除目标视图
                         [desView removeFromSuperview];
                         [UIView animateWithDuration:BLOCK_MERGE_EXPAND_TIME
                                          animations:^{
                                              srcView.layer.affineTransform = CGAffineTransformMakeScale(BLOCK_ADD_MAX_SCALE, BLOCK_ADD_MAX_SCALE);
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:BLOCK_MERGE_REVERSE_TIME
                                                               animations:^{
                                                                   srcView.layer.affineTransform = CGAffineTransformIdentity;
                                                               }];
                                          }];
                     }];
}

- (void)moveBlockFromIndexPath1:(NSIndexPath *)srcIdx1 andIndexPath2:(NSIndexPath *)srcIdx2 toIndexPath:(NSIndexPath *)desIdx withValue:(NSUInteger)value {
    if (!srcIdx1 || !srcIdx2 || !self.blocksDict[srcIdx1] || !self.blocksDict[srcIdx2] || desIdx.row>=self.dimension || desIdx.section>=self.dimension) {
        return;
    }
    // 计算位置
    MCBlockView *src1View = self.blocksDict[srcIdx1];
    MCBlockView *src2View = self.blocksDict[srcIdx2];
    
    CGFloat xCursor = self.blockPadding + desIdx.section*(self.blockWidth+self.blockPadding);
    CGFloat yCursor = self.blockPadding + desIdx.row*(self.blockWidth+self.blockPadding);
    CGRect finalFrame = src1View.frame;
    finalFrame.origin.x = xCursor;
    finalFrame.origin.y = yCursor;
    
    [self.blocksDict removeObjectForKey:srcIdx1];
    [self.blocksDict removeObjectForKey:srcIdx2];
    self.blocksDict[desIdx] = src1View;
    
    [UIView animateWithDuration:(PER_SQUARE_SLIDE_TIME*1)
                                   delay:0
                                 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         src1View.frame = finalFrame;
                         src2View.frame = finalFrame;
                     } completion:^(BOOL finished) {
                         src1View.blockValue = value;
                         if (!finished) {
                             [src2View removeFromSuperview];
                             return;
                         }
                         src1View.layer.affineTransform = CGAffineTransformMakeScale(BLOCK_MERGE_START_SCALE, BLOCK_MERGE_START_SCALE);
                         [src2View removeFromSuperview];
                         [UIView animateWithDuration:BLOCK_MERGE_EXPAND_TIME
                                          animations:^{
                                              src1View.layer.affineTransform = CGAffineTransformMakeScale(BLOCK_ADD_MAX_SCALE, BLOCK_ADD_MAX_SCALE);
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:BLOCK_MERGE_REVERSE_TIME
                                                               animations:^{
                                                                   src1View.layer.affineTransform = CGAffineTransformIdentity;
                                                               }];
                                          }];
                     }];
}

- (MCAppearanceManager *)appearanceManager {
    if (!_appearanceManager) {
        _appearanceManager = [MCAppearanceManager new];
    }
    return _appearanceManager;
}

- (NSMutableDictionary *)blocksDict {
    if (!_blocksDict) {
        _blocksDict = [NSMutableDictionary dictionary];
    }
    return _blocksDict;
}

@end

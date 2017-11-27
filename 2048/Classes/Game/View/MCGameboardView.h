//
//  MCGameboardView.h
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCGameboardView : UIView

+ (instancetype)gameboardWithDimension:(NSUInteger)dimension
                             blockWidth:(CGFloat)width
                           blockPadding:(CGFloat)padding
                          cornerRadius:(CGFloat)cornerRadius
                       backgroundColor:(UIColor *)backgroundColor
                       foregroundColor:(UIColor *)foregroundColor;

- (void)reset;

- (void)addBlockAtIndexPath:(NSIndexPath *)indexPath
                  withValue:(NSUInteger)value;

- (void)moveBlockFromIndexPath:(NSIndexPath *)srcIdx
                   toIndexPath:(NSIndexPath *)desIdx
                     withValue:(NSUInteger)value;

- (void)moveBlockFromIndexPath1:(NSIndexPath *)srcIdx1
                  andIndexPath2:(NSIndexPath *)srcIdx2
                   toIndexPath:(NSIndexPath *)desIdx
                     withValue:(NSUInteger)value;

@end

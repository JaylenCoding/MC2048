//
//  MCBlockView.h
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCAppearanceManagerDelegate;

@interface MCBlockView : UIView

@property (nonatomic, assign) NSInteger blockValue;
// 代理方法
@property (nonatomic, weak) id<MCAppearanceManagerDelegate> delegate;

+ (instancetype)blockForPosition:(CGPoint)position
                      sideLength:(CGFloat)side
                           value:(NSUInteger)value
                    cornerRadius:(CGFloat)cornerRadius;

@end

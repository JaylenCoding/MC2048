//
//  MCScoreView.h
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCScoreView : UIView

@property (nonatomic, assign) NSInteger score;

+ (instancetype)scoreWithCornerRadius:(CGFloat)radius
                      backgroundColor:(UIColor *)color
                            textColor:(UIColor *)textColor
                             textFont:(UIFont *)textFont;

@end

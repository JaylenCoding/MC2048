//
//  MCPeakView.h
//  2048
//
//  Created by Minecode on 2017/11/27.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPeakView : UIView

@property (nonatomic, assign) NSInteger peak;

+ (instancetype)peakWithCornerRadius:(CGFloat)radius
                      backgroundColor:(UIColor *)color
                            textColor:(UIColor *)textColor
                             textFont:(UIFont *)textFont;

@end

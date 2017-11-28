//
//  MCPeakView.m
//  2048
//
//  Created by Minecode on 2017/11/27.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCPeakView.h"

@interface MCPeakView ()

@property (nonatomic, weak) UILabel *peakLabel;

@end

@implementation MCPeakView

+ (instancetype)peakWithCornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)color textColor:(UIColor *)textColor textFont:(UIFont *)textFont {
    MCPeakView *view = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*0.25, 60)];
    view.peak = 0;
    view.layer.cornerRadius = cornerRadius;
    view.backgroundColor = color ? color: [UIColor whiteColor];
    view.userInteractionEnabled = YES;
    if (textColor) {
        view.peakLabel.textColor = textColor;
    }
    if (textFont) {
        view.peakLabel.font = textFont;
    }
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [self addSubview:label];
        self.peakLabel = label;
    }
    return self;
}

- (void)setPeak:(NSInteger)peak {
    _peak = peak;
    self.peakLabel.text = [NSString stringWithFormat:@"最高\n%ld", self.peak];
}

@end

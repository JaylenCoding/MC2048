//
//  MCScoreView.m
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCScoreView.h"

#define DEFAULT_FRAME CGRectMake(0, 0, 140, 60)

@interface MCScoreView ()

@property (nonatomic, strong) UILabel *scoreLabel;

@end


@implementation MCScoreView

+ (instancetype)scoreWithCornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)color textColor:(UIColor *)textColor textFont:(UIFont *)textFont {
    MCScoreView *view = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*0.25, 60)];
    view.score = 0;
    view.layer.cornerRadius = cornerRadius;
    view.backgroundColor = color ? color: [UIColor whiteColor];
    view.userInteractionEnabled = YES;
    if (textColor) {
        view.scoreLabel.textColor = textColor;
    }
    if (textFont) {
        view.scoreLabel.font = textFont;
    }
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [self addSubview:label];
        self.scoreLabel = label;
    }
    return self;
}

- (void)setScore:(NSInteger)score {
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"分数\n%ld", (long)self.score];
}

@end

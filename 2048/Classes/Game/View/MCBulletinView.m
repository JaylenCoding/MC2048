//
//  MCBulletinView.m
//  2048
//
//  Created by Minecode on 2017/11/27.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCBulletinView.h"

@interface MCBulletinView ()

@property (nonatomic, strong) UILabel *textLabel;

@end


@implementation MCBulletinView

+ (instancetype)bulletinWithCornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)color textColor:(UIColor *)textColor textFont:(UIFont *)textFont {
    MCBulletinView *view = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.3, 0)];
    view.layer.cornerRadius = cornerRadius;
    view.backgroundColor = color;
    view.userInteractionEnabled = YES;
    if (textColor) {
        view.textLabel.textColor = textColor;
    }
    if (textFont) {
        view.textLabel.font = textFont;
    }
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.text = @"2048";
        [self addSubview:label];
        self.textLabel = label;
    }
    return self;
}

- (void)layoutSubviews {
    CGRect labelFrame = self.textLabel.frame;
    labelFrame.size.height = self.frame.size.height;
    labelFrame.size.width = self.frame.size.width;
    self.textLabel.frame = labelFrame;
}

- (void)setGameTitle:(NSString *)gameTitle {
    _gameTitle = gameTitle;
    self.textLabel.text = gameTitle;
}

@end

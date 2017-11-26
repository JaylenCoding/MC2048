//
//  MCBlockView.m
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCBlockView.h"
#import "MCAppearanceManager.h"

@interface MCBlockView ()

// 方块属性
@property (nonatomic, readonly) UIColor *defaultBackgroundColor;
@property (nonatomic, readonly) UIColor *defaultNumberColor;

@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, assign) NSUInteger value;

@end

@implementation MCBlockView

// 请使用该构造器
+ (instancetype)blockForPosition:(CGPoint)position sideLength:(CGFloat)sideLength value:(NSUInteger)value cornerRadius:(CGFloat)cornerRadius {
    MCBlockView *view = [[[self class] alloc] initWithFrame: CGRectMake(position.x, position.y, sideLength, sideLength)];
    view.blockValue = value;
    view.backgroundColor = view.defaultBackgroundColor;
    view.numberLabel.textColor = view.defaultNumberColor;
    view.value = value;
    view.layer.cornerRadius = cornerRadius;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.3;
        [self addSubview:label];
        self.numberLabel = label;
    }
    return self;
}

- (void)setDelegate:(id<MCAppearanceManagerDelegate>)delegate {
    _delegate = delegate;
    if (delegate != nil) {
        self.backgroundColor = [delegate blockColorForValue:self.blockValue];
        self.numberLabel.textColor = [delegate numberColorForValue:self.blockValue];
        self.numberLabel.font = [delegate fontForNumbers];
    }
}

- (void)setBlockValue:(NSInteger)blockValue {
    _blockValue = blockValue;
    self.numberLabel.text = [@(blockValue) stringValue];
    if (self.delegate != nil) {
        self.backgroundColor = [self.delegate blockColorForValue:blockValue];
        self.numberLabel.textColor = [self.delegate numberColorForValue:blockValue];
    }
    self.value = blockValue;
}

- (UIColor *)defaultBackgroundColor {
    return [UIColor lightGrayColor];
}

- (UIColor *)defaultNumberColor {
    return [UIColor blackColor];
}

@end

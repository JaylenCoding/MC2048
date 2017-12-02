//
//  MCButtonScaleTransition.m
//  2048
//
//  Created by Minecode on 2017/11/28.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCButtonScaleTransition.h"
#import "MCHomeVC.h"
#import "MCInterestVC.h"

#define TRAN_DURATION 0.3

@implementation MCButtonScaleTransition

+ (instancetype)transitionWithType:(MCButtonScaleTransitionType)type {
    return [[self alloc] initWithType:type];
}

- (instancetype)initWithType:(MCButtonScaleTransitionType)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

#pragma mark - UIViewControllerAnimationTransition
// 转场持续时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return TRAN_DURATION;
}

// 处理转场上下文
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.type) {
        case MCButtonScaleTransitionPresent:
            [self presentAnimationWithContext:transitionContext];
            break;
        case MCButtonScaleTransitionDismiss:
            [self dismissAnimationWithContext:transitionContext];
            break;
    }
}

#pragma mark - 私有API
// 根据转场上下文实现present
- (void)presentAnimationWithContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    MCHomeVC *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    MCInterestVC *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    
    // 绘制路径
    UIBezierPath *beginPath = [UIBezierPath bezierPathWithRect:fromVC.intersetButton.frame];
    UIBezierPath *endPath = [UIBezierPath bezierPathWithRect:[UIScreen mainScreen].bounds];
    // 创建CAShapeLayer遮罩层并遮罩toVC
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = endPath.CGPath;
    toVC.view.layer.mask = maskLayer;
    // 创建路径动画
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.delegate = self;
    // 设置动画路径
    maskLayerAnimation.fromValue = (__bridge id)(beginPath.CGPath);
    maskLayerAnimation.toValue = (__bridge id)(endPath.CGPath);
    maskLayerAnimation.duration = [self transitionDuration:transitionContext];
    maskLayerAnimation.delegate = self;
    maskLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    // 添加动画
    [maskLayerAnimation setValue:transitionContext forKey:@"transitionContext"];
    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
}

// 根据转场上下文实现dismiss
- (void)dismissAnimationWithContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    MCInterestVC *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    MCHomeVC *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIView *containerView = [transitionContext containerView];
    // 绘制路径
    UIBezierPath *beginPath = [UIBezierPath bezierPathWithRect:[UIScreen mainScreen].bounds];
    UIBezierPath *endPath = [UIBezierPath bezierPathWithRect:toVC.intersetButton.frame];
    // 创建CAShapeLayer遮罩层并遮罩toVC
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = endPath.CGPath;
    fromVC.view.layer.mask = maskLayer;
    // 创建路径动画
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.delegate = self;
    // 设置动画路径
    maskLayerAnimation.fromValue = (__bridge id)(beginPath.CGPath);
    maskLayerAnimation.toValue = (__bridge id)(endPath.CGPath);
    maskLayerAnimation.duration = [self transitionDuration:transitionContext];
    maskLayerAnimation.delegate = self;
    maskLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    // 添加动画
    [maskLayerAnimation setValue:transitionContext forKey:@"transitionContext"];
    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    switch (self.type) {
        case MCButtonScaleTransitionPresent: {
            id<UIViewControllerContextTransitioning> transitionContext = [anim valueForKey:@"transitionContext"];
            [transitionContext completeTransition:YES];
        }
        case MCButtonScaleTransitionDismiss: {
            id<UIViewControllerContextTransitioning> transitionContext = [anim valueForKey:@"transitionContext"];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            if ([transitionContext transitionWasCancelled]) {
                [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
            }
        }
            
    }
}
@end

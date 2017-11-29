//
//  MCButtonScaleTransition.h
//  2048
//
//  Created by Minecode on 2017/11/28.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MCButtonScaleTransitionType) {
    MCButtonScaleTransitionPresent = 0,
    MCButtonScaleTransitionDismiss
};


@interface MCButtonScaleTransition : NSObject<UIViewControllerAnimatedTransitioning, CAAnimationDelegate>

@property (nonatomic, assign) MCButtonScaleTransitionType type;

+ (instancetype)transitionWithType:(MCButtonScaleTransitionType)type;

- (instancetype)initWithType:(MCButtonScaleTransitionType)type;

@end

//
//  MCInterestVC.m
//  2048
//
//  Created by Minecode on 2017/11/28.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCInterestVC.h"
#import "MCClassicGameVC.h"

#import "MCButtonScaleTransition.h"

@interface MCInterestVC () <UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UIButton *mode33Button;
@property (weak, nonatomic) IBOutlet UIButton *mode55Button;
@property (weak, nonatomic) IBOutlet UIButton *modeNMButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;


@end

@implementation MCInterestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButton];
}

#pragma mark - 初始化配置
- (instancetype)init {
    if (self = [super init]) {
        // 设置自定义转场
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        // 设置自定义转场
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

#pragma mark - 私有方法
- (void)setupButton {
    [self.mode33Button addTarget:self action:@selector(mode33Action) forControlEvents:UIControlEventTouchUpInside];
    [self.mode55Button addTarget:self action:@selector(mode55Action) forControlEvents:UIControlEventTouchUpInside];
    [self.modeNMButton addTarget:self action:@selector(modeNMAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)mode33Action {
    MCClassicGameVC *vc = [MCClassicGameVC gameWithDimension:3
                                                winThreshold:128
                                                   gameTitle:@"2048\n3×3模式"
                                             backgroundColor:[UIColor whiteColor]
                                               swipeControls:YES];
    vc.gameNotice = @"达到128以获得胜利";
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)mode55Action {
    MCClassicGameVC *vc = [MCClassicGameVC gameWithDimension:5
                                                winThreshold:2048
                                                   gameTitle:@"2048\n5×5模式"
                                             backgroundColor:[UIColor whiteColor]
                                               swipeControls:YES];
    vc.gameNotice = @"达到2048以获得胜利";
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)modeNMAction {
    MCClassicGameVC *vc = [MCClassicGameVC gameWithDimension:8
                                                winThreshold:8192
                                                   gameTitle:@"2048\n噩梦模式"
                                             backgroundColor:[UIColor whiteColor]
                                               swipeControls:YES];
    vc.gameNotice = @"达到8192以获得胜利";
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)backAction {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - 转场动画实现
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [MCButtonScaleTransition transitionWithType:MCButtonScaleTransitionPresent];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [MCButtonScaleTransition transitionWithType:MCButtonScaleTransitionDismiss];
}

@end

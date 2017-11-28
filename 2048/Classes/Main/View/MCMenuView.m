//
//  MCMenuView.m
//  2048
//
//  Created by Minecode on 2017/11/28.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCMenuView.h"

#import "UIColor+Quick.h"

#if DEBUG
#define MCLOG(...) NSLog(__VA_ARGS__)
#else
#define MCLOG(...)
#endif

#define BKG_EXPAND_TIME        0.26
#define MENU_START_SCALE       0.1
#define MENU_MAX_SCALE         1.1
#define MENU_DELAY             0
#define MENU_EXPAND_TIME       0.18
#define MENU_REVERSE_TIME      0.08

#define BKG_MAX_ALPHA          0.7
#define MENU_HEADER_HEIGHT     10

@interface MCMenuView ()

// UI控件
@property (nonatomic, strong) UIView *bkgView;
@property (nonatomic, strong) UIView *menuContainer;
@property (nonatomic, strong) UIButton *sharedButton;
@property (nonatomic, strong) UIButton *backButton;

// 游戏属性
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL sharedEnabled;           // 分享
@property (nonatomic, assign) BOOL backEnabled;             // 返回主菜单
@property (nonatomic, assign) BOOL tapQuitEnabled;          // 取消

// 游戏UI属性
@property (nonatomic, strong) UIColor *menuBackgroundColor;

@end


@implementation MCMenuView

+ (instancetype)menuWithBackgroundColor:(UIColor *)color tapQuitEnabled:(BOOL)tapQuitEnabled sharedEnabled:(BOOL)sharedEnabled {
    MCMenuView *view = [[MCMenuView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    // 属性设置
    view.menuBackgroundColor = color;
    view.sharedEnabled = sharedEnabled;
    view.tapQuitEnabled = YES;
    view.backEnabled = YES;
    [view setupView];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setupView {
    self.count = 0;
    if (self.sharedEnabled) self.count++;
    if (self.backEnabled) self.count++;
    // 创建背景遮罩视图
    UIView *bkgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    bkgView.backgroundColor = [UIColor darkGrayColor];
    bkgView.alpha = 0;
    if (self.tapQuitEnabled) {
        [bkgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonTapped)]];
    }
    bkgView.userInteractionEnabled = NO;
    [self addSubview:bkgView];
    self.bkgView = bkgView;
    
    // 计算菜单高度
    CGFloat menuWidth = 0.6 * [UIScreen mainScreen].bounds.size.width;
    CGFloat menuItemHeight = 50;
    CGFloat menuHeight = MENU_HEADER_HEIGHT + self.count * 51 - 1;
    CGFloat xCursor = 0.5 * ([UIScreen mainScreen].bounds.size.width - menuWidth);
    CGFloat yCursor = 0.5 * ([UIScreen mainScreen].bounds.size.height - menuHeight);
    // 生成菜单视图
    UIView *menuContainer = [[UIView alloc] init];
    menuContainer.frame = CGRectMake(xCursor, yCursor, menuWidth, menuHeight);
    menuContainer.backgroundColor = [UIColor whiteColor];
    [self addSubview:menuContainer];
    self.menuContainer = menuContainer;
    
    /// 生成按钮
    xCursor = 0;
    yCursor = MENU_HEADER_HEIGHT;
    // 生成分享按钮
    if (self.sharedEnabled) {
        UIButton *sharedButton = [[UIButton alloc] initWithFrame:CGRectMake(xCursor, yCursor, menuWidth, menuItemHeight)];
        [sharedButton setTitle:@"分享战绩" forState: UIControlStateNormal];
        [sharedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        sharedButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [sharedButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.menuContainer addSubview:sharedButton];
        self.sharedButton = sharedButton;
        yCursor += menuItemHeight + 1;
    }
    
    // 生成返回主菜单按钮
    if (self.backEnabled) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(xCursor, yCursor, menuWidth, menuItemHeight)];
        [backButton setTitle:@"返回主菜单" forState: UIControlStateNormal];
        [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.menuContainer addSubview:backButton];
        self.sharedButton = backButton;
    }
    
    /// 绘制线条
    // 绘制顶端线条
    UIView *headerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, MENU_HEADER_HEIGHT)];
    headerSeparator.backgroundColor = [UIColor colorWithR:76 g:153 b:246];
    [menuContainer addSubview:headerSeparator];
    // 绘制分隔线条
    yCursor = MENU_HEADER_HEIGHT;
    for (NSInteger i = 1; i <= self.count - 1; ++i) {
        UIView *cellSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, yCursor+i*menuItemHeight, menuWidth, 1)];
        cellSeparator.backgroundColor = [UIColor darkGrayColor];
        [menuContainer addSubview:cellSeparator];
    }
    
    /// 动画
    // 背景遮罩动画
    [UIView animateWithDuration:BKG_EXPAND_TIME
                          delay:MENU_DELAY
                        options:0
                     animations:^{
                         self.bkgView.alpha = BKG_MAX_ALPHA;
                     } completion:^(BOOL finished) {
                         self.bkgView.userInteractionEnabled = YES;
                     }];
    // 菜单动画
    menuContainer.layer.affineTransform = CGAffineTransformMakeScale(MENU_START_SCALE, MENU_START_SCALE);
    menuContainer.userInteractionEnabled = NO;
    [UIView animateWithDuration:MENU_EXPAND_TIME
                          delay:MENU_DELAY
                        options:0
                     animations:^{
                         menuContainer.layer.affineTransform = CGAffineTransformMakeScale(MENU_MAX_SCALE, MENU_MAX_SCALE);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:MENU_REVERSE_TIME
                                          animations:^{
                                              menuContainer.layer.affineTransform = CGAffineTransformIdentity;
                                          } completion:^(BOOL finished) {
                                              menuContainer.userInteractionEnabled = YES;
                                          }];
                     }];
}

/// 逻辑响应API
// 菜单--取消
- (void)cancelButtonTapped {
    self.userInteractionEnabled = NO;
    // 背景遮罩消失动画
    [UIView animateWithDuration:BKG_EXPAND_TIME
                     animations:^{
                         self.bkgView.alpha = 0;
                     } completion:^(BOOL finished) {
                         // 不知道写什么
                     }];
    // 菜单栏消失动画
    [UIView animateWithDuration:MENU_EXPAND_TIME
                     animations:^{
                         self.menuContainer.layer.affineTransform = CGAffineTransformMakeScale(MENU_MAX_SCALE, MENU_MAX_SCALE);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:MENU_REVERSE_TIME
                                          animations:^{
                                              self.menuContainer.layer.affineTransform = CGAffineTransformMakeScale(MENU_START_SCALE, MENU_START_SCALE);
                                          } completion:^(BOOL finished) {
                                              if ([self.delegate respondsToSelector:@selector(menuShouldQuit:)]) {
                                                  [self.delegate menuShouldQuit:self];
                                              }
                                              else {
                                                  MCLOG(@"menuShouldQuit:方法未实现");
                                              }
                                          }];
                     }];
}

// 菜单--返回主菜单
- (void)backButtonTapped {
    if ([self.delegate respondsToSelector:@selector(menuShouldBackToMain)]) {
        [self.delegate menuShouldBackToMain];
    }
    else {
        MCLOG(@"menuShouldBackToMain方法未实现");
    }
}

- (void)shareButtonTapped {
    if ([self.delegate respondsToSelector:@selector(menuShouldShared)]) {
        [self.delegate menuShouldShared];
    }
    else {
        MCLOG(@"menuShouldShared方法未实现");
    }
}

@end

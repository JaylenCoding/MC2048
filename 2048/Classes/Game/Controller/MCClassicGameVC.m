//
//  MCClassicGameVC.m
//  2048
//
//  Created by Minecode on 2017/11/25.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCClassicGameVC.h"

#import "MCClassicGame.h"
#import "MCScoreView.h"
#import "MCPeakView.h"
#import "MCBulletinView.h"
#import "MCGameboardView.h"
#import "MCMenuView.h"

#import "UIDevice+QucikJudge.h"
#import "UIColor+Quick.h"

#if DEBUG
#define MCLOG(...) NSLog(__VA_ARGS__)
#else
#define MCLOG(...)
#endif

#define ELEMENT_SPACING 10
#define DEFAULT_BULLETIN_BKG_COLOR [UIColor colorWithR:231 g:196 b:66]
#define DEFAULT_BOARD_BKG_COLOR [UIColor colorWithR:182 g:172 b:159]

@interface MCClassicGameVC () <MCClassicGameDelegate, MCMenuViewDelegate>

// 界面UI控件
@property (nonatomic, strong) MCGameboardView *gameboard;
@property (nonatomic, strong) MCClassicGame *classicGame;
@property (nonatomic, strong) MCScoreView *scoreView;
@property (nonatomic, strong) MCPeakView *peakView;
@property (nonatomic, strong) MCBulletinView *bulletinView;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *restartButton;

// 游戏属性
@property (nonatomic, copy) NSString *gameTitle;
@property (nonatomic, assign) NSUInteger dimension;
@property (nonatomic, assign) NSUInteger threshold;
@property (nonatomic, assign) BOOL useScoreView;
@property (nonatomic, assign) BOOL usePeakView;
@property (nonatomic, assign) BOOL useBulletinView;

@end

@implementation MCClassicGameVC

+ (instancetype)gameWithDimension:(NSUInteger)dimension winThreshold:(NSUInteger)threshold gameTitle:(NSString *)gameTitle backgroundColor:(UIColor *)backgroundColor swipeControls:(BOOL)swipeEnabled {
    MCClassicGameVC *vc = [[self class] new];
    vc.dimension = MAX(dimension, 2);
    vc.threshold = MAX(threshold, 16);
    vc.gameTitle = gameTitle;
    vc.useScoreView = YES;
    vc.usePeakView = YES;
    vc.useBulletinView = YES;
    vc.view.backgroundColor = backgroundColor ? backgroundColor: [UIColor whiteColor];
    [vc setupGestures];
    return vc;
}

#pragma mark - 添加手势检测器
-(void)setupGestures {
    UISwipeGestureRecognizer *upGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(controlUp)];
    upGes.numberOfTouchesRequired = 1;
    upGes.direction = UISwipeGestureRecognizerDirectionUp;
    [self.gameboard addGestureRecognizer:upGes];
    
    UISwipeGestureRecognizer *downGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(controlDown)];
    downGes.numberOfTouchesRequired = 1;
    downGes.direction = UISwipeGestureRecognizerDirectionDown;
    [self.gameboard addGestureRecognizer:downGes];
    
    UISwipeGestureRecognizer *leftGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(controlLeft)];
    leftGes.numberOfTouchesRequired = 1;
    leftGes.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.gameboard addGestureRecognizer:leftGes];
    
    UISwipeGestureRecognizer *rightGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(controlRight)];
    rightGes.numberOfTouchesRequired = 1;
    rightGes.direction = UISwipeGestureRecognizerDirectionRight;
    [self.gameboard addGestureRecognizer:rightGes];
}

- (void)setupGame {
    MCScoreView *scoreView;
    MCPeakView *peakView;
    MCBulletinView *bulletinView;
    
    // 创建视图
    if (self.useScoreView) {
        scoreView = [MCScoreView scoreWithCornerRadius:6
                                       backgroundColor:DEFAULT_BOARD_BKG_COLOR
                                             textColor:[UIColor whiteColor]
                                              textFont:[UIFont fontWithName:@"HelveticaNeue-Bold"
                                                                       size:16]];
        self.scoreView = scoreView;
    }
    if (self.usePeakView) {
        peakView = [MCPeakView peakWithCornerRadius:6
                                    backgroundColor:DEFAULT_BOARD_BKG_COLOR
                                          textColor:[UIColor whiteColor]
                                           textFont:[UIFont fontWithName:@"HelveticaNeue-Bold"
                                                                    size:16]];
        self.peakView = peakView;
    }
    if (self.useBulletinView) {
        bulletinView = [MCBulletinView bulletinWithCornerRadius:6
                                                backgroundColor:DEFAULT_BULLETIN_BKG_COLOR
                                                      textColor:[UIColor whiteColor]
                                                       textFont:[UIFont fontWithName:@"HelveticaNeue-Bold"
                                                                                size:24]];
        bulletinView.gameTitle = self.gameTitle;
        self.bulletinView = bulletinView;
    }
    UIButton *menuButton = [[UIButton alloc] init];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setBackgroundColor:[UIColor colorWithR:227 g:155 b:101]];
    menuButton.layer.cornerRadius = 6;
    [menuButton setTitle:@"菜单" forState:UIControlStateNormal];
    self.menuButton = menuButton;
    UIButton *restartButton = [[UIButton alloc] init];
    [restartButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    [restartButton setBackgroundColor:[UIColor colorWithR:227 g:155 b:101]];
    restartButton.layer.cornerRadius = 6;
    [restartButton setTitle:@"重置" forState:UIControlStateNormal];
    self.restartButton = restartButton;
    
    // 生成游戏棋盘
    CGFloat padding = (self.dimension > 5) ? 3.0 : 6.0;
    CGFloat cellWidth = floorf((self.view.frame.size.width*0.8 - padding*(self.dimension+1)) / ((float)self.dimension));
    cellWidth = MAX(30, cellWidth);
    MCGameboardView *gameboard = [MCGameboardView gameboardWithDimension:self.dimension
                                                              blockWidth:cellWidth
                                                            blockPadding:padding
                                                            cornerRadius:6
                                                         backgroundColor:[UIColor blackColor]
                                                         foregroundColor:[UIColor darkGrayColor]];
    
    // 计算高度
    CGFloat infoContainerTop;            // 数据容器顶端位置
    CGFloat infoContainerHeight;         // 数据容器高度
    CGFloat ctrButtonTop;                // 控制按钮顶端位置
    CGFloat ctrButtonHeight;             // 控制按钮高度
    CGFloat gameboardTop;                // 棋盘顶端高度
    CGFloat bulletinHeight;              // 游戏信息块高度
    // 计算
    if ([[UIDevice currentDevice] isIphoneX]) {
        infoContainerTop = 54;
    }
    else {
        infoContainerTop = 30;
    }
    infoContainerHeight = 60;
    ctrButtonTop = infoContainerTop + infoContainerHeight + 10;
    ctrButtonHeight = 30;
    gameboardTop = 0.5*(self.view.frame.size.height - gameboard.frame.size.height);
    bulletinHeight = ctrButtonHeight + ctrButtonTop - infoContainerTop;
    
    // 添加分数板
    if (self.useScoreView) {
        CGRect scoreFrame = scoreView.frame;
        scoreFrame.origin.x = 0.4 * self.view.bounds.size.width;
        scoreFrame.origin.y = infoContainerTop;
        scoreFrame.size.height = infoContainerHeight;
        scoreView.frame = scoreFrame;
        [self.view addSubview:scoreView];
    }
    // 添加高分板
    if (self.usePeakView) {
        CGRect peakFrame = peakView.frame;
        peakFrame.origin.x = 0.7 * self.view.bounds.size.width;
        peakFrame.origin.y = infoContainerTop;
        peakFrame.size.height = infoContainerHeight;
        peakView.frame = peakFrame;
        [self.view addSubview:peakView];
    }
    // 添加游戏名称栏
    if (self.useBulletinView) {
        CGRect bulletinFrame = bulletinView.frame;
        bulletinFrame.origin.x = 0.05 * self.view.bounds.size.width;
        bulletinFrame.origin.y = infoContainerTop;
        bulletinFrame.size.height = bulletinHeight;
        bulletinView.frame = bulletinFrame;
        [self.view addSubview:bulletinView];
    }
    // 添加菜单按钮
    CGRect menuButtonFrame = menuButton.frame;
    menuButtonFrame.origin.x = 0.4 * self.view.bounds.size.width;
    menuButtonFrame.origin.y = ctrButtonTop;
    menuButtonFrame.size.height = ctrButtonHeight;
    menuButtonFrame.size.width = 0.25 * self.view.bounds.size.width;
    menuButton.frame = menuButtonFrame;
    [self.view addSubview:menuButton];
    // 添加重置按钮
    CGRect restartButtonFrame = restartButton.frame;
    restartButtonFrame.origin.x = 0.7 * self.view.bounds.size.width;
    restartButtonFrame.origin.y = ctrButtonTop;
    restartButtonFrame.size.height = ctrButtonHeight;
    restartButtonFrame.size.width = 0.25 * self.view.bounds.size.width;
    restartButton.frame = restartButtonFrame;
    [self.view addSubview:restartButton];
    
    CGRect gameboardFrame = gameboard.frame;
    gameboardFrame.origin.x = 0.5 * (self.view.bounds.size.width - gameboardFrame.size.width);
    gameboardFrame.origin.y = gameboardTop;
    gameboard.frame = gameboardFrame;
    [self.view addSubview:gameboard];
    // 完成算高
    self.gameboard = gameboard;
    // 构造游戏模型
    MCClassicGame *classicGame = [MCClassicGame gameWithDimension:self.dimension
                                                     winThreshold:self.threshold
                                                         delegate:self];
    [classicGame addBlockRandomWithVlue:2];
    [classicGame addBlockRandomWithVlue:2];
    self.classicGame = classicGame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGame];
}

#pragma mark - 私有API
- (void)followUp {
    if ([self.classicGame userHasWon]) {
        [self.delegate gameFinishedWithWin:YES score:self.classicGame.score peak:self.classicGame.peak];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"胜利!" message:@"你胜利了!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSInteger rand = arc4random_uniform(10);
        if (rand & 1) {
            [self.classicGame addBlockRandomWithVlue:4];
        }
        else {
            [self.classicGame addBlockRandomWithVlue:2];
        }
        if ([self.classicGame isUserLost]) {
            [self.delegate gameFinishedWithWin:NO score:self.classicGame.score peak:self.classicGame.peak];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"失败!" message:@"你失败了!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - MCClassicGameDelegate代理方法实现
- (void)moveBlockFromIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to newValue:(NSUInteger)value {
    [self.gameboard moveBlockFromIndexPath:from toIndexPath:to withValue:value];
}

- (void)moveBlockFromIndexPath1:(NSIndexPath *)from1 andIndexPath2:(NSIndexPath *)from2 toIndexPath:(NSIndexPath *)to newValue:(NSUInteger)value {
    [self.gameboard moveBlockFromIndexPath1:from1 andIndexPath2:from2 toIndexPath:to withValue:value];
}

- (void)addBlockAtIndexPath:(NSIndexPath *)indexPath value:(NSUInteger)value {
    [self.gameboard addBlockAtIndexPath:indexPath withValue:value];
}

- (void)scoreDidChange:(NSInteger)newScore {
    self.scoreView.score = newScore;
}

- (void)peakDidChange:(NSInteger)newPeak {
    self.peakView.peak = newPeak;
}

#pragma mark - MCMenuViewDelegate代理方法实现
- (void)menuShouldQuit:(MCMenuView *)menuView {
    [menuView removeFromSuperview];
    self.gameboard.userInteractionEnabled = YES;
}

- (void)menuShouldBackToMain {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - 方向控制
- (void)controlUp {
    [self.classicGame performMoveInDirection:MCMoveDirectionUp completion:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)controlDown {
    [self.classicGame performMoveInDirection:MCMoveDirectionDown completion:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)controlLeft {
    [self.classicGame performMoveInDirection:MCMoveDirectionLeft completion:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)controlRight {
    [self.classicGame performMoveInDirection:MCMoveDirectionRight completion:^(BOOL changed) {
        if (changed) [self followUp];
    }];
}

- (void)controlReset {
    [self.gameboard reset];
    [self.classicGame reset];
    [self.classicGame addBlockRandomWithVlue:2];
    [self.classicGame addBlockRandomWithVlue:2];
}

- (void)controlExit {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 游戏控制API
- (void)reset {
    [self.gameboard reset];
    [self.classicGame reset];
    [self.classicGame addBlockRandomWithVlue:2];
    [self.classicGame addBlockRandomWithVlue:2];
}

- (void)showMenu {
    self.gameboard.userInteractionEnabled = NO;
    MCMenuView *view = [MCMenuView menuWithBackgroundColor:DEFAULT_BOARD_BKG_COLOR
                                            tapQuitEnabled:YES
                                             sharedEnabled:YES];
    view.delegate = self;
    [self.view addSubview:view];
}

@end

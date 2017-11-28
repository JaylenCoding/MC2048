//
//  MCMenuView.h
//  2048
//
//  Created by Minecode on 2017/11/28.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCMenuView;

@protocol MCMenuViewDelegate <NSObject>

// 取消菜单栏
- (void)menuShouldQuit:(MCMenuView *)menuView;
// 返回主菜单
- (void)menuShouldBackToMain;
// 分享游戏
- (void)menuShouldShared;

@end


@interface MCMenuView : UIView

@property (nonatomic, weak) id<MCMenuViewDelegate> delegate;

+ (instancetype)menuWithBackgroundColor:(UIColor *)color
                           tapQuitEnabled:(BOOL)tapQuitEnabled
                          sharedEnabled:(BOOL)sharedEnabled;

@end

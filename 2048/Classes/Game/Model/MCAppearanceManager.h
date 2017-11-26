//
//  MCAppearanceManager.h
//  2048
//
//  Created by Minecode on 2017/11/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MCAppearanceManagerDelegate <NSObject>

- (UIColor *)blockColorForValue:(NSUInteger)value;
- (UIColor *)numberColorForValue:(NSUInteger)value;
- (UIFont *)fontForNumbers;

@end

@interface MCAppearanceManager : NSObject <MCAppearanceManagerDelegate>

@end

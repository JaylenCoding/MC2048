//
//  MCHomeVC.m
//  2048
//
//  Created by Minecode on 2017/11/25.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCHomeVC.h"
#import "MCInterestVC.h"

#import "MCClassicGameVC.h"

#if DEBUG
#define MCLOG(...) NSLog(__VA_ARGS__)
#else
#define MCLOG(...)
#endif

@interface MCHomeVC ()

@end

@implementation MCHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)classicButtonTapped:(id)sender {
    MCClassicGameVC *vc = [MCClassicGameVC gameWithDimension:4
                                                winThreshold:1024
                                                   gameTitle:@"2048\n经典模式"
                                             backgroundColor:[UIColor whiteColor]
                                               swipeControls:YES];
    vc.gameNotice = @"达到1024以获得胜利";
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)extremityButtonTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MCInterestVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"interestVC"];
//    MCInterestVC *vc = [[MCInterestVC alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}



@end

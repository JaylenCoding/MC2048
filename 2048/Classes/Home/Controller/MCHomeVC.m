//
//  MCHomeVC.m
//  2048
//
//  Created by Minecode on 2017/11/25.
//  Copyright © 2017年 Minecode. All rights reserved.
//

#import "MCHomeVC.h"

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
    MCLOG(@"classic button tapped");
}


@end

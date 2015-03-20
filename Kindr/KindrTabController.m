//
//  KindrTabController.m
//  Kindr
//
//  Created by Kyle Lucovsky on 3/2/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "KindrTabController.h"
#import "PostListViewController.h"
#import "KindrTabController.h"

@interface KindrTabController ()

@end

@implementation KindrTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:211.0/255.0 green:65.0/255.0 blue:50.0/255.0 alpha:1.0]];
    [UITabBar appearance].tintColor = [UIColor colorWithRed:211.0/255.0 green:65.0/255.0 blue:50.0/255.0 alpha:1.0];
//    [UITabBar appearance].tintColor = [UIColor colorWithRed:254.0/255.0 green:111.0/255.0 blue:32.0/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

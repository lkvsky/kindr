//
//  PostDetailViewController.m
//  Kindr
//
//  Created by Kyle Lucovsky on 2/19/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "PostDetailViewController.h"
#import "PostItemView.h"

@interface PostDetailViewController ()
@end

@implementation PostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.opaque = NO;
    
    float viewWidth = self.view.frame.size.width;
    PostItemView *postView = [[PostItemView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, self.view.frame.size.height)
                                                        withPost:self.post
                                                       withImage:self.postImage];
    [postView renderDetailedView];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, self.view.frame.size.height)];
    scrollView.contentSize = CGSizeMake(viewWidth, postView.frame.size.height);
    [self.view addSubview:scrollView];
    [scrollView addSubview:postView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  PostDetailViewController.h
//  Kindr
//
//  Created by Kyle Lucovsky on 2/19/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostDetailViewController : UIViewController
@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) UIImage *postImage;
@end

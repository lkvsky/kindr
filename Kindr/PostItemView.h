//
//  PostView.h
//  Kindr
//
//  Created by Kyle Lucovsky on 2/18/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostItemView : UIView
@property (strong, nonatomic) Post *post;

- (instancetype)initWithFrame:(CGRect)frame
                     withPost:(Post *)post;
- (instancetype)initWithFrame:(CGRect)frame
                     withPost:(Post *)post
                    withImage:(UIImage *)image;
- (void)renderCardView;
- (void)renderDetailedView;
- (void)renderFeedView;
- (UIImage *)downloadPostImage;
@end

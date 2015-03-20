//
//  PostCell.h
//  Kindr
//
//  Created by Kyle Lucovsky on 3/16/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@protocol SwipeablePostCell <NSObject>
- (void)tapDelete:(NSString *)headline;
@end

@interface PostCell : UITableViewCell
@property (weak, nonatomic) id <SwipeablePostCell> delegate;
- (void)configureWithPost:(Post *)post;
@end

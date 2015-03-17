//
//  PostCell.h
//  Kindr
//
//  Created by Kyle Lucovsky on 3/16/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostCell : UITableViewCell
- (void)configureWithPost:(Post *)post;
@end

//
//  Post+Utilities.h
//  Kindr
//
//  Created by Kyle Lucovsky on 3/9/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "Post.h"
#import <UIKit/UIKit.h>

@interface Post (Utilities)
- (NSString *)parseBlockElementsFromString:(NSString *)content;
//- (NSString *)parseInlineElementsFromString:(NSString *)content;
//- (NSString *)stylizeItalicElementsFromStrong:(NSString *)content;
//- (NSString *)stylizeBoldElementsFromStrong:(NSString *)content;
@end

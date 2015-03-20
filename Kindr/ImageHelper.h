//
//  ImageHelper.h
//  Kindr
//
//  Created by Kyle Lucovsky on 3/20/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageHelper : NSObject
+ (instancetype)sharedInstance;
- (UIImage *)getImageWithUrl:(NSString *)imageUrl;
- (void)removeImageWithUrl:(NSString *)imageUrl;
@end

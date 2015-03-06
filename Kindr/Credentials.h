//
//  Credentials.h
//  Kindr
//
//  Created by Kyle Lucovsky on 3/6/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Credentials : NSObject
+ (NSString *)getUsername;
+ (NSString *)getPassword;
@end

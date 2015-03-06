//
//  APIClient.h
//  Kindr
//
//  Created by Kyle Lucovsky on 2/25/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>
#import "Post.h"

@interface APIClient : NSObject
@property (strong, nonatomic) RKObjectManager *objectManager;

+ (APIClient *)sharedAPIClient  __attribute__((const));
- (void)searchPostsWith:(NSDictionary *)paramaters success:(void (^)(NSArray *results))success failure:(void (^)())failure;
- (void)savePost:(Post *)post asKept:(BOOL)kept;
- (NSArray *)getKeptPosts;
- (NSArray *)getUnseenArticles;
- (NSUInteger)getArticleCount;
- (void)deleteUnkeptPosts;
@end

//
//  APIClient.m
//  Kindr
//
//  Created by Kyle Lucovsky on 2/25/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "APIClient.h"
#import "Post.h"
#import "Credentials.h"

@implementation APIClient

- (instancetype)init
{
    // initialize AFNetworking HTTPClient
    NSURL *baseUrl = [NSURL URLWithString:@"https://esp.weavelet.net"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    [client setAuthorizationHeaderWithUsername:[Credentials getUsername] password:[Credentials getPassword]];
    
    // initialize RestKit and setup datastore
    self.objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];

    NSError *error;
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"]];
    NSManagedObjectModel * managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    RKManagedObjectStore * managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSArray * searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentPath = [searchPaths objectAtIndex:0];
    NSPersistentStore * persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:[NSString stringWithFormat:@"%@/CoreData.sqlite", documentPath] fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    
    if(!persistentStore){
        NSLog(@"Failed to add persistent store: %@", error);
    }
    
    [managedObjectStore createManagedObjectContexts];
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    self.objectManager.managedObjectStore = managedObjectStore;
        
    // setup object mappings
    RKEntityMapping *postMapping = [RKEntityMapping mappingForEntityForName:@"Post" inManagedObjectStore:managedObjectStore];
    [postMapping addAttributeMappingsFromDictionary:@{@"headline": @"headline",
                                                      @"postId": @"postId",
                                                      @"images": @"images",
                                                      @"authorDisplayName": @"authorDisplayName",
                                                      @"defaultBlogId": @"defaultBlogId",
                                                      @"content": @"content"}];
    postMapping.identificationAttributes = @[@"postId"];

    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:@"/api/search/post"
                                                                                           keyPath:@"data.items.post"
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [self.objectManager addResponseDescriptor:responseDescriptor];
    
    return self;
}

+ (APIClient *)sharedAPIClient
{
    static APIClient *sharedInstance = nil;
    sharedInstance = [[APIClient alloc] init];
    
    return sharedInstance;
}

- (void)searchPostsWith:(NSDictionary *)paramaters success:(void (^)(NSArray *results))success failure:(void (^)())failure
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/api/search/post"
                                           parameters:paramaters
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  success([self getUnseenArticles]);
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  failure();
                                              }];
}

- (void)savePost:(Post *)post asKept:(BOOL)kept
{
    post.kept = [NSNumber numberWithBool:kept];
    post.seen = [NSNumber numberWithBool:YES];
    NSError *error;
    
    if (post.isUpdated && post.managedObjectContext) {
        [post.managedObjectContext saveToPersistentStore:&error];
    }
}

- (NSUInteger)getArticleCount
{
    NSManagedObjectContext *context = self.objectManager.managedObjectStore.mainQueueManagedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    NSError *error = nil;
    
    return [context countForFetchRequest:request error:&error];
}

- (NSArray *)getUnseenArticles
{
    NSManagedObjectContext *context = self.objectManager.managedObjectStore.mainQueueManagedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"seen = nil"];
    NSError *error = nil;
    request.predicate = predicate;
    
    return [context executeFetchRequest:request error:&error];
}

- (NSArray *)getKeptPosts
{
    NSManagedObjectContext *managedObjectContext = self.objectManager.managedObjectStore.mainQueueManagedObjectContext;
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kept = YES"];
    request.predicate = predicate;

    return [managedObjectContext executeFetchRequest:request error:&error];
}

- (void)deleteUnkeptPosts
{
    NSManagedObjectContext *managedObjectContext = self.objectManager.managedObjectStore.mainQueueManagedObjectContext;
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kept = NO"];
    request.predicate = predicate;
    NSArray *objectsToDelete = [managedObjectContext executeFetchRequest:request error:&error];
    
    for (Post *post in objectsToDelete) {
        [managedObjectContext deleteObject:post];
    }

    [managedObjectContext saveToPersistentStore:&error];
}

@end

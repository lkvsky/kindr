//
//  Post.h
//  Kindr
//
//  Created by Kyle Lucovsky on 3/3/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * authorDisplayName;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * defaultBlogId;
@property (nonatomic, retain) NSString * headline;
@property (nonatomic, retain) id images;
@property (nonatomic, retain) NSNumber * kept;
@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSNumber * seen;

@end

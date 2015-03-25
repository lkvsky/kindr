//
//  ImageHelper.m
//  Kindr
//
//  Created by Kyle Lucovsky on 3/20/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageHelper.h"

@interface ImageHelper()
@property (strong, nonatomic) NSCache *imageCache;
@end

@implementation ImageHelper
- (NSCache *)imageCache
{
    if (!_imageCache) _imageCache = [[NSCache alloc] init];
    
    return _imageCache;
}

- (instancetype) init
{
    self = [super init];
    return self;
}

+ (instancetype)sharedInstance
{
    static ImageHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (UIImage *)getImageWithUrl:(NSString *)imageUrl
{
    UIImage *image = [self.imageCache objectForKey:imageUrl];
        
    if (image == nil) {
        NSMutableString *imageUrlString = [[NSMutableString alloc] initWithString:@"http://i.kinja-img.com/gawker-media/image/upload/"];
        [imageUrlString appendString:imageUrl];
        
        NSData *imageData = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:imageUrlString]];
        image = [[UIImage alloc] initWithData:imageData];
        
        [self.imageCache setObject:image forKey:imageUrl];
    }
    
    return image;
}

- (BOOL)imageIsCached:(NSString *)imageUrl
{
    if ([self.imageCache objectForKey:imageUrl] != nil) return YES;
    
    return NO;
}

- (void)removeImageWithUrl:(NSString *)imageUrl
{
    UIImage *image = [self.imageCache objectForKey:imageUrl];
    
    if (image != nil) {
        [self.imageCache removeObjectForKey:imageUrl];
    }
}
@end

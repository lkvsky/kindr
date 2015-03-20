//
//  PostView.m
//  Kindr
//
//  Created by Kyle Lucovsky on 2/18/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "PostItemView.h"
#import "Post+Utilities.h"
#import "ImageHelper.h"

@interface PostItemView ()
@property (strong, nonatomic) UIImage *postImage;
@end

@implementation PostItemView

- (instancetype)initWithFrame:(CGRect)frame
                     withPost:(Post *)post
{
    self = [super init];
    self.frame = frame;
    self.post = post;
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                     withPost:(Post *)post
                    withImage:(UIImage *)image
{
    self = [self initWithFrame:frame
               withPost:post];
    self.postImage = image;
    
    return self;
}

- (void)renderCardView
{
    // general fame
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    // headline
    UITextView *headlineView = [[UITextView alloc] init];
    NSAttributedString *headline = [[NSAttributedString alloc] initWithString:self.post.headline attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:20]}];
    [headlineView setAttributedText:headline];
    [headlineView setEditable:NO];
    [headlineView setScrollEnabled:NO];
    CGSize headlineSize = [headlineView sizeThatFits:CGSizeMake(self.frame.size.width, FLT_MAX)];
    headlineView.frame = CGRectMake(0, 0, self.frame.size.width, headlineSize.height);
    [self addSubview:headlineView];
    headlineView.center = CGPointMake(headlineView.frame.size.width / 2, self.frame.size.height - (headlineView.frame.size.height / 2));
    
    // background image
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *background = [[UIImageView alloc] initWithImage:self.postImage];
        float aspectRatio = self.postImage.size.height / self.postImage.size.width;
        background.frame = CGRectMake(0, 0, self.frame.size.height / aspectRatio, self.frame.size.height);
        background.center = CGPointMake(self.center.x, background.center.y);
        
        [self addSubview:background];
        [self sendSubviewToBack:background];
    });
}

- (void)renderDetailedView
{
    float viewWidth = self.frame.size.width;
    
    // headline
    UITextView *headlineView = [[UITextView alloc] init];
    NSAttributedString *headline = [[NSAttributedString alloc] initWithString:self.post.headline attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:20]}];
    [headlineView setAttributedText:headline];
    [headlineView setEditable:NO];
    [headlineView setScrollEnabled:NO];
    CGSize headlineSize = [headlineView sizeThatFits:CGSizeMake(viewWidth, FLT_MAX)];
    headlineView.frame = CGRectMake(0, 0, headlineSize.width, headlineSize.height);
    
    // image
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.postImage];
    float imageHeight = viewWidth * (self.postImage.size.height / self.postImage.size.width);
    imageView.frame = CGRectMake(0, headlineSize.height, viewWidth, imageHeight);
    
    // content
    UITextView *contentView = [[UITextView alloc] init];
    NSAttributedString *attributedContent = [[NSAttributedString alloc]
                                             initWithString:[self.post parseBlockElementsFromString:self.post.content]
                                             attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:16.0]}];
    
    [contentView setEditable:NO];
    [contentView setAttributedText:attributedContent];
    [contentView setScrollEnabled:NO];
    contentView.userInteractionEnabled = YES;
    CGSize contentSize = [contentView sizeThatFits:CGSizeMake(viewWidth, FLT_MAX)];
    contentView.frame = CGRectMake(0, imageHeight + headlineSize.height, contentSize.width, contentSize.height);
    contentView.contentSize = contentSize;
    
    // add subviews to self
    self.frame = CGRectMake(0, 0, viewWidth, headlineSize.height + imageHeight + contentSize.height);
    [self addSubview:headlineView];
    [self addSubview:imageView];
    [self addSubview:contentView];
}

- (UIImage *)downloadPostImage
{
    return self.postImage;
}

- (UIImage *)postImage
{
    if (!_postImage) {
        _postImage = [[ImageHelper sharedInstance] getImageWithUrl:self.post.images[0]];
    }
    
    return _postImage;
}

#pragma mark - Initialization

- (void)setup
{
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
}

- (void)awakeFromNib { [self setup]; }

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    [self setup];
    
    return self;
}

@end

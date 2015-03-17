//
//  PostView.m
//  Kindr
//
//  Created by Kyle Lucovsky on 2/18/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "PostItemView.h"
#import "Post+Utilities.h"

@interface PostItemView ()
@property (strong, nonatomic) UIImage *postImage;
@property (strong, nonatomic) UIView *deleteContainer;
@property (nonatomic) BOOL deleteOpen;
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

- (void)renderFeedView
{
    // variables
    float frameWidth = self.frame.size.width;
    float frameHeight = self.frame.size.height;
    
    // general frame
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.masksToBounds = YES;
    
    // headline
    UITextView *headlineView = [[UITextView alloc] init];
    NSAttributedString *headline = [[NSAttributedString alloc]
                                    initWithString:self.post.headline
                                    attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:16]}];
    [headlineView setAttributedText:headline];
    [headlineView setEditable:NO];
    [headlineView setScrollEnabled:NO];
    headlineView.frame = CGRectMake(frameHeight, 0, frameWidth - frameHeight, frameHeight);
     [self addSubview:headlineView];
    
    // background image
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.postImage];
        float aspectRatio = self.postImage.size.height / self.postImage.size.width;
        imageView.frame = CGRectMake(0, 0, frameHeight / aspectRatio, frameHeight);
        
        UIView *imageContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameHeight, frameHeight)];
        imageContainer.layer.masksToBounds = YES;
        imageContainer.clipsToBounds = YES;
        
        [imageContainer addSubview:imageView];
        [self addSubview:imageContainer];
        [self sendSubviewToBack:imageContainer];
    });
    
    // delete view
    self.deleteContainer = [[UIView alloc] initWithFrame:CGRectMake(-1 * frameHeight, 0, frameHeight, frameHeight)];
    UIImageView *deleteIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"close2"]];
    [self.deleteContainer setBackgroundColor:[UIColor colorWithRed:255 green:0 blue:0 alpha:0.7]];
    [self.deleteContainer addSubview:deleteIcon];
    [self addSubview:self.deleteContainer];
    float iconWidth = 30;
    float centerValue = (self.deleteContainer.frame.size.width / 2) - (iconWidth / 2);
    deleteIcon.frame = CGRectMake(centerValue, centerValue, iconWidth, iconWidth);
    
    // add events for deletion
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(swipePost:)];
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(swipePost:)];
    UIGestureRecognizer *tapPost = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(tapPost:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [rightSwipe setNumberOfTouchesRequired:1];
    [leftSwipe setNumberOfTouchesRequired:1];
    
    [self addGestureRecognizer:rightSwipe];
    [self addGestureRecognizer:leftSwipe];
    [self addGestureRecognizer:tapPost];
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
//    NSString *content = [self.post parseBlockElementsFromString:self.post.content];
//    content = [self.post parseInlineElementsFromString:content];
//    content = [self.post stylizeItalicElementsFromStrong:content];
//    content = [self.post stylizeBoldElementsFromStrong:content];
    
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
        NSMutableString *imageUrlString = [[NSMutableString alloc] initWithString:@"http://i.kinja-img.com/gawker-media/image/upload/"];
        [imageUrlString appendString:self.post.images[0]];
        
        NSData *imageData = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:imageUrlString]];
        _postImage = [[UIImage alloc] initWithData:imageData];
    }
    
    return _postImage;
}

#pragma mark - Events

- (void)swipePost:(UISwipeGestureRecognizer *)sender
{
    CGRect newFrame = self.deleteContainer.frame;
    
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        newFrame = CGRectMake(-1 * self.frame.size.height, 0, self.frame.size.height, self.frame.size.height);
        self.deleteOpen = NO;
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        newFrame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
        self.deleteOpen = YES;
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.deleteContainer.frame = newFrame;
                     }];
}

- (void)tapPost:(UITapGestureRecognizer *)sender
{
    CGPoint touchLocation = [sender locationInView:self];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.deleteOpen && (touchLocation.x < self.deleteContainer.frame.size.width && touchLocation.y < self.deleteContainer.frame.size.height)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TapDelete"
                                                                object:self];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TapPost"
                                                                object:self];
        }
    }
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

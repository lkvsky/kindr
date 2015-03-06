//
//  ViewController.m
//  Kindr
//
//  Created by Kyle Lucovsky on 2/17/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "PostListViewController.h"
#import "Post.h"
#import "PostItemView.h"
#import "PostDetailViewController.h"
#import "APIClient.h"

@interface PostListViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;
@property (strong, nonatomic) NSMutableArray *posts;
@property (weak, nonatomic) Post *selectedPost;
@property (weak, nonatomic) APIClient *sharedAPIClient;
@property (strong, nonatomic) PostItemView *postView;
@property (nonatomic) CGPoint postCenter;
@property (nonatomic) int postIndex;
@end

@implementation PostListViewController

# pragma properties

- (APIClient *)sharedAPIClient
{
    if (!_sharedAPIClient) _sharedAPIClient = [APIClient sharedAPIClient];

    return _sharedAPIClient;
}

- (int)postIndex
{
    if (!_postIndex) _postIndex = 0;
    
    return _postIndex;
}

# pragma rendering

- (void)loadPosts
{
    [self loadPostsWithParams:@{@"start":@"0"}
                      success:^(NSArray *results) {
                          _posts = [[NSMutableArray alloc] initWithArray:results];
                          [self startFirstView];
                      }];
}

- (void)loadPostsWithParams:(NSDictionary *)queryParams success:(void (^)(NSArray *results))success
{
    NSMutableDictionary *defaultParams = [[NSMutableDictionary alloc] initWithDictionary:@{@"starters":@"true",
                                                                                           @"hasImages":@"true",
                                                                                           @"domain":@"gawker.com",
                                                                                           @"domain":@"jezebel.com",
                                                                                           @"domain":@"gizmodo.com",
                                                                                           @"domain":@"deadspin.com",
                                                                                           @"domain":@"lifehacker.com",
                                                                                           @"domain":@"io9.com",
                                                                                           @"domain":@"kotaku.com"}];
    [defaultParams addEntriesFromDictionary:queryParams];
    
    [self.activitySpinner startAnimating];
    [self.sharedAPIClient searchPostsWith:defaultParams
                                  success:success
                                  failure:^{
                                      NSLog(@"%@", @"failure");
                                  }];
}

- (void)startFirstView
{
    [self.activitySpinner stopAnimating];
    [self queueNextPost];
    [self renderControls];
}

#define POSTSIZE 300
#define CONTROL_MARGIN 20
#define CONTROL_SIZE 100

- (void)renderCurrentPost
{
    Post *post = self.posts[self.postIndex];
    self.postView = [[PostItemView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - POSTSIZE) / 2, (self.view.frame.size.height - POSTSIZE - CONTROL_SIZE - CONTROL_MARGIN) / 2, POSTSIZE, POSTSIZE)
                                               withPost:post];
    [self.view addSubview:self.postView];
    self.postCenter = self.postView.center;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapPost:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(panPost:)];
    
    [self.postView addGestureRecognizer:tap];
    [self.postView addGestureRecognizer:pan];
    
    // Asynchronously download image and render post
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(aQueue, ^{
        [self.postView downloadPostImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.postView renderCardView];
        });
    });
}

- (void)queueNextPost
{
    NSUInteger postQueueCount = [self.posts count];
    void (^getPosts)() = ^{
        [self loadPostsWithParams:@{@"start": [NSString stringWithFormat:@"%li", postQueueCount]}
                          success:^(NSArray *results) {
                              for (Post *post in results) {
                                  if (![_posts containsObject:post]) {
                                      [_posts addObject:post];
                                  }
                              }
                          }];
    };
    
    if (![self.posts count] || self.postIndex == (postQueueCount - 1)) {
        postQueueCount += [self.sharedAPIClient getArticleCount];
        getPosts();
    } else if (self.postIndex >= [self.posts count] - 5) {
        // Update queue of posts
        dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(aQueue, ^{
            getPosts();
        });
    }
    
    [self renderCurrentPost];
    self.postIndex += 1;
}

- (void)renderControls
{
    float postCenterOffset = POSTSIZE / 2;
    float controlDismissX = self.postCenter.x - postCenterOffset;
    float controlKeepX = self.postCenter.x + postCenterOffset - CONTROL_SIZE;
    float controlY = self.postCenter.y + postCenterOffset + CONTROL_MARGIN;
    UIButton *dismiss = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *keep = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    dismiss.frame = CGRectMake(controlDismissX, controlY, CONTROL_SIZE, CONTROL_SIZE);
    keep.frame = CGRectMake(controlKeepX, controlY, CONTROL_SIZE, CONTROL_SIZE);
    
    [dismiss setImage:[UIImage imageNamed:@"close2"] forState:UIControlStateNormal];
    [keep setImage:[UIImage imageNamed:@"fire14"] forState:UIControlStateNormal];
    [dismiss addTarget:self
               action:@selector(touchDismissButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [keep addTarget:self
               action:@selector(touchKeepButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *button in [[NSArray alloc] initWithObjects:keep, dismiss, nil]) {
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [UIColor grayColor].CGColor;
        button.layer.cornerRadius = CONTROL_SIZE / 2;
    }

    [self.view addSubview:dismiss];
    [self.view addSubview:keep];
}

- (void)animateView:(PostItemView *)view toPoint:(CGPoint)point andReplace:(BOOL)queuePost
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                        view.center = point;
                         
                         if (queuePost) {
                             [self queueNextPost];
                         }
                     }
                     completion:^(BOOL complete){
                         if (complete && queuePost) {
                             [view removeFromSuperview];
                         }
                     }];
}

# pragma gestures

- (void)touchDismissButton:(UIButton *)sender
{
    [self.sharedAPIClient savePost:self.postView.post asKept:NO];
    [self animateView:self.postView
              toPoint:CGPointMake(0 - self.view.frame.size.width + (self.postView.frame.size.width / 2), self.postView.center.y + 100)
           andReplace:YES];
}

- (void)touchKeepButton:(UIButton *)sender
{
    [self.sharedAPIClient savePost:self.postView.post asKept:YES];
    [self animateView:self.postView
              toPoint:CGPointMake(self.view.frame.size.width + (self.postView.frame.size.width / 2), self.postView.center.y + 100)
           andReplace:YES];
}

#define PAN_BREAKPOINT 75

- (void)panPost:(UIPanGestureRecognizer *)sender
{
    PostItemView *targetView = (PostItemView *)sender.view;
    CGPoint translation = [sender translationInView:targetView];
    float xDifference = self.postCenter.x - (sender.view.center.x + translation.x);
    float newY = sender.view.center.y + translation.y;
    
    targetView.center = CGPointMake(sender.view.center.x + translation.x, newY);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint newPoint;
        BOOL queuePost = YES;
        
        if (xDifference > PAN_BREAKPOINT) {
            [self.sharedAPIClient savePost:self.postView.post asKept:NO];
            newPoint = CGPointMake(0 - self.view.frame.size.width + (targetView.frame.size.width / 2), self.postView.center.y + PAN_BREAKPOINT);
        } else if (xDifference < (-1 * PAN_BREAKPOINT)) {
            [self.sharedAPIClient savePost:self.postView.post asKept:YES];
            newPoint = CGPointMake(self.view.frame.size.width + (targetView.frame.size.width / 2), self.postView.center.y + PAN_BREAKPOINT);
        } else {
            newPoint = self.postCenter;
            queuePost = NO;
        }
        
        [self animateView:targetView
                  toPoint:newPoint
               andReplace:queuePost];
    }

    [sender setTranslation:CGPointMake(0, 0) inView:targetView];
}

- (void)tapPost:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        PostItemView *targetView = (PostItemView *)sender.view;
        NSPredicate *findPostId = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            Post *targetPost = (Post *)evaluatedObject;
            return targetPost.postId == targetView.post.postId;
        }];
        NSArray *filteredPosts = [self.posts filteredArrayUsingPredicate:findPostId];
        
        if ([filteredPosts count]) {
            PostDetailViewController *destinationVc = [[PostDetailViewController alloc] init];
            destinationVc.post = filteredPosts[0];
            destinationVc.postImage = [targetView downloadPostImage];
            [self.navigationController pushViewController:destinationVc animated:YES];
        }
    }
}

# pragma initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.activitySpinner.hidesWhenStopped = true;
    
    // Custom Logo
    UIImage *kindrLogo = [UIImage imageNamed:@"kindr_logo.png"];
    UIImageView *kindrImageView = [[UIImageView alloc] initWithImage:kindrLogo];
    kindrImageView.contentMode = UIViewContentModeScaleAspectFit;
    kindrImageView.clipsToBounds = YES;
    kindrImageView.frame = CGRectMake(0, 0, kindrImageView.superview.frame.size.width, 45);
    [self.navigationItem setTitleView:kindrImageView];
    
    // Render kindr
    [self.sharedAPIClient deleteUnkeptPosts];
    [self loadPosts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

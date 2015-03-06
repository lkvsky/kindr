//
//  SavedPostViewController.m
//  Kindr
//
//  Created by Kyle Lucovsky on 3/2/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "SavedPostViewController.h"
#import "APIClient.h"
#import "Post.h"
#import "PostItemView.h"
#import "PostDetailViewController.h"

@interface SavedPostViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) APIClient *sharedAPIClient;
@property BOOL hasAppeared;
@end

@implementation SavedPostViewController

#pragma properties

- (APIClient *)sharedAPIClient
{
    if (!_sharedAPIClient) _sharedAPIClient = [APIClient sharedAPIClient];
    
    return _sharedAPIClient;
}

#pragma rendering

#define POST_WIDTH 320
#define POST_HEIGHT 100
#define POST_MARGIN 10

- (void)loadPosts
{
    NSMutableArray *keptPosts = [[NSMutableArray alloc] initWithArray:[self.sharedAPIClient getKeptPosts]];
    
    if (!keptPosts) {
        _posts = [[NSMutableArray alloc] init];
    } else {
        _posts = keptPosts;
    }
}

- (void)renderPostList
{
    float yValue = POST_MARGIN;
    
    for (Post *post in self.posts) {
        [self addPostToList:post atYValue:yValue];
        yValue += (POST_MARGIN + POST_HEIGHT);
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, yValue);
}

- (void)translatePostList
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         float yValue = POST_MARGIN;
                         float postWidth = self.view.frame.size.width - (POST_MARGIN * 2);
                         
                         for (PostItemView *postView in self.scrollView.subviews) {
                             if ([postView isKindOfClass:[PostItemView class]]) {
                                 postView.frame = CGRectMake((self.view.frame.size.width - postWidth) / 2, yValue, postWidth, POST_HEIGHT);
                                 yValue += (POST_MARGIN + POST_HEIGHT);
                             }
                         }
                         
                         self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, yValue);
                     }];
}

- (void)addPostToList:(Post *)post atYValue:(float)yValue
{
    float postWidth = self.view.frame.size.width - (POST_MARGIN * 2);
    PostItemView *postView = [[PostItemView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - postWidth) / 2, yValue, postWidth, POST_HEIGHT)
                                                        withPost:post];

    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(aQueue, ^{
        [postView downloadPostImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [postView renderFeedView];
        });
    });
    
    [self.scrollView addSubview:postView];
}

#pragma events

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)tapPost:(NSNotification *)notification
{
    PostItemView *targetView = (PostItemView *)notification.object;
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

- (void)tapDeletePost:(NSNotification *)notification
{
    PostItemView *targetView = (PostItemView *)notification.object;
    NSPredicate *findPostId = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Post *targetPost = (Post *)evaluatedObject;
        return targetPost.postId == targetView.post.postId;
    }];
    NSArray *filteredPosts = [self.posts filteredArrayUsingPredicate:findPostId];
    
    if ([filteredPosts count]) {
        Post *deletedPost = filteredPosts[0];
        [self.posts removeObject:deletedPost];
        [UIView animateWithDuration:0.3
                         animations:^{
                             targetView.layer.opacity = 0;
                         }
                         completion:^(BOOL finished) {
                             [targetView removeFromSuperview];
                             [self.sharedAPIClient savePost:deletedPost asKept:NO];
                             [self translatePostList];
                         }];
    }
}

#pragma initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Custom Logo
    UIImage *kindrLogo = [UIImage imageNamed:@"kindr_logo.png"];
    UIImageView *kindrImageView = [[UIImageView alloc] initWithImage:kindrLogo];
    kindrImageView.contentMode = UIViewContentModeScaleAspectFit;
    kindrImageView.clipsToBounds = YES;
    kindrImageView.frame = CGRectMake(0, 0, kindrImageView.superview.frame.size.width, 45);
    [self.navigationItem setTitleView:kindrImageView];
    
    // Post list setup
    self.scrollView.delegate = self;
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tapDeletePost:)
                                                 name:@"TapDelete"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tapPost:)
                                                 name:@"TapPost"
                                               object:nil];
    
    [self loadPosts];
    [self renderPostList];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.hasAppeared) {
        NSArray *keptPosts = [self.sharedAPIClient getKeptPosts];
        float yValue = self.scrollView.contentSize.height;
        
        for (Post *post in keptPosts) {
            if (![self.posts containsObject:post]) {
                [self.posts addObject:post];
                [self addPostToList:post atYValue:yValue];
                yValue += (POST_MARGIN + POST_HEIGHT);
            }
        }
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, yValue);
    } else {
        self.hasAppeared = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

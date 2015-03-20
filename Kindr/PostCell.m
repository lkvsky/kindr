//
//  PostCell.m
//  Kindr
//
//  Created by Kyle Lucovsky on 3/16/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "PostCell.h"
#import "ImageHelper.h"

@interface PostCell () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *headlineView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) NSString *postId;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (nonatomic) BOOL isOpen;
@end

@implementation PostCell

#pragma mark - Events

- (IBAction)deleteButtonTapped:(id)sender
{
    [self.delegate tapDelete:self.postId];
}

- (void)swipePost:(UISwipeGestureRecognizer *)sender
{
    CGFloat deleteButtonOffset = CGRectGetWidth(self.deleteButton.frame);
    
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft && !self.isOpen) {
        self.rightConstraint.constant += deleteButtonOffset;
        self.leftConstraint.constant -= deleteButtonOffset;
        self.isOpen = YES;
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight && self.isOpen) {
        self.rightConstraint.constant -= CGRectGetWidth(self.deleteButton.frame);
        self.leftConstraint.constant += CGRectGetWidth(self.deleteButton.frame);
        self.isOpen = NO;
    }
    
    [self setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.125
                     animations:^{
                         [self layoutIfNeeded];
                     }];
}

#pragma mark - Initialization

- (void)layoutSubviews
{
    // delete button customization
    CAGradientLayer *gradient = [CAGradientLayer layer];
    NSArray *colors = @[(id)[UIColor colorWithRed:254.0/255.0 green:111.0/255.0 blue:32.0/255.0 alpha:1.0].CGColor, (id)[UIColor colorWithRed:211.0/255.0 green:65.0/255.0 blue:50.0/255.0 alpha:1.0].CGColor];
    gradient.colors = colors;
    gradient.frame = self.deleteButton.bounds;
    [self.deleteButton.layer insertSublayer:gradient atIndex:0];
    [self.deleteButton bringSubviewToFront:self.deleteButton.imageView];
    [self.deleteButton.imageView setTintColor:[UIColor whiteColor]];
    
    // set shadow
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 0.25;
    self.layer.shadowOffset = CGSizeMake(0, 0.5);
    CGRect shadowFrame = self.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    self.layer.shadowPath = shadowPath;
}

- (void)configureWithPost:(Post *)post
{
    if (post.images && [post.images count] > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            UIImage *image = [[ImageHelper sharedInstance] getImageWithUrl:post.images[0]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.thumbnailView.image = image;
            });
        });
    }
    
    self.headlineView.text = post.headline;
    self.postId = post.postId;
}

- (void)awakeFromNib {
    // Initialization code
    self.layer.masksToBounds = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.layoutMargins = UIEdgeInsetsMake(5, 5, 5, 5);
    
    // Add gesture recognizers
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePost:)];;
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePost:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    leftSwipe.delegate = self;
    rightSwipe.delegate = self;
    [self.containerView addGestureRecognizer:leftSwipe];
    [self.containerView addGestureRecognizer:rightSwipe];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (self.selected) {
        CALayer *transparentLayer = [CALayer layer];
        transparentLayer.backgroundColor = [UIColor whiteColor].CGColor;
        transparentLayer.opacity = 0.4;
        transparentLayer.frame = self.bounds;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.layer.mask = transparentLayer;
        }];
    } else {
        self.layer.mask = nil;
    }
}

- (void)setFrame:(CGRect)frame {
    frame.origin.y += 8;
    frame.size.height -= 2 * 4;
    frame.origin.x += 8;
    frame.size.width -= 2 * 8;
    [super setFrame:frame];
}

@end

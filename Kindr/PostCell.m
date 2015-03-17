//
//  PostCell.m
//  Kindr
//
//  Created by Kyle Lucovsky on 3/16/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "PostCell.h"

@interface PostCell ()
@end

@implementation PostCell

- (void)configureWithPost:(Post *)post
{
    UIView *container = [[UIView alloc] initWithFrame:self.frame];
    UIImageView *imageView = [[UIImageView alloc] init];
    container.clipsToBounds = YES;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = container.bounds;
    gradient.startPoint = CGPointMake(0.0, 0.4);
    gradient.endPoint = CGPointMake(0.0, 1.0);
    gradient.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor];

    if (post.images && [post.images count] > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            NSMutableString *imageUrlString = [[NSMutableString alloc] initWithString:@"http://i.kinja-img.com/gawker-media/image/upload/"];
            [imageUrlString appendString:post.images[0]];
            NSData *imageData = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:imageUrlString]];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            float aspectRatio = image.size.height / image.size.width;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
                imageView.frame = CGRectMake(0, 0, self.frame.size.width, image.size.height * aspectRatio);
                [container addSubview:imageView];
                [imageView.layer insertSublayer:gradient above:0];
                [self setBackgroundView:container];
            });
        });
    }
    
    self.textLabel.text = post.headline;
}

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = nil;
    self.opaque = NO;
    self.textLabel.textColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.center = CGPointMake(self.center.x, self.frame.size.height - 20);
}

- (void)prepareForReuse
{
    self.backgroundView = nil;
}

@end

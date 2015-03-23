//
//  KindrButton.m
//  Kindr
//
//  Created by Kyle Lucovsky on 3/23/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "KindrButton.h"

@implementation KindrButton

- (instancetype)initWithImage:(UIImage *)imageIcon withTintColor:(UIColor *)color withFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setImage:imageIcon forState:UIControlStateNormal];
    self.imageView.tintColor = color;
    [self render];
    
    return self;
}

- (void)render
{
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.layer.bounds cornerRadius:50.0].CGPath;
    self.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    self.layer.borderWidth = 5.0;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = 50.0;
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 0.25;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowRadius = 2.0;
    self.layer.shadowPath = shadowPath;
}

@end

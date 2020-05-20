//
//  UIView+CFFrame.m
//  NOteDropDownMenuView
//
//  Created by Peak on 16/5/28.
//  Copyright © 2016年 陈峰. All rights reserved.
//

#import "UIView+CFFrame.h"

@implementation UIView (CFFramen)

//---------- X ----------//
- (void)setCf_xn:(CGFloat)cf_x {
    CGRect frame = self.frame;
    frame.origin.x = cf_x;
    self.frame = frame;
}

- (CGFloat)cf_xn {
    return self.frame.origin.x;
}

//---------- Y ----------//
- (void)setCf_yn:(CGFloat)cf_y {
    CGRect frame = self.frame;
    frame.origin.y = cf_y;
    self.frame = frame;
}

- (CGFloat)cf_yn {
    return self.frame.origin.y;
}

//---------- CenterX ----------//
- (void)setCf_centerXn:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)cf_centerXn {
    return self.center.x;
}

//---------- CenterY ----------//
- (void)setCf_centerYn:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)cf_centerYn {
    return self.center.y;
}

//---------- Width ----------//
- (void)setCf_widthn:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)cf_widthn {
    return self.frame.size.width;
}

//---------- Height ----------//
- (void)setCf_heightn:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)cf_heightn {
    return self.frame.size.height;
}

//---------- Origin ----------//
- (void)setCf_originn:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)cf_originn {
    return self.frame.origin;
}

//---------- Size ----------//
- (void)setCf_sizen:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)cf_sizen {
    return self.frame.size;
}

- (CGFloat)cf_maxXn {
    return self.frame.size.width + self.frame.origin.x;
}

- (CGFloat)cf_maxYn {
    return self.frame.size.height + self.frame.origin.y;
}


+ (instancetype)viewWithXnote:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height
{
    return [[self alloc] initWithFrame:CGRectMake(x, y, width, height)];
}

+ (instancetype)viewWithFrame:(CGRect)frame
{
    return [[UIView alloc] initWithFrame:frame];
}

+ (instancetype)viewWithFrame:(CGRect)frame backgroundColor:(UIColor *)color
{
    UIView *view = [self viewWithFrame:frame];
    view.backgroundColor = color;
    return view;
}

@end

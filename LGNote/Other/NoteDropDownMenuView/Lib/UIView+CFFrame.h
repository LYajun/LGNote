//
//  UIView+CFFrame.h
//  NOteDropDownMenuView
//
//  Created by Peak on 16/5/28.
//  Copyright © 2016年 陈峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CFFramen)

@property (nonatomic, assign) CGFloat cf_xn;
@property (nonatomic, assign) CGFloat cf_yn;
@property (nonatomic, assign) CGFloat cf_centerXn;
@property (nonatomic, assign) CGFloat cf_centerYn;
@property (nonatomic, assign) CGFloat cf_widthn;
@property (nonatomic, assign) CGFloat cf_heightn;

@property (nonatomic, assign, readonly) CGFloat cf_maxXn;
@property (nonatomic, assign, readonly) CGFloat cf_maxYn;

@property (nonatomic, assign) CGPoint cf_originn;
@property (nonatomic, assign) CGSize cf_sizen;

+ (instancetype)viewWithXnote:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;
+ (instancetype)viewWithFrame:(CGRect)frame;
+ (instancetype)viewWithFrame:(CGRect)frame backgroundColor:(UIColor *)color;

@end

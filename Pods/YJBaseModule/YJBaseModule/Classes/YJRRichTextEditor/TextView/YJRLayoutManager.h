//
//  YJRLayoutManager.h
//
//  Version 0.2.0
//
//  Created by Illya Busigin on 01/05/2014.
//  Copyright (c) 2014 Cyrillian, Inc.
//
//  Distributed under MIT license.
//  Get the latest version from here:
//


#import <UIKit/UIKit.h>

@interface YJRLayoutManager : NSLayoutManager

@property (nonatomic, strong) UIFont *lineNumberFont;
@property (nonatomic, strong) UIColor *lineNumberColor;

@property (nonatomic, readonly) CGFloat gutterWidth;
@property (nonatomic, assign) NSRange selectedRange;

- (CGRect)paragraphRectForRange:(NSRange)range;

@end

//
//  YJRTextStorage.h
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

@interface YJRTextStorage : NSTextStorage

@property (nonatomic, strong) NSArray *tokens;
@property (nonatomic, strong) UIFont *defaultFont;

- (void)update;

@end

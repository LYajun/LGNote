//
//  YJRTextView.h
//
//  Version 0.2.0
//
//  Created by Illya Busigin on 01/05/2014.
//  Copyright (c) 2014 Cyrillian, Inc.
//  Copyright (c) 2013 Dominik Hauser
//  Copyright (c) 2013 Sam Rijs
//


#import <UIKit/UIKit.h>
#import "YJRToken.h"

@interface YJRTextView : UITextView

@property (nonatomic, strong) NSArray *tokens;
@property (nonatomic, strong) UIPanGestureRecognizer *singleFingerPanRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *doubleFingerPanRecognizer;

@property UIColor *gutterBackgroundColor;
@property UIColor *gutterLineColor;

@property (nonatomic, assign) BOOL lineCursorEnabled;

@end

//
//  YJRTextView.m
//
//  Version 0.2.0
//
//  Created by Illya Busigin on 01/05/2014.
//  Copyright (c) 2014 Cyrillian, Inc.
//  Copyright (c) 2013 Dominik Hauser
//  Copyright (c) 2013 Sam Rijs
//

#import "YJRTextView.h"
#import "YJRLayoutManager.h"
#import "YJRTextStorage.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]

static void *YJRTextViewContext = &YJRTextViewContext;
static const float kCursorVelocity = 1.0f/8.0f;

@interface YJRTextView ()

@property (nonatomic, strong) YJRLayoutManager *lineNumberLayoutManager;
@property (nonatomic, strong) YJRTextStorage *syntaxTextStorage;

@end

@implementation YJRTextView
{
    NSRange startRange;
}

#pragma mark - Initialization & Setup

- (id)initWithFrame:(CGRect)frame
{
    YJRTextStorage *textStorage = [YJRTextStorage new];
    YJRLayoutManager *layoutManager = [YJRLayoutManager new];
    
    self.lineNumberLayoutManager = layoutManager;
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    //  Wrap text to the text view's frame
    textContainer.widthTracksTextView = YES;
    
    [layoutManager addTextContainer:textContainer];

    [textStorage removeLayoutManager:textStorage.layoutManagers.firstObject];
    [textStorage addLayoutManager:layoutManager];
    
    self.syntaxTextStorage = textStorage;
    
    if ((self = [super initWithFrame:frame textContainer:textContainer]))
    {
        self.contentMode = UIViewContentModeRedraw; // causes drawRect: to be called on frame resizing and device rotation
        
        [self _commonSetup];
    }
    
    return self;
}

- (void)_commonSetup
{
    // Setup observers
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(font)) options:NSKeyValueObservingOptionNew context:YJRTextViewContext];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedTextRange)) options:NSKeyValueObservingOptionNew context:YJRTextViewContext];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedRange)) options:NSKeyValueObservingOptionNew context:YJRTextViewContext];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextViewDidChangeNotification:) name:UITextViewTextDidChangeNotification object:self];
    
    // Setup defaults
    self.font = [UIFont systemFontOfSize:16.0f];
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType     = UITextAutocorrectionTypeNo;
    self.lineCursorEnabled = YES;
    self.gutterBackgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.gutterLineColor       = [UIColor lightGrayColor];
    
    // Inset the content to make room for line numbers
    self.textContainerInset = UIEdgeInsetsMake(8, self.lineNumberLayoutManager.gutterWidth, 8, 0);
    
    // Setup the gesture recognizers
    _singleFingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singleFingerPanHappend:)];
    _singleFingerPanRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:_singleFingerPanRecognizer];
    
    _doubleFingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doubleFingerPanHappend:)];
    _doubleFingerPanRecognizer.minimumNumberOfTouches = 2;
    [self addGestureRecognizer:_doubleFingerPanRecognizer];
}


#pragma mark - Cleanup

- (void)dealloc
{
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(font))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedTextRange))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedRange))];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(font))] && context == YJRTextViewContext)
    {
        // Whenever the UITextView font is changed we want to keep a reference in the stickyFont ivar. We do this to counteract a bug where the underlying font can be changed without notice and cause undesired behaviour.
        self.syntaxTextStorage.defaultFont = self.font;
    }
    else if (([keyPath isEqualToString:NSStringFromSelector(@selector(selectedTextRange))] ||
              [keyPath isEqualToString:NSStringFromSelector(@selector(selectedRange))]) && context == YJRTextViewContext)
    {
        [self setNeedsDisplay];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - Notifications

- (void)handleTextViewDidChangeNotification:(NSNotification *)notification
{
    if (notification.object == self)
    {
        CGRect line = [self caretRectForPosition: self.selectedTextRange.start];
        CGFloat overflow = line.origin.y + line.size.height - ( self.contentOffset.y + self.bounds.size.height - self.contentInset.bottom - self.contentInset.top );
        
        if ( overflow > 0 )
        {
            // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
            // Scroll caret to visible area
            CGPoint offset = self.contentOffset;
            offset.y += overflow + 7; // leave 7 pixels margin
            // Cannot animate with setContentOffset:animated: or caret will not appear
//            [UIView animateWithDuration:.2 animations:^{
//                [self setContentOffset:offset];
//            }];
        }
    }
}


#pragma mark - Overrides

- (void)setTokens:(NSMutableArray *)tokens
{
    [self.syntaxTextStorage setTokens:tokens];
}

- (NSArray *)tokens
{
    YJRTextStorage *syntaxTextStorage = (YJRTextStorage *)self.textStorage;
    
    return syntaxTextStorage.tokens;
}

- (void)setText:(NSString *)text
{
    UITextRange *textRange = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self replaceRange:textRange withText:text];
}


#pragma mark - Line Drawing

// Original implementation sourced from: https://github.com/alldritt/TextKit_LineNumbers
- (void)drawRect:(CGRect)rect
{
    //  Drag the line number gutter background.  The line numbers them selves are drawn by LineNumberLayoutManager.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    
    CGFloat height = MAX(CGRectGetHeight(bounds), self.contentSize.height) + 200;
    
    // Set the regular fill
    CGContextSetFillColorWithColor(context, self.gutterBackgroundColor.CGColor);
    CGContextFillRect(context, CGRectMake(bounds.origin.x, bounds.origin.y, self.lineNumberLayoutManager.gutterWidth, height));
    
    // Draw line
    CGContextSetFillColorWithColor(context, self.gutterLineColor.CGColor);
    CGContextFillRect(context, CGRectMake(self.lineNumberLayoutManager.gutterWidth, bounds.origin.y, 0.5, height));
    
    if (_lineCursorEnabled)
    {
        self.lineNumberLayoutManager.selectedRange = self.selectedRange;
        
        NSRange glyphRange = [self.lineNumberLayoutManager.textStorage.string paragraphRangeForRange:self.selectedRange];
        glyphRange = [self.lineNumberLayoutManager glyphRangeForCharacterRange:glyphRange actualCharacterRange:NULL];
        self.lineNumberLayoutManager.selectedRange = glyphRange;
        [self.lineNumberLayoutManager invalidateDisplayForGlyphRange:glyphRange];
    }
    
    [super drawRect:rect];
}


#pragma mark - Gestures

// Sourced from: https://github.com/srijs/NLTextView
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Only accept horizontal pans for the code navigation to preserve correct scrolling behaviour.
    if (gestureRecognizer == _singleFingerPanRecognizer || gestureRecognizer == _doubleFingerPanRecognizer)
    {
        CGPoint translation = [gestureRecognizer translationInView:self];
        
        float translationX = (float)translation.x;
        float translationY = (float)translation.y;
        
        return fabsf(translationX) > fabsf(translationY);
    }
    
    return YES;
    
}

// Sourced from: https://github.com/srijs/NLTextView
- (void)singleFingerPanHappend:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        startRange = self.selectedRange;
    }
    
    CGFloat cursorLocation = MAX(startRange.location + [sender translationInView:self].x * kCursorVelocity, 0);
    
    self.selectedRange = NSMakeRange(cursorLocation, 0);
}

// Sourced from: https://github.com/srijs/NLTextView
- (void)doubleFingerPanHappend:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        startRange = self.selectedRange;
    }
    
    CGFloat cursorLocation = MAX(startRange.location + [sender translationInView:self].x * kCursorVelocity, 0);
    
    float location = startRange.location - cursorLocation;
    
    if (cursorLocation > startRange.location)
    {
        self.selectedRange = NSMakeRange(startRange.location, fabsf(location));
    }
    else
    {
        self.selectedRange = NSMakeRange(cursorLocation, fabsf(location));
    }
}

@end

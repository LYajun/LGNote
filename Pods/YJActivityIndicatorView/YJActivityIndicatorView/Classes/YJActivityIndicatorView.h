//
//  YJActivityIndicatorView.h
//
//
//  Created by Danil Gontovnik on 5/23/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YJActivityIndicatorAnimationType) {
    YJActivityIndicatorAnimationTypeNineDots,
    YJActivityIndicatorAnimationTypeTriplePulse,
    YJActivityIndicatorAnimationTypeFiveDots,
    YJActivityIndicatorAnimationTypeRotatingSquares,
    YJActivityIndicatorAnimationTypeDoubleBounce,
    YJActivityIndicatorAnimationTypeTwoDots,
    YJActivityIndicatorAnimationTypeThreeDots,
    YJActivityIndicatorAnimationTypeBallPulse,
    YJActivityIndicatorAnimationTypeBallClipRotate,
    YJActivityIndicatorAnimationTypeBallClipRotatePulse,
    YJActivityIndicatorAnimationTypeBallClipRotateMultiple,
    YJActivityIndicatorAnimationTypeBallRotate,
    YJActivityIndicatorAnimationTypeBallZigZag,
    YJActivityIndicatorAnimationTypeBallZigZagDeflect,
    YJActivityIndicatorAnimationTypeBallTrianglePath,
    YJActivityIndicatorAnimationTypeBallScale,
    YJActivityIndicatorAnimationTypeLineScale,
    YJActivityIndicatorAnimationTypeLineScaleParty,
    YJActivityIndicatorAnimationTypeBallScaleMultiple,
    YJActivityIndicatorAnimationTypeBallPulseSync,
    YJActivityIndicatorAnimationTypeBallBeat,
    YJActivityIndicatorAnimationTypeLineScalePulseOut,
    YJActivityIndicatorAnimationTypeLineScalePulseOutRapid,
    YJActivityIndicatorAnimationTypeBallScaleRipple,
    YJActivityIndicatorAnimationTypeBallScaleRippleMultiple,
    YJActivityIndicatorAnimationTypeTriangleSkewSpin,
    YJActivityIndicatorAnimationTypeBalLGridBeat,
    YJActivityIndicatorAnimationTypeBalLGridPulse,
    YJActivityIndicatorAnimationTypeRotatingSandglass,
    YJActivityIndicatorAnimationTypeRotatingTrigons,
    YJActivityIndicatorAnimationTypeTripleRings,
    YJActivityIndicatorAnimationTypeCookieTerminator,
    YJActivityIndicatorAnimationTypeBallSpinFadeLoader
};

@interface YJActivityIndicatorView : UIView

- (id)initWithType:(YJActivityIndicatorAnimationType)type;
- (id)initWithType:(YJActivityIndicatorAnimationType)type tintColor:(UIColor *)tintColor;
- (id)initWithType:(YJActivityIndicatorAnimationType)type tintColor:(UIColor *)tintColor size:(CGFloat)size;

@property (nonatomic) YJActivityIndicatorAnimationType type;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic) CGFloat size;

@property (nonatomic, readonly) BOOL animating;

- (void)startAnimating;
- (void)stopAnimating;

@end

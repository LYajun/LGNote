//
//  UIView+YJ.m
//  YJExtensionsDemo
//
//  Created by 刘亚军 on 2019/3/14.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "UIView+YJ.h"
#import <objc/runtime.h>


@implementation UIView (YJ)
#pragma mark - 渐变色
+ (Class)layerClass {
    return [CAGradientLayer class];
}
+ (UIView *)yj_gradientViewWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
    UIView *view = [[self alloc] init];
    [view yj_setGradientBackgroundWithColors:colors locations:locations startPoint:startPoint endPoint:endPoint];
    return view;
}
- (void)yj_setGradientBackgroundWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
    NSMutableArray *colorsM = [NSMutableArray array];
    for (UIColor *color in colors) {
        [colorsM addObject:(__bridge id)color.CGColor];
    }
    self.colors = [colorsM copy];
    self.locations = locations;
    self.startPoint = startPoint;
    self.endPoint = endPoint;
}
- (NSArray *)colors {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setColors:(NSArray *)colors {
    objc_setAssociatedObject(self, @selector(colors), colors, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setColors:self.colors];
    }
}

- (NSArray<NSNumber *> *)locations {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLocations:(NSArray<NSNumber *> *)locations {
    objc_setAssociatedObject(self, @selector(locations), locations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setLocations:self.locations];
    }
}

- (CGPoint)startPoint {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

- (void)setStartPoint:(CGPoint)startPoint {
    objc_setAssociatedObject(self, @selector(startPoint), [NSValue valueWithCGPoint:startPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setStartPoint:self.startPoint];
    }
}

- (CGPoint)endPoint {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

- (void)setEndPoint:(CGPoint)endPoint {
    objc_setAssociatedObject(self, @selector(endPoint), [NSValue valueWithCGPoint:endPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setEndPoint:self.endPoint];
    }
}
#pragma mark - UIView处理
- (void)yj_clipLayerWithRadius:(CGFloat)r width:(CGFloat)w color:(UIColor *)color{
    self.layer.cornerRadius = r;
    self.layer.borderWidth = w;
    self.layer.borderColor = color.CGColor;
    self.layer.masksToBounds = YES;
}

- (void)yj_shadowWithWidth:(CGFloat)width borderColor:(UIColor *)borderColor opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset{
    self.layer.borderWidth = width;
    self.layer.borderColor = borderColor.CGColor;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
    self.layer.shadowOffset = offset;
}
#pragma mark - Shake
- (void)yj_shake {
    [self _yj_shake:10 direction:1 currentTimes:0 withDelta:5 speed:0.03 shakeDirection:YJShakeDirectionHorizontal completion:nil];
}

- (void)yj_shake:(int)times withDelta:(CGFloat)delta {
    [self _yj_shake:times direction:1 currentTimes:0 withDelta:delta speed:0.03 shakeDirection:YJShakeDirectionHorizontal completion:nil];
}

- (void)yj_shake:(int)times withDelta:(CGFloat)delta completion:(void(^)(void))handler {
    [self _yj_shake:times direction:1 currentTimes:0 withDelta:delta speed:0.03 shakeDirection:YJShakeDirectionHorizontal completion:handler];
}

- (void)yj_shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval {
    [self _yj_shake:times direction:1 currentTimes:0 withDelta:delta speed:interval shakeDirection:YJShakeDirectionHorizontal completion:nil];
}

- (void)yj_shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval completion:(void(^)(void))handler {
    [self _yj_shake:times direction:1 currentTimes:0 withDelta:delta speed:interval shakeDirection:YJShakeDirectionHorizontal completion:handler];
}

- (void)yj_shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(YJShakeDirection)shakeDirection {
    [self _yj_shake:times direction:1 currentTimes:0 withDelta:delta speed:interval shakeDirection:shakeDirection completion:nil];
}

- (void)yj_shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(YJShakeDirection)shakeDirection completion:(void (^)(void))completion {
    [self _yj_shake:times direction:1 currentTimes:0 withDelta:delta speed:interval shakeDirection:shakeDirection completion:completion];
}

- (void)_yj_shake:(int)times direction:(int)direction currentTimes:(int)current withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(YJShakeDirection)shakeDirection completion:(void (^)(void))completionHandler {
    [UIView animateWithDuration:interval animations:^{
        self.layer.affineTransform = (shakeDirection == YJShakeDirectionHorizontal) ? CGAffineTransformMakeTranslation(delta * direction, 0) : CGAffineTransformMakeTranslation(0, delta * direction);
    } completion:^(BOOL finished) {
        if(current >= times) {
            [UIView animateWithDuration:interval animations:^{
                self.layer.affineTransform = CGAffineTransformIdentity;
            } completion:^(BOOL finished){
                if (completionHandler != nil) {
                    completionHandler();
                }
            }];
            return;
        }
        [self _yj_shake:(times - 1)
              direction:direction * -1
           currentTimes:current + 1
              withDelta:delta
                  speed:interval
         shakeDirection:shakeDirection
             completion:completionHandler];
    }];
}
#pragma mark - Frame
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}


- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (BOOL)yj_isIPhoneX{
    if ((MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 375 &&
         MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 812)) {
        return YES;
    }
    return NO;
}
- (CGFloat)yj_stateBarSpace{
     return ([self yj_isIPhoneX] ? 24 : 0);
}
- (CGFloat)yj_tabBarSpace{
    return ([self yj_isIPhoneX] ? 34 : 0);
}
- (CGFloat)yj_customNavBarHeight{
    return ([self yj_isIPhoneX] ? 88 : 64);
}
- (CGFloat)yj_customTabBarHeight{
    return ([self yj_isIPhoneX] ? 83 : 49);
}
@end


@implementation UILabel (YJ)

+ (Class)layerClass {
    return [CAGradientLayer class];
}

@end

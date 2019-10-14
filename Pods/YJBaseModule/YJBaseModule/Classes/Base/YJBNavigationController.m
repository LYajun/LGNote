//
//  YJBNavigationController.m
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/7/24.
//

#import "YJBNavigationController.h"

@interface YJBNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation YJBNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackPopGesture];
}
- (void)setBackPopGesture{
    // 获取系统自带滑动手势的target对象
    id target = self.interactivePopGestureRecognizer.delegate;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
    self.backGesture = [[UIPanGestureRecognizer alloc] initWithTarget:target action:NSSelectorFromString(@"handleNavigationTransition:")];
#pragma clang diagnostic pop
    // 设置手势代理，拦截手势触发
    self.backGesture.delegate = self;
    // 给导航控制器的view添加全屏滑动手势
    [self.view addGestureRecognizer:self.backGesture];
    
    

}


// 什么时候调用：每次触发手势之前都会询问下代理，是否触发。
// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // 注意：只有非根控制器才有滑动返回功能，根控制器没有。
    // 判断导航控制器是否只有一个子控制器，如果只有一个子控制器，肯定是根控制器
    /**
     *  这里有两个条件不允许手势执行，1、当前控制器为根控制器；2、如果这个push、pop动画正在执行（私有属性）
     */
    return self.viewControllers.count !=1 && ![[self valueForKey:@"_isTransitioning"] boolValue];
}
// 手指触摸屏幕后回调的方法，返回NO则不再进行手势识别，方法触发等
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (gestureRecognizer == self.backGesture) {
        
        CGPoint touchPoint = [touch locationInView:[UIApplication sharedApplication].delegate.window];
        if (touchPoint.x > 0 && touchPoint.x < 20) {
            return YES;
        }
        return NO;
    }
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)pushViewControllerWithClass:(Class)controllerClass {
    UIViewController *vc = [[controllerClass alloc] init];
    [self pushViewController:vc animated:YES];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count == 1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"YJBViewController")]) {
        [self.view addGestureRecognizer:self.backGesture];
    }else{
        [self.view removeGestureRecognizer:self.backGesture];
    }

    [super pushViewController:viewController animated:animated];
}

+ (void)yj_adapterScrollView_iOS_11{
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
}
@end

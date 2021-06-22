//
//  YJBNavigationController.h
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/7/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJBNavigationController : UINavigationController

@property (nonatomic, strong) UIPanGestureRecognizer *backGesture;

- (void)pushViewControllerWithClass:(Class)controllerClass;

//适配iOS11以上
+ (void)yj_adapterScrollView_iOS_11;
@end

NS_ASSUME_NONNULL_END

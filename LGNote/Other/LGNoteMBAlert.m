//
//  LGNoteMBAlert.m
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "LGNoteMBAlert.h"
#import "LGNoteConfigure.h"
#import <LGAlertHUD/LGAlertHUD.h>
#import "NSBundle+Notes.h"

@interface LGNoteMBAlert ()
{
    NSTimer       *_timer;
}

@property (nonatomic, copy) LGHUDDidHiddenBlock block;

@end


@implementation LGNoteMBAlert

+ (LGNoteMBAlert *)shareMBAlert{
    static LGNoteMBAlert * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LGNoteMBAlert alloc]init];
    });
    return manager;
}

- (void)showIndeterminate{
    [self showIndeterminateWithStatus:@""];
}

- (UIView *)currentView{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    return view;
}

- (void)showIndeterminateWithStatus:(NSString *)status{
    [LGAlert showIndeterminateWithStatus:status];
}

- (void)showStatus:(NSString *)status{
    [LGAlert showStatus:status];
}

- (void)showRemindStatus:(NSString *)status{
    [LGAlert showInfoWithStatus:status];
}

- (void)showSuccessWithStatus:(NSString *)status{
    [LGAlert showSuccessWithStatus:status];
}

- (void)showSuccessWithStatus:(NSString *)status afterDelay:(NSTimeInterval)delay completetion:(LGHUDDidHiddenBlock)completetion{
   [LGAlert showSuccessWithStatus:status];
    _timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(timerEvent) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    _block = completetion;
}

// 定时器方法
- (void)timerEvent{
    self.block();
}

- (void)showErrorWithStatus:(NSString *)status{
    [LGAlert showErrorWithStatus:status];
}



- (void)showBarDeterminateWithProgress:(CGFloat) progress{
    [self showBarDeterminateWithProgress:progress status:@"上传中..."];
}

- (void)showBarDeterminateWithProgress:(CGFloat) progress status:(NSString *)status{
    [LGAlert showBarDeterminateWithProgress:progress status:status];
}


- (void)hide{
    [LGAlert hide];
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}




- (void)showAlertControllerOn:(UIViewController *)viewController title:(nonnull NSString *)title message:(nonnull NSString *)message oneTitle:(nonnull NSString *)oneTitle oneHandle:(nonnull void (^)(UIAlertAction * _Nonnull))oneHandle twoTitle:(nonnull NSString *)twoTitle twoHandle:(nonnull void (^)(UIAlertAction * _Nonnull))twoHandle completion:(nonnull void (^)(void))completion{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:oneTitle style:UIAlertActionStyleDefault handler:oneHandle];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:twoTitle style:UIAlertActionStyleDefault handler:twoHandle];
    [action1 setValue:[UIColor redColor] forKey:@"titleTextColor"];
    //    [action2 setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alertController addAction:action2];
    [alertController addAction:action1];
    [viewController presentViewController:alertController animated:YES completion:completion];
}

/** HUD提示的内容 */
- (NSMutableAttributedString *)showHUDContent:(NSString *)content imageName:(NSString *)imageName{
    NSTextAttachment *attment = [[NSTextAttachment alloc] init];
    attment.image = [NSBundle lg_imagePathName:imageName];
    attment.bounds = CGRectMake(0, -10, 25, 30);
    
    NSAttributedString *attmentAtt = [NSAttributedString attributedStringWithAttachment:attment];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[@"\t " stringByAppendingString:content]];
    [att insertAttributedString:attmentAtt atIndex:0];
    
    return att;
}

/** 设置阴影效果 */
- (void)shadowView:(UIView *)view shadowColor:(UIColor *)color opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset{
    view.layer.masksToBounds = YES;
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowOpacity = opacity;
    view.layer.shadowRadius = radius;
    view.layer.shadowOffset = offset;
    view.clipsToBounds = NO;
}


@end

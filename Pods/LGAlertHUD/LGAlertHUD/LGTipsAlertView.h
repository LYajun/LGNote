//
//  LGTipsAlertView.h
//  LGAlertDemo
//
//  Created by lancoo on 2020/9/7.
//  Copyright © 2020 lancoo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGTipsAlertView : UIView

/** 成功 */
+ (void)showSuccessWithTips:(NSString *)tips;
/** 失败 */
+ (void)showFailureWithTips:(NSString *)tips;
+ (void)showFailureWithError:(NSError *)error;
/** 警告 */
+ (void)showErrorWithTips:(NSString *)tips;

+ (void)hide;

@end

NS_ASSUME_NONNULL_END

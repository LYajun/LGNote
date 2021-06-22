//
//  LGTipsAlertView.m
//  LGAlertDemo
//
//  Created by lancoo on 2020/9/7.
//  Copyright © 2020 lancoo. All rights reserved.
//

#import "LGTipsAlertView.h"
#import <Masonry/Masonry.h>
#import "LGAlertHUD.h"
#import <YJExtensions/YJExtensions.h>

@interface LGTipsAlertView ()

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIView *contentView;

@end

@implementation LGTipsAlertView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    self.window = UIApplication.sharedApplication.delegate.window;
    self.frame = self.window.bounds;
    self.backgroundColor = UIColor.clearColor;
    self.clipsToBounds = YES;
    
    self.backView = UIView.alloc.init;
    self.backView.backgroundColor = UIColor.blackColor;
    self.backView.frame = self.bounds;
    self.backView.alpha = 0.0f;
    [self addSubview:self.backView];
    
    self.contentView = UIView.alloc.init;
    self.contentView.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self);
    }];
    
    self.contentView.layer.cornerRadius = 2.0f;
    self.contentView.layer.shadowColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1.0].CGColor;
    self.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    self.contentView.layer.shadowOpacity = 1;
    self.contentView.layer.shadowRadius = 2.0f;
}

- (void)show {
    self.contentView.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    [self.window addSubview:self];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.backView.alpha = 0.0f;
        weakSelf.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1f, 1.1f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            weakSelf.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf hide];
            });
        }];
    }];
}

- (void)hide {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.backView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}
- (void)directhide {
    self.backView.alpha = 0.0f;
    [self removeFromSuperview];
}
- (void)showTips:(NSString *)tips imageName:(NSString *)imageName {
    [LGTipsAlertView hide];
    
    UIImage *image = [UIImage yj_imageNamed:imageName atBundle:LGAlert.alertBundle];
    
    UIImageView *iconIV = [[UIImageView alloc] initWithImage:image];
    [self.contentView addSubview:iconIV];
    [iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(18.0f);
        make.left.equalTo(self.contentView.mas_left).offset(35.0f);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.text = tips;
    tipsLabel.textColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f];
    tipsLabel.font = [UIFont systemFontOfSize:18.0f];
    tipsLabel.numberOfLines = 0;
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconIV.mas_right).offset(5.0f);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.top.equalTo(self.contentView.mas_top).offset(15.0f);
        make.right.equalTo(self.contentView.mas_right).offset(-35.0f);
        make.width.mas_lessThanOrEqualTo(200.0f);
    }];
    
    [self show];
}

/** 成功 */
+ (void)showSuccessWithTips:(NSString *)tips {
    [LGTipsAlertView.alloc.init showTips:tips imageName:@"lg_tips_success"];
}

/** 失败 */
+ (void)showFailureWithTips:(NSString *)tips {
    [LGTipsAlertView.alloc.init showTips:tips imageName:@"lg_tips_failure"];
}

+ (void)showFailureWithError:(NSError *)error {
    NSString *errorDesc = error.localizedDescription;
    if (!errorDesc || errorDesc.length == 0) errorDesc = @"未知错误";
    [self showFailureWithTips:errorDesc];
}

/** 警告 */
+ (void)showErrorWithTips:(NSString *)tips {
    [LGTipsAlertView.alloc.init showTips:tips imageName:@"lg_tips_error"];
}

+ (void)hide {
    for (UIView *view in UIApplication.sharedApplication.delegate.window.subviews) {
        if ([view isKindOfClass:LGTipsAlertView.class]) {
            [((LGTipsAlertView *)view) directhide];
        }
    }
}

@end

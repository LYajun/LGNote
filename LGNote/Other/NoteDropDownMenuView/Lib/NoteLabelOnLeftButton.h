//
//  NoteLabelOnLeftButton.h
//  NOteDropDownMenuView
//
//  Created by Peak on 16/5/28.
//  Copyright © 2016年 陈峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteLabelOnLeftButton : UIButton

+ (instancetype)createButtonWithImageNamenote:(NSString *)imgName title:(NSString *)title titleColor:(UIColor *)titleColor frame:(CGRect)btnFrame target:(id)target action:(SEL)action;

@end

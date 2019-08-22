//
//  LGNNewSeleteDataView.h
//  NoteDemo
//
//  Created by abc on 2019/8/21.
//  Copyright © 2019 hend. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,  NoteDateType) {
    NoteDateTypeWeek,  // 本周
    NoteDateTypeMonth, // 本月
    NoteDateTypeYear   // 本年
};


@protocol LGNNewSeleteDataViewDelegate <NSObject>

@optional

- (void)DataDidClickedAtIndexlgtm:(NSInteger)index;

//点击确认
- (void)filterViewDidChooseCallBack:(NSString *)time starTime:(NSString *)starTime endTime:(NSString *)endTime;

//点击重置
- (void)ClickresetBtn;

//点击毛玻璃
- (void)ClickMBL;
@end

@interface LGNNewSeleteDataView : UIView


@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, weak) id<LGNNewSeleteDataViewDelegate> delegate;

- (void)showView;

- (void)hideView;

//快速隐藏

- (void)hideViewForCelerity;

/** 传入VM的参数 */
- (void)bindViewModelParam:(NSString*)type starTime:(NSString*)starT endTime:(NSString*)endT;
@end

NS_ASSUME_NONNULL_END

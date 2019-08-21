//
//  LGNNewSeleteDataView.h
//  NoteDemo
//
//  Created by abc on 2019/8/21.
//  Copyright © 2019 hend. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LGNNewSeleteDataViewDelegate <NSObject>

@optional

- (void)DataDidClickedAtIndexlgtm:(NSInteger)index;

//点击确认
- (void)filterViewDidChooseCallBack:(NSString *)time starTime:(NSString *)starTime endTime:(NSString *)endTime;

//点击重置

@end

@interface LGNNewSeleteDataView : UIView


@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, weak) id<LGNNewSeleteDataViewDelegate> delegate;

- (void)showView;

- (void)hideView;



@end

NS_ASSUME_NONNULL_END

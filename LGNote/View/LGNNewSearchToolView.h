//
//  LGNNewSearchToolView.h
//  NoteDemo
//
//  Created by abc on 2019/8/21.
//  Copyright © 2019 hend. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LGNSearchToolViewConfigure.h"

NS_ASSUME_NONNULL_BEGIN


@protocol NewSearchToolViewDelegate <NSObject>
@optional

/** 进入搜索 */
- (void)NewenterSearchEvent;
/** 进入s筛选 */
- (void)NewfilterEvent;
/** 进入s筛选时间 */
- (void)NewSeleteEvent:(BOOL)selete;;
@end

@interface LGNNewSearchToolView : UIView


@property (nonatomic, strong, readwrite) UIButton *filterBtn;

@property (nonatomic, strong, readwrite) UIButton *seleteBtn;



@property (nonatomic, weak) id <NewSearchToolViewDelegate> delegate;

/**
 初始化
 
 @param frame frame
 @param configure 配置信息
 @return <#return value description#>
 */
- (instancetype)initWithFrame:(CGRect)frame
                    configure:(LGNSearchToolViewConfigure *)configure;


/**
 重置标记按钮状态
 */
//- (void)reSettingRemarkButtonUnSelected;


@end

NS_ASSUME_NONNULL_END

//
//  YJBViewController.h
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/7/20.
//

#import <UIKit/UIKit.h>
#import "YJBDataModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface YJBViewController : UIViewController

/** 数据处理对象 */
@property (nonatomic,strong) YJBDataModel *dataModel;
/** 初始化 */
- (instancetype)initWithDataModelName:(NSString *)dataModelName;

/** 是否关闭侧滑iOS默认手势，默认不关闭 */
@property (nonatomic, assign) BOOL closeSideslip;



- (void)yj_interactivePopGestureAction;
- (void)yj_setNavigationDelegate;


- (void)yj_loadData;
- (void)yj_loadGifData;
- (void)yj_updateData;
- (void)yj_loadErrorUpdate;

- (void)yj_loadTableData;

/** 加载视图与顶部的间距 */
@property (nonatomic,assign) CGFloat yj_loadingViewTopSpace;

/** 加载中 */
- (void)yj_setLoadingViewShow:(BOOL)show;
- (void)yj_setLoadingViewShow:(BOOL)show backgroundColor:(UIColor *)backgroundColor tintColor:(UIColor *)tintColor;
- (void)yj_setLoadingGifViewShow:(BOOL)show;
- (void)yj_setLoadingFlowerTitleViewShow:(BOOL)show;

@property (nonatomic,strong) UIColor *loadingViewBgColor;
@property (copy, nonatomic) NSString *yj_loadingGifTitle;
@property (copy, nonatomic) NSString *yj_loadingFlowerTitle;


/** 没有数据 */
@property (copy, nonatomic) NSString *yj_noDataTitle;

/** 图片的偏移量 */
@property (nonatomic,assign) CGFloat yj_noDataImgOffsetY;
@property (nonatomic,assign) CGFloat yj_noDataSearchImgOffsetY;

/** 是否搜索 */
@property (nonatomic,assign) BOOL yj_searchNodata;
- (void)yj_setNoDataViewShow:(BOOL)show;
- (void)yj_setNoDataViewShow:(BOOL)show isSearch:(BOOL)isSearch;
- (void)yj_setNoDataViewShow:(BOOL)show belowView:(UIView *)belowView;
- (void)yj_setNoDataViewShow:(BOOL)show isSearch:(BOOL)isSearch belowView:(nullable UIView *)belowView;

/** 发生错误 */
@property (copy, nonatomic) NSString *yj_loadErrorTitle;
/** 图片的偏移量 */
@property (nonatomic,assign) CGFloat yj_loadErrorImgOffsetY;
- (void)yj_setLoadErrorViewShow:(BOOL)show;
@end

NS_ASSUME_NONNULL_END

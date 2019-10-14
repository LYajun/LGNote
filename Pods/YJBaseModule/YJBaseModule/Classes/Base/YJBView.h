//
//  YJBView.h
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/7/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJBView : UIView


@property (nonatomic,copy) void (^yj_loadErrorUpdateBlock) (void);


/** 加载视图与顶部的间距 */
@property (nonatomic,assign) CGFloat yj_loadingViewTopSpace;

/** 加载中 */
- (void)yj_setLoadingViewShow:(BOOL)show;
- (void)yj_setLoadingViewShow:(BOOL)show backgroundColor:(UIColor *)backgroundColor tintColor:(UIColor *)tintColor;
- (void)yj_setLoadingGifViewShow:(BOOL)show;
- (void)yj_setLoadingFlowerTitleViewShow:(BOOL)show;

@property (copy, nonatomic) NSString *yj_loadingGifTitle;
@property (copy, nonatomic) NSString *yj_loadingFlowerTitle;


/** 没有数据 */
@property (copy, nonatomic) NSString *yj_noDataTitle;
/** 搜索图片的放大倍数 */
@property (nonatomic,assign) CGFloat yj_searchScale;
/** 搜索图片的偏移量 */
@property (nonatomic,assign) CGFloat yj_searchTranslateY;
/** 图片的偏移量 */
@property (nonatomic,assign) CGFloat yj_noDataImgOffsetY;


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

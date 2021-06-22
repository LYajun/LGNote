//
//  YJBCollectionView.h
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/7/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol YJBCollectionViewRefreshDelegate <NSObject>
@optional
- (void)collectionViewHeaderDidRefresh;
- (void)collectionViewFooterDidRefresh;
@end
@interface YJBCollectionView : UICollectionView
@property (nonatomic,assign) BOOL hideFooterStateLab;
@property (nonatomic,assign) id<YJBCollectionViewRefreshDelegate> refreshDelegate;
- (void)installRefreshHeader:(BOOL)installHeader footer:(BOOL)installFooter;
- (void)endHeaderRefreshing;
- (void)endFooterRefreshing;
- (void)endFooterRefreshingWithNoMoreData;
- (void)resetFooterNoMoreData;
- (void)startHeaderRefreshing;
- (void)yj_reloadData;
@end

NS_ASSUME_NONNULL_END

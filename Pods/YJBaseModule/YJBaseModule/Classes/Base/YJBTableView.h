//
//  YJBTableView.h
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/8/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol YJBTableViewRefreshDelegate <NSObject>
@optional
- (void)tableViewHeaderDidRefresh;
- (void)tableViewFooterDidRefresh;
@end
@interface YJBTableView : UITableView
@property (nonatomic,assign) BOOL hideFooterStateLab;
@property (nonatomic,strong) UIColor *footerStateColor;
@property (nonatomic,strong) UIColor *headerStateColor;
@property (nonatomic,assign) id<YJBTableViewRefreshDelegate> refreshDelegate;
- (void)installRefreshHeader:(BOOL)installHeader footer:(BOOL)installFooter;
- (void)endHeaderRefreshing;
- (void)endFooterRefreshing;
- (void)endFooterRefreshingWithNoMoreData;
- (void)resetFooterNoMoreData;


- (BOOL)headerIsRefreshing;

- (void)startHeaderRefreshing;

@end

NS_ASSUME_NONNULL_END

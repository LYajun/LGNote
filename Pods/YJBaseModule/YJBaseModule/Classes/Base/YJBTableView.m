//
//  YJBTableView.m
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/8/1.
//

#import "YJBTableView.h"
#import <MJRefresh/MJRefresh.h>
#import "YJBManager.h"

@interface YJBTableView ()

@end
@implementation YJBTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        [self configure];
    }
    return self;
}
- (void)configure{
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.estimatedRowHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
    self.estimatedSectionFooterHeight = 0;
}
- (void)installRefreshHeader:(BOOL)installHeader footer:(BOOL)installFooter{
    __weak typeof(self) weakSelf = self;
    if (installHeader) {
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            if (weakSelf.refreshDelegate && [weakSelf.refreshDelegate respondsToSelector:@selector(tableViewHeaderDidRefresh)]) {
                [weakSelf.refreshDelegate tableViewHeaderDidRefresh];
            }
        }];
        header.lastUpdatedTimeLabel.hidden = YES;
        [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
        [header setTitle:@"松手开始刷新" forState:MJRefreshStatePulling];
        [header setTitle:@"正在拼命加载 ..." forState:MJRefreshStateRefreshing];
        header.stateLabel.font = [UIFont systemFontOfSize:[YJBManager defaultManager].refreshHeaderStateTitleSize];
        header.stateLabel.textColor = [YJBManager defaultManager].refreshHeaderStateTitleColor;
        self.mj_header = header;
    }
    
    if (installFooter) {
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            if (weakSelf.refreshDelegate && [weakSelf.refreshDelegate respondsToSelector:@selector(tableViewFooterDidRefresh)]) {
                [weakSelf.refreshDelegate tableViewFooterDidRefresh];
            }
        }];
        // 设置文字
        [footer setTitle:@"上拉加载更多 ..." forState:MJRefreshStateIdle];
        [footer setTitle:@"正在拼命加载 ..." forState:MJRefreshStateRefreshing];
        [footer setTitle:@"已全部加载" forState:MJRefreshStateNoMoreData];
        footer.stateLabel.font = [UIFont systemFontOfSize:[YJBManager defaultManager].refreshFooterStateTitleSize];
        footer.stateLabel.textColor = [YJBManager defaultManager].refreshFooterStateTitleColor;
        self.mj_footer = footer;
    }
}
- (void)endHeaderRefreshing{
    if (self.mj_header) {
        [self.mj_header endRefreshing];
    }
}
- (void)endFooterRefreshing{
    if (self.mj_footer) {
        [self.mj_footer endRefreshing];
    }
}
- (void)endFooterRefreshingWithNoMoreData{
    if (self.mj_footer) {
        [self.mj_footer endRefreshingWithNoMoreData];
    }
}
- (void)resetFooterNoMoreData{
    if (self.mj_footer) {
        [self.mj_footer resetNoMoreData];
    }
}

- (void)startHeaderRefreshing{
    __weak typeof(self) weakSelf = self;
    if (self.mj_header) {
        [self.mj_header beginRefreshingWithCompletionBlock:^{
            if (weakSelf.refreshDelegate && [weakSelf.refreshDelegate respondsToSelector:@selector(tableViewHeaderDidRefresh)]) {
                [weakSelf.refreshDelegate tableViewHeaderDidRefresh];
            }
        }];
        
    }
}
@end

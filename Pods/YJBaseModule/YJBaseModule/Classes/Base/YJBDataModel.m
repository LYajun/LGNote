//
//  YJBDataModel.m
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/8/1.
//

#import "YJBDataModel.h"
#import "YJBTableView.h"
#import "YJBCollectionView.h"
#import <LGAlertHUD/LGAlertHUD.h>
#import "YJBViewController.h"

@implementation YJBDataModel

- (instancetype)initWithOwnController:(YJBViewController *)ownController{
    if (self = [super init]) {
        self.ownController = ownController;
        [self yj_configure];
    }
    return self;
}
- (instancetype)initWithOwnView:(YJBView *)ownView{
    if (self = [super init]) {
        self.ownView = ownView;
        [self yj_configure];
    }
    return self;
}
- (void)yj_configure{
    _models = [NSMutableArray array];
    _startPage = 1;
    _pageSize = 10;
    _totalCount = 0;
    _updateIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}
- (void)setTotalCount:(NSInteger)totalCount{
    _totalCount = totalCount;
    if (self.totalCountUpdateBlock) {
        self.totalCountUpdateBlock(totalCount);
    }
}
- (void)yj_removeAllData{
    [self.models removeAllObjects];
}
- (BOOL)yj_isRemoveAll{
    return self.currentPage == self.startPage;
}


- (void)yj_loadDataWithSuccess:(void (^)(BOOL))success failed:(void (^)(NSError * _Nonnull))failed{
    // This method is for override
}
- (void)yj_handleResponseData:(NSDictionary *)data modelClass:(Class)modelClass success:(void (^)(BOOL))success{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL noMoreData = NO;
        if (data && data.count > 0) {
            weakSelf.model = [[modelClass alloc] initWithDictionary:data];
        }else{
            noMoreData = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(noMoreData);
            }
            
        });
        
    });
}

#pragma mark - Table

- (void)yj_loadTableFirstPage{
    [self.ownTableView resetFooterNoMoreData];
    self.currentPage = self.startPage;
    [self yj_loadTableDataWithPage:self.currentPage];
}

- (void)yj_loadTableNextPage{
    self.currentPage++;
    [self yj_loadTableDataWithPage:self.currentPage];
}
- (void)yj_loadTableDataWithPage:(NSInteger)page{
    
    __weak typeof(self) weakSelf = self;
    [self yj_loadTableDataWithPage:page success:^(BOOL noMore) {
        [weakSelf.ownTableView endHeaderRefreshing];
        if (noMore) {
            [weakSelf.ownTableView endFooterRefreshingWithNoMoreData];
        }else{
            [weakSelf.ownTableView endFooterRefreshing];
        }
        [weakSelf.ownTableView reloadData];
        if (weakSelf.ownController) {
            [weakSelf.ownController yj_loadTableData];
        }
        weakSelf.ownTableView.hideFooterStateLab = weakSelf.models.count == 0;
    } failed:^(NSError * _Nonnull error) {
        [LGAlert showErrorWithStatus:@"加载失败"];
        [weakSelf.ownTableView endHeaderRefreshing];
        [weakSelf.ownTableView endFooterRefreshing];
        weakSelf.totalCount = 0;
         weakSelf.ownTableView.hideFooterStateLab = weakSelf.models.count == 0;
    }];
}
- (void)yj_loadTableDataWithPage:(NSInteger)page success:(void (^)(BOOL))success failed:(void (^)(NSError * _Nonnull))failed{
    // This method is for override
}

- (void)yj_loadTableIndexPathData{
    [self.ownController yj_setLoadingViewShow:YES backgroundColor:[UIColor colorWithWhite:0.2 alpha:0.4] tintColor:[UIColor whiteColor]];
    __weak typeof(self) weakSelf = self;
    [self yj_loadTableDataAtIndexPath:self.updateIndexPath success:^(BOOL noData) {
        [weakSelf.ownController yj_setLoadingViewShow:NO backgroundColor:[UIColor colorWithWhite:0.2 alpha:0.4] tintColor:[UIColor whiteColor]];
        if (noData) {
            [LGAlert showErrorWithStatus:@"更新失败"];
        }else{
            [weakSelf.ownTableView reloadData];
            [weakSelf.ownTableView scrollToRowAtIndexPath:weakSelf.updateIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
    } failed:^(NSError * _Nonnull error) {
        [weakSelf.ownController yj_setLoadingViewShow:NO backgroundColor:[UIColor colorWithWhite:0.2 alpha:0.4] tintColor:[UIColor whiteColor]];
        [LGAlert showErrorWithStatus:@"更新失败"];
    }];
}
- (void)yj_loadTableDataAtIndexPath:(NSIndexPath *)indexPath success:(void (^)(BOOL))success failed:(void (^)(NSError * _Nonnull))failed{
    // This method is for override
}

#pragma mark - CollectionView
- (void)yj_loadCollectionFirstPage{
    [self.ownCollectionView resetFooterNoMoreData];
    self.currentPage = self.startPage;
    [self yj_loadCollectioneDataWithPage:self.currentPage];
}

- (void)yj_loadCollectionNextPage{
     self.currentPage++;
     [self yj_loadCollectioneDataWithPage:self.currentPage];
}

- (void)yj_loadCollectioneDataWithPage:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    [self yj_loadCollectionDataWithPage:page success:^(BOOL noMore) {
        [weakSelf.ownCollectionView endHeaderRefreshing];
        if (noMore) {
            [weakSelf.ownCollectionView endFooterRefreshingWithNoMoreData];
        }else{
            [weakSelf.ownCollectionView endFooterRefreshing];
        }
        [weakSelf.ownCollectionView yj_reloadData];
        if (weakSelf.ownController) {
           [weakSelf.ownController yj_loadTableData];
        }
        weakSelf.ownCollectionView.hideFooterStateLab = weakSelf.models.count == 0;
    } failed:^(NSError * _Nonnull error) {
        [LGAlert showErrorWithStatus:@"加载失败"];
        [weakSelf.ownCollectionView endHeaderRefreshing];
        [weakSelf.ownCollectionView endFooterRefreshing];
        weakSelf.totalCount = 0;
        weakSelf.ownCollectionView.hideFooterStateLab = weakSelf.models.count == 0;
    }];
}

- (void)yj_loadCollectionDataWithPage:(NSInteger)page success:(void (^)(BOOL))success failed:(void (^)(NSError * _Nonnull))failed{
    // This method is for override
}

- (void)yj_loadCollectionIndexPathData{
    [self.ownController yj_setLoadingViewShow:YES backgroundColor:[UIColor colorWithWhite:0.2 alpha:0.4] tintColor:[UIColor whiteColor]];
    __weak typeof(self) weakSelf = self;
    [self yj_loadCollectionDataAtIndexPath:self.updateIndexPath success:^(BOOL noData) {
        [weakSelf.ownController yj_setLoadingViewShow:NO backgroundColor:[UIColor colorWithWhite:0.2 alpha:0.4] tintColor:[UIColor whiteColor]];
        if (noData) {
            [LGAlert showErrorWithStatus:@"更新失败"];
        }else{
            [weakSelf.ownCollectionView yj_reloadData];
            [weakSelf.ownCollectionView scrollToItemAtIndexPath:weakSelf.updateIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        }
    } failed:^(NSError * _Nonnull error) {
        [weakSelf.ownController yj_setLoadingViewShow:NO backgroundColor:[UIColor colorWithWhite:0.2 alpha:0.4] tintColor:[UIColor whiteColor]];
        [LGAlert showErrorWithStatus:@"更新失败"];
    }];
}

- (void)yj_loadCollectionDataAtIndexPath:(NSIndexPath *)indexPath success:(void (^)(BOOL))success failed:(void (^)(NSError * _Nonnull))failed{
    // This method is for override
}


#pragma mark - 数据处理
- (void)yj_handleResponseDataList:(NSArray *)dataList modelClass:(Class)modelClass totalCount:(NSInteger)totalCount success:(void (^)(BOOL))success{
    if (self. yj_isRemoveAll) {
        [self yj_removeAllData];
    }
    BOOL noMore = NO;
    if (dataList && dataList.count > 0) {
        if (self.currentPage != self.startPage) {
            if (totalCount > 0) {
                noMore = (self.pageSize * (self.currentPage - self.startPage) + dataList.count) >= totalCount;
            }else{
                noMore = (self.pageSize <= 0) || (dataList.count < self.pageSize);
            }
        }else{
            if (dataList.count < self.pageSize || (totalCount > 0 && dataList.count == totalCount)) {
                noMore = YES;
            }
        }
        for (NSDictionary *dict in dataList) {
            YJBModel *model = [[modelClass alloc] initWithDictionary:dict];
            [self.models addObject:model];
        }
        if (totalCount > 0) {
            self.totalCount = totalCount;
        }else{
            self.totalCount = self.models.count;
        }
    }else{
        noMore = YES;
        self.totalCount = self.models.count;
    }
    if (success) {
        success(noMore);
    }
}

- (void)yj_handleResponseData:(NSDictionary *)data modelClass:(Class)modelClass atIndexPath:(NSIndexPath *)indexPath success:(void (^)(BOOL))success{
    BOOL noData = NO;
    if (data && data.count > 0 && self.models.count > 0) {
        YJBModel *model = [[modelClass alloc]initWithDictionary:data];
        if (indexPath.section > 0) {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self.models[indexPath.section]];
            [arr replaceObjectAtIndex:indexPath.row withObject:model];
            [self.models replaceObjectAtIndex:indexPath.section withObject:arr];
        }else{
            [self.models replaceObjectAtIndex:indexPath.row withObject:model];
        }
    }else{
        noData = YES;
    }
    if (success) {
        success(noData);
    }
}

#pragma mark - DidSelect
- (void)yj_didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.updateIndexPath = indexPath;
    [self yj_gotoDetailPageAtIndexPath:indexPath];
}
- (void)yj_gotoDetailPageAtIndexPath:(NSIndexPath *)indexPath{
    // This method is for override
}
@end

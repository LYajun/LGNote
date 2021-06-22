//
//  YJBDataModel.h
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/8/1.
//

#import <Foundation/Foundation.h>
#import "YJBModel.h"

NS_ASSUME_NONNULL_BEGIN

@class YJBViewController,YJBTableView,YJBCollectionView,YJBView;
@interface YJBDataModel : NSObject
@property (nonatomic,strong) YJBModel *model;

/** 学科ID */
@property (nonatomic,copy) NSString *subjectID;
/** 搜索关键字 */
@property (nonatomic,copy) NSString *searchKey;
/** 资料类型 */
@property (nonatomic,copy) NSString *resType;
/** 资料来源 */
@property (nonatomic,copy) NSString *source;

/** 教案ID */
@property (nonatomic,copy) NSString *lessonPlanID;
/** 教师ID */
@property (nonatomic,copy) NSString *teacherID;

/** 课件ID */
@property (nonatomic,copy) NSString *coursewareID;
/** 子课件ID */
@property (nonatomic,copy) NSString *subCoursewareID;

/** 任务ID */
@property (nonatomic,copy) NSString *assignmentID;
/** 任务ID */
@property (nonatomic,copy) NSString *assignmentName;
/** 用户ID */
@property (nonatomic,copy) NSString *userID;
/** 作答ID */
@property (nonatomic,copy) NSString *answerID;
/** 资料ID */
@property (nonatomic,copy) NSString *resID;
/** 资料名 */
@property (nonatomic,copy) NSString *resName;
/** 班级ID */
@property (nonatomic,copy) NSString *classID;
/** 大题ID */
@property (nonatomic,copy) NSString *topicID;
/** 是否标准资料 */
@property (nonatomic,assign) BOOL isStandard;
/** 资料类型 */
@property (nonatomic,assign) NSInteger resOriginTypeID;
/** 课件类型ID */
@property (nonatomic,copy) NSString *resOriTypeID;
/** 其他参数 */
@property (nonatomic,strong) NSDictionary *otherParameters;


/** 表格 当前页码 */
@property (nonatomic,assign) NSInteger currentPage;
/** 表格 起始页码 */
@property (nonatomic,assign) NSInteger startPage;
/** 表格 每页数据量 */
@property (nonatomic,assign) NSInteger pageSize;
/** 表格 总数 */
@property (nonatomic,assign) NSInteger totalCount;
/** 刷新数据索引 */
@property (nonatomic,strong) NSIndexPath *updateIndexPath;
/** 数据总数回调 */
@property (nonatomic,copy) void (^totalCountUpdateBlock) (NSInteger totalCount);
/** 表格 模型数组 */
@property (nonatomic,strong) NSMutableArray *models;
/** 表格 数据列表清空 */
- (void)yj_removeAllData;
/** 表格 是否需要清空刷新 */
- (BOOL)yj_isRemoveAll;


/** 所属的控制器 */
@property (weak, nonatomic) YJBView *ownView;
@property (weak, nonatomic) YJBViewController *ownController;
@property (weak, nonatomic) YJBTableView *ownTableView;
@property (weak, nonatomic) YJBCollectionView *ownCollectionView;

- (instancetype)initWithOwnController:(YJBViewController *)ownController;
- (instancetype)initWithOwnView:(YJBView *)ownView;
- (void)yj_configure;


/** Controller */
- (void)yj_loadDataWithSuccess:(void(^)(BOOL noData))success failed:(void(^)(NSError *error))failed;
- (void)yj_handleResponseData:(NSDictionary *)data modelClass:(Class)modelClass success:(void(^)(BOOL noData))success;

/** TableView */
- (void)yj_loadTableFirstPage;
- (void)yj_loadTableNextPage;
- (void)yj_loadTableIndexPathData;

- (void)yj_loadTableDataWithPage:(NSInteger)page success:(void(^)(BOOL noMore))success failed:(void(^)(NSError *error))failed;
- (void)yj_loadTableDataAtIndexPath:(NSIndexPath *)indexPath success:(void (^)(BOOL noData))success failed:(void (^)(NSError *error))failed;

/** CollectionView */
- (void)yj_loadCollectionFirstPage;
- (void)yj_loadCollectionNextPage;
- (void)yj_loadCollectionIndexPathData;

- (void)yj_loadCollectionDataWithPage:(NSInteger)page success:(void(^)(BOOL noMore))success failed:(void(^)(NSError *error))failed;
- (void)yj_loadCollectionDataAtIndexPath:(NSIndexPath *)indexPath success:(void (^)(BOOL noData))success failed:(void (^)(NSError *error))failed;




- (void)yj_handleResponseDataList:(NSArray *)dataList modelClass:(Class)modelClass totalCount:(NSInteger)totalCount success:(void(^)(BOOL noMore))success;
- (void)yj_handleResponseData:(NSDictionary *)data modelClass:(Class)modelClass atIndexPath:(NSIndexPath *)indexPath success:(void(^)(BOOL noData))success;

- (void)yj_didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)yj_gotoDetailPageAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

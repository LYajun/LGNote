//
//  NoteViewModel.h
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "LGNParamModel.h"
#import "LGNNoteModel.h"
#import "LGNSubjectModel.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const CheckNoteBaseUrlKey;

@interface LGNViewModel : NSObject
/** 参数 */
@property (nonatomic, strong) LGNParamModel *paramModel;

/** 刷新 */
@property (nonatomic, strong) RACCommand *refreshCommand;
@property (nonatomic, strong) RACSubject *refreshSubject;
@property (nonatomic, strong) RACCommand *nextPageCommand;

/** 添加、编辑、删除（1添加、0编辑、3删除) */  
@property (nonatomic, strong) RACCommand *operateCommand;
@property (nonatomic, strong) RACSubject *operateSubject;
//
///** 删除 */
//@property (nonatomic, strong) RACCommand *deletedCommand;
//@property (nonatomic, strong) RACSubject *deletedSubject;

/** 搜索 */
@property (nonatomic, strong) RACCommand *searchCommand;
@property (nonatomic, strong) RACSubject *searchSubject;

/** 获取某一条笔记的详情信息 */
@property (nonatomic, strong) RACCommand *getDetailNoteCommand;
@property (nonatomic, strong) RACSubject *getDetailNoteSubject;

/** 获取本学期开始和截止时间 */
@property (nonatomic, strong) RACCommand *getTermTimeCommand;
@property (nonatomic, strong) RACSubject *getTermTimeSubject;

//获取某一系统或全部笔记所有学科列表

@property (nonatomic, strong) RACCommand *getAllSubjectCommand;
@property (nonatomic, strong) RACSubject *getAllSubjectSubject;

//获取备选教材列表
@property (nonatomic, strong) RACCommand *getTextbookListRateCommand;
@property (nonatomic, strong) RACSubject *getTextbookListRateSubject;

//获取教材节点
@property (nonatomic, strong) RACCommand *getNodeInfoRateCommand;
@property (nonatomic, strong) RACSubject *getNodeInfoRateSubject;


/** 数据总数 */
@property (nonatomic, assign) NSInteger totalCount;
/** 笔记所支持学科 */
@property (nonatomic, copy)   NSArray *subjectArray;
/** 获取支持的系统 */
@property (nonatomic, copy)   NSArray *systemArray;
/** 数据源 */
@property (nonatomic, strong) LGNNoteModel *dataSourceModel;
/** 是否是搜索操作，是的话会屏蔽删除操作 */
@property (nonatomic, assign) BOOL isSearchOperation;
/** 是否是添加操作 */
@property (nonatomic, assign) BOOL isAddNoteOperation;

/**
 检查url的可用性

 @return <#return value description#>
 */
- (RACSignal *)checkNoteBaseUrl;

/**
 获取筛选支持的学科信息

 @return <#return value description#>
 */
- (RACSignal *)getAllSubjectInfo;

/**
 获取所有支持的系统信息

 @return <#return value description#>
 */
- (RACSignal *)getAllSystemInfo;

/**
 获取某一条笔记的详情信息

 @param noteID <#noteID description#>
 @return <#return value description#>
 */
- (RACSignal *)getOneNoteInfoWithNoteID:(NSString *)noteID;

/**
 上传图片
 
 @param images <#images description#>
 @return <#return value description#>
 */
- (RACSignal *)uploadImages:(NSArray <UIImage *> *)images;


/**
  上传笔记相关联来源详细信息

 @param sourceInfo <#sourceInfo description#>
 @return <#return value description#>
 */
- (RACSignal *)uploadNoteSourceInfo:(id)sourceInfo;


/**
 通过学科数组、学科名，返回对应学科ID和在picker显示的下标
 
 @param subjectArray 学科集合
 @param subjectName 学科名
 @return <#return value description#>
 */
- (RACSignal *)getSubjectIDAndPickerSelectedForSubjectArray:(NSArray *)subjectArray
                                                subjectName:(NSString *)subjectName;


- (NSArray *)configureMaterialPickerDataSource;

- (NSArray *)configureSubjectPickerDataSource;

@end

NS_ASSUME_NONNULL_END

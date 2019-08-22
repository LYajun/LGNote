//
//  LGNNewFilterViewController.h
//  NoteDemo
//
//  Created by abc on 2019/8/21.
//  Copyright © 2019 hend. All rights reserved.
//

#import "LGNoteBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NewFilterStyle) {
    NewFilterStyleDefault,            // 默认(只有学科筛选)
    NewFilterStyleCustom              // 自定义(学科和系统)
};

@protocol LGNNewFilterDelegate <NSObject>
@required

/**
 确定筛选后，返回筛选数据
 
 @param subjecID <#subjecID description#>
 @param systemID <#systemID description#>
 */
- (void)NewfilterViewDidChooseCallBack:(NSString *)subjecID systemID:(NSString *)systemID remake:(BOOL)remake;

@end


@interface LGNNewFilterViewController : LGNoteBaseViewController

@property (nonatomic, weak) id <LGNNewFilterDelegate> delegate;

/** 筛选类型 */
@property (nonatomic, assign) NewFilterStyle filterStyle;
/** 学科 */
@property (nonatomic, copy) NSArray *subjectArray;
@property (nonatomic, copy) NSArray *systemArray;

/** 传入VM的参数 */
- (void)bindViewModelParam:(id)param;


@end

NS_ASSUME_NONNULL_END

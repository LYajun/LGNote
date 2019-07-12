//
//  NoteMainTableView.h
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "LGNoteBaseTableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LGNNoteMainTableView : LGNoteBaseTableView
//搜索
@property (nonatomic,assign) BOOL  isSearchVC;
@property (nonatomic,strong) NSString * searchContent;

@property (nonatomic, copy) void (^notoDataCall)(NSInteger page);
@end

NS_ASSUME_NONNULL_END

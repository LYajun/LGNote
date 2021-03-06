//
//  NoteMainTableViewCell.h
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LGNNoteModel;
NS_ASSUME_NONNULL_BEGIN

@interface LGNNoteMainTableViewCell : UITableViewCell

- (void)configureCellForDataSource:(LGNNoteModel *)dataSource indexPath:(NSIndexPath *)indexPath;

- (void)configureCellForDataSource_TY:(LGNNoteModel *)dataSource indexPath:(NSIndexPath *)indexPath;
//搜索
@property (nonatomic,assign) BOOL  isSearchVC;
@property (nonatomic,strong) NSString * searchContent;
/** 资料名 */
@property (nonatomic, copy) NSString *MaterialName;

@end

NS_ASSUME_NONNULL_END

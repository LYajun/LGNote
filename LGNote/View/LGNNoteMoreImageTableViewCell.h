//
//  NoteMoreImageTableViewCell.h
//  NoteDemo
//
//  Created by hend on 2019/3/21.
//  Copyright © 2019 hend. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LGNNoteModel;

@interface LGNNoteMoreImageTableViewCell : UITableViewCell

- (void)configureCellForDataSource_TY:(LGNNoteModel *)dataSource indexPath:(NSIndexPath *)indexPath;

- (void)configureCellForDataSource:(LGNNoteModel *)dataSource indexPath:(NSIndexPath *)indexPath;
//搜索
@property (nonatomic,assign) BOOL  isSearchVC;
@property (nonatomic,strong) NSString * searchContent;
/** 资料名 */
@property (nonatomic, copy) NSString *MaterialName;
@end

NS_ASSUME_NONNULL_END

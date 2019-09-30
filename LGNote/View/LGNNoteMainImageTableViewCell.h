//
//  NoteMainImageTableViewCell.h
//  NoteDemo
//
//  Created by hend on 2019/3/20.
//  Copyright © 2019 hend. All rights reserved.
//

#import "LGNNoteMainTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LGNNoteMainImageTableViewCell : UITableViewCell


- (void)configureCellForDataSource:(LGNNoteModel *)dataSource indexPath:(NSIndexPath *)indexPath;
//搜索
@property (nonatomic,assign) BOOL  isSearchVC;
@property (nonatomic,strong) NSString * searchContent;
/** 资料名 */
@property (nonatomic, copy) NSString *MaterialName;
@end

NS_ASSUME_NONNULL_END

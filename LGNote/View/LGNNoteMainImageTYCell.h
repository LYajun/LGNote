//
//  LGNNoteMainImageTYCell.h
//  NoteDemo
//
//  Created by abc on 2020/5/21.
//  Copyright © 2020 hend. All rights reserved.
//

#import "LGNNoteMainTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LGNNoteMainImageTYCell : UITableViewCell


- (void)configureCellForDataSource:(LGNNoteModel *)dataSource indexPath:(NSIndexPath *)indexPath;
//搜索
@property (nonatomic,assign) BOOL  isSearchVC;
@property (nonatomic,strong) NSString * searchContent;
/** 资料名 */
@property (nonatomic, copy) NSString *MaterialName;
@end

NS_ASSUME_NONNULL_END

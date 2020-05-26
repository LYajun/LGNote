//
//  LGNTextBookListModel.h
//  NoteDemo
//
//  Created by abc on 2020/5/25.
//  Copyright © 2020 hend. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGNTextBookListModel : NSObject
//教材ID
@property (nonatomic,strong) NSString * TextbookId;
@property (nonatomic,strong) NSString * TextbookName;
//封面图片地址，绝对地址
@property (nonatomic,strong) NSString * CoverImgUrl;
//是否已选中
@property (nonatomic,strong) NSString * IsSelected;
@end

NS_ASSUME_NONNULL_END

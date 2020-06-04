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
//教材列表

@property (nonatomic,copy) NSString * BookName;
@property (nonatomic,copy) NSString * BookId;



@property (nonatomic,copy) NSString * UnionName;
@property (nonatomic,copy) NSString * UnionId;
@end

NS_ASSUME_NONNULL_END

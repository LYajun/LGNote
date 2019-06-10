//
//  LGNSingleTool.h
//  NoteDemo
//
//  Created by abc on 2019/6/5.
//  Copyright © 2019 hend. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGNoteConfigure.h"
NS_ASSUME_NONNULL_BEGIN

@interface LGNSingleTool : NSObject

//复制的文本内容
@property (nonatomic, strong) NSMutableAttributedString *CopyNoteContent_Att;

@property (nonatomic,strong) NSAttributedString * attributedString;

@property (nonatomic,strong) NSString * Notcontent;
AS_SINGLETON(LGNSingleTool)
@end

NS_ASSUME_NONNULL_END

//
//  YJNewNoteView.h
//  YJNewNote_Example
//
//  Created by 刘亚军 on 2020/4/9.
//  Copyright © 2020 lyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJNewNoteManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface YJNewNoteView : UIView
+ (void)showNewNoteViewOn:(UIView *)view newNoteType:(YJNewNoteType)newNoteType;
@end

NS_ASSUME_NONNULL_END

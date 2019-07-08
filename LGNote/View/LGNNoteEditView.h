//
//  NoteEditView.h
//  NoteDemo
//
//  Created by hend on 2019/3/11.
//  Copyright © 2019 hend. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGNoteBaseTextView.h"
#import "LGNoteBaseTextField.h"

NS_ASSUME_NONNULL_BEGIN
@class LGNViewModel;

/** 编辑页头部样式使用 */
typedef NS_ENUM(NSInteger, NoteEditViewHeaderStyle) {
    NoteEditViewHeaderStyleNoHidden,          // 都不隐藏,不支持点击
    
    NoteEditViewHeaderStyleNoHiddenCanTouch,//都不隐藏,支持点击
    NoteEditViewHeaderStyleHideSource,        // 隐藏来源选项
    NoteEditViewHeaderStyleHideSubject,       // 隐藏学科选项
    NoteEditViewHeaderStyleHideAll            // 隐藏全部
};

@interface LGNNoteEditView : UIView

@property (nonatomic, weak) UIViewController *ownController;


/**
 初始化

 @param frame <#frame description#>
 @param style <#style description#>
 @return <#return value description#>
 */
- (instancetype)initWithFrame:(CGRect)frame
              headerViewStyle:(NoteEditViewHeaderStyle)style;

- (void)bindViewModel:(LGNViewModel *)viewModel;

@property (nonatomic, strong) LGNoteBaseTextView *contentTextView;
@property (nonatomic, strong) LGNoteBaseTextField *titleTextF;
@property (nonatomic, strong) UIButton *remarkBtn;
@property (nonatomic, strong) UIButton *subjectBtn;

@property (nonatomic,assign) BOOL  canEditing;
@end

NS_ASSUME_NONNULL_END

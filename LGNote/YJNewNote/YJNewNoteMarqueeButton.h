//
//  YJNewNoteMarqueeButton.h
//  LGKnowledgeFramework
//
//  Created by 刘亚军 on 2019/10/31.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJNewNoteMarqueeLabel.h"
NS_ASSUME_NONNULL_BEGIN

@interface YJNewNoteMarqueeButton : UIView
@property (nonatomic,strong,readonly) YJNewNoteMarqueeLabel *titleLabel;
@property (nonatomic,assign) BOOL selected;
- (instancetype)initWithFrame:(CGRect)frame isLeftTitle:(BOOL)isLeftTitle;
- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end

NS_ASSUME_NONNULL_END

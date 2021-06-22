//
//  YJNewNoteMarqueeLabel.h
//  LGMultimediaFramework
//
//  Created by 刘亚军 on 2019/3/4.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YJNewNoteMarqueeLabelType) {
    YJNewNoteMarqueeLabelTypeLeft = 0,//向左边滚动
    YJNewNoteMarqueeLabelTypeLeftRight = 1,//先向左边，再向右边滚动
};

@interface YJNewNoteMarqueeLabel : UILabel

@property(nonatomic,assign) YJNewNoteMarqueeLabelType marqueeLabelType;
@property(nonatomic,assign) CGFloat speed;//速度
@property(nonatomic,assign) CGFloat secondLabelInterval;
@property(nonatomic,assign) NSTimeInterval stopTime;//滚到顶的停止时间
- (void)invalidateTimer;
@end

NS_ASSUME_NONNULL_END

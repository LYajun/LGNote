//
//  YJBTableViewCell.h
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/8/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJBTableViewCell : UITableViewCell
@property (nonatomic, assign) BOOL isShowSeparator;
@property (nonatomic, assign) CGFloat separatorWidth;
@property (nonatomic, assign) CGFloat separatorOffset;
@property (nonatomic, assign) CGPoint separatorOffsetPoint;
@property (nonatomic,strong) UIColor *sepColor;
@property (nonatomic,strong) UIColor *highlightColor;
@end

NS_ASSUME_NONNULL_END

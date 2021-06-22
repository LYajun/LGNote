//
//  YJBWebNavigationView.h
//  YJBaseModule
//
//  Created by 刘亚军 on 2019/9/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJBWebNavigationView : UIView
/** 标题 */
@property (nonatomic,copy) NSString *titleStr;
/** 返回回调 */
@property (nonatomic,copy) void (^backBlock) (void);
@end

NS_ASSUME_NONNULL_END

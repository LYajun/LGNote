//
//  YJBModel.h
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/8/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJBModel : NSObject<NSMutableCopying>
/** 用字典初始化（MJExtension） */
- (instancetype)initWithDictionary:(NSDictionary *)aDictionary;

/** 用JSONString初始化 */
- (instancetype)initWithJSONString:(NSString *)aJSONString;

@end

NS_ASSUME_NONNULL_END

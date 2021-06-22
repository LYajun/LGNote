//
//  YJAudioMerger.h
//  Pods-YJUtils_Example
//
//  Created by 刘亚军 on 2019/8/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJAudioMerger : NSObject
/** 音频合成输出路径 */
@property (nonatomic,copy) NSString *outPutFilePath;

+ (YJAudioMerger *)shareAudioMerger;

- (void)mergeAudioWithStartPath:(NSString *)startPath endPath:(NSString *)endPath;
- (void)mergeAudioWithStartPath:(NSString *)startPath endPath:(NSString *)endPath completion:(void (^ _Nullable) (BOOL isSuccess))completion;

- (void)mergeMoreAudioWithPaths:(NSArray *)paths;
- (void)mergeMoreAudioWithPaths:(NSArray *)paths completion:( void (^ _Nullable) (BOOL isSuccess))completion;
@end

NS_ASSUME_NONNULL_END

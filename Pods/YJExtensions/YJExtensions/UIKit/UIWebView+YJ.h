//
//  UIWebView+YJ.h
//  YJExtensionsDemo
//
//  Created by 刘亚军 on 2019/7/22.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWebView (YJ)
+ (NSArray *)voiceAllFileExtension;
+ (NSArray *)imageAllFileExtension;

+ (BOOL)yj_isVoiceFileWithExtName:(NSString *)extName;

+ (BOOL)yj_isImgFileWithExtName:(NSString *)extName;

- (void)yj_setTextSizeWithRate:(NSString *)rate;

- (void)yj_addImgClickEvent;
/** 获取到H5页面上所有图片的url的拼接 */
- (NSString *)yj_getImages;
@end

NS_ASSUME_NONNULL_END

//
//  YJBManager.h
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/7/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

#define IsIPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface YJBManager : NSObject
/** 加载动图文件夹名 */
@property (nonatomic,copy) NSString *loadingDirName;
/** 加载动图文件名前缀 */
@property (nonatomic,copy) NSString *loadingImgPrefix;
/** 加载动图文件名后缀缀 */
@property (nonatomic,copy) NSString *loadingImgSuffix;

/** 加载视图颜色 */
@property (nonatomic,strong) UIColor *loadingColor;

/** 加载动图标题 */
@property (nonatomic,copy) NSString *loadingGifTitle;
/** 加载动图标题颜色 */
@property (nonatomic,strong) UIColor *loadingGifTitleColor;
/** 加载动图标题大小 */
@property (nonatomic,assign) CGFloat loadingGifTitleSize;

/** 加载菊花标题 */
@property (nonatomic,copy) NSString *loadingFlowerTitle;
/** 加载菊花标题颜色 */
@property (nonatomic,strong) UIColor *loadingFlowerTitleColor;
/** 加载菊花标题大小 */
@property (nonatomic,assign) CGFloat loadingFlowerTitleSize;
/** 加载菊花视图颜色 */
@property (nonatomic,strong) UIColor *loadingFlowerColor;


/** 数据为空 */
@property (nonatomic,copy) NSString *loadEmptyImgName;
@property (nonatomic,copy) NSString *loadEmptyTitle;
/** 数据为空标题颜色 */
@property (nonatomic,strong) UIColor *loadEmptyTitleColor;
/** 数据为空标题大小 */
@property (nonatomic,assign) CGFloat loadEmptyTitleSize;

/** 搜索为空 */
@property (nonatomic,copy) NSString *searchEmptyImgName;
@property (nonatomic,copy) NSString *searchEmptyTitle;

/** 加载失败 */
@property (nonatomic,copy) NSString *loadErrorImgName;
@property (nonatomic,copy) NSString *loadErrorTitle;
/** 加载失败标题颜色 */
@property (nonatomic,strong) UIColor *loadErrorTitleColor;
/** 加载失败标题大小 */
@property (nonatomic,assign) CGFloat loadErrorTitleSize;

/** 上下拉标题 */
@property (nonatomic,strong) UIColor *refreshHeaderStateTitleColor;
@property (nonatomic,assign) CGFloat refreshHeaderStateTitleSize;
@property (nonatomic,strong) UIColor *refreshFooterStateTitleColor;
@property (nonatomic,assign) CGFloat refreshFooterStateTitleSize;


+ (YJBManager *)defaultManager;

- (NSBundle *)currentBundle;
- (NSArray *)loadingImgs;
@end

NS_ASSUME_NONNULL_END

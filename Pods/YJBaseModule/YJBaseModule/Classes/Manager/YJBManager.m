//
//  YJBManager.m
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/7/20.
//

#import "YJBManager.h"
#import <YJExtensions/YJExtensions.h>

#import <LGBundle/LGBundleManager.h>

@interface YJBManager ()
@property (nonatomic,strong) NSArray *loadingImgs;
@property (nonatomic,strong) NSBundle *currentBundle;
@property (nonatomic,strong) NSBundle *lgBundle;
@end
@implementation YJBManager
+ (YJBManager *)defaultManager{
    static YJBManager * macro = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        macro = [[YJBManager alloc]init];
        [macro configure];
    });
    return macro;
}

- (void)configure{
    _currentBundle = [NSBundle yj_bundleWithCustomClass:YJBManager.class bundleName:@"YJBaseModule"];
    _lgBundle = [LGBundleManager defaultManager].bundle;
    
    _loadingImgs = [LGBundleManager defaultManager].loadingImgs;
    
    
    _loadingColor = [UIColor yj_colorWithHex:0x989898];
    _loadingGifTitle = @"努力加载中...";
    _loadingGifTitleColor = [UIColor yj_colorWithHex:0x989898];
    _loadingGifTitleSize = 14;
    
    
    _loadingFlowerTitle = @"正在初始化资源...";
    _loadingFlowerTitleColor = [UIColor yj_colorWithHex:0x45bcfa];
    _loadingFlowerTitleSize = 16;
    _loadingFlowerColor = [UIColor yj_colorWithHex:0x45bcfa];
    
    
    _loadEmptyTitle = @"暂无内容";
    _loadEmptyImgName = @"empty_1";
    _loadEmptyTitleColor = [UIColor yj_colorWithHex:0x989898];
    _loadEmptyTitleSize = 14;
    
    _searchEmptyTitle = @"无搜索结果，换个词试试吧~";
    _searchEmptyImgName = @"search_empty_1";
    
    
    _loadErrorTitle = @"数据加载失败，轻触刷新";
    _loadErrorImgName= @"error_1";
    _loadErrorTitleColor = [UIColor yj_colorWithHex:0x989898];
    _loadErrorTitleSize = 14;
    
    
    _refreshHeaderStateTitleSize = 15;
    _refreshHeaderStateTitleColor = [UIColor yj_colorWithHex:0x333333];
    _refreshFooterStateTitleSize = 15;
    _refreshFooterStateTitleColor = [UIColor yj_colorWithHex:0x989898];
    
   
}
@end

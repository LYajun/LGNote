//
//  YJBManager.m
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/7/20.
//

#import "YJBManager.h"
#import <YJExtensions/YJExtensions.h>

@interface YJBManager ()
@property (nonatomic,strong) NSArray *loadingImgs;
@property (nonatomic,strong) NSBundle *currentBundle;
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
    
    _loadingDirName = @"Loading1";
    _loadingImgPrefix = @"loading";
    _loadingImgSuffix = @"jpg";
    
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
    
    [self initLoadingImg];
}

- (void)initLoadingImg{
    CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
    NSFileManager *fielM = [NSFileManager defaultManager];
    NSArray *arrays = [fielM contentsOfDirectoryAtPath:[self.currentBundle yj_bundlePathWithName:self.loadingDirName] error:nil];
    NSMutableArray *imageArr = [NSMutableArray array];
    for (NSInteger i = 1; i <= arrays.count; i++) {
        UIImage *image = [UIImage yj_imagePathName:[NSString stringWithFormat:@"%@/%@%li.%@",self.loadingDirName,self.loadingImgPrefix,i,self.loadingImgSuffix] atBundle:self.currentBundle];
        if (image) {
            [imageArr addObject:image];
        }
    }
    NSLog(@"loadingGifImg Linked in %f ms", (CFAbsoluteTimeGetCurrent() - startTime) *1000.0);
    self.loadingImgs = imageArr;
}

@end

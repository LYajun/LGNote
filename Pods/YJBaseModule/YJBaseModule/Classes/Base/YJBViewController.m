//
//  YJBViewController.m
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/7/20.
//

#import "YJBViewController.h"
#import "YJBNavigationController.h"

#import <YJActivityIndicatorView/YJActivityIndicatorView.h>
#import <Masonry/Masonry.h>
#import <YJExtensions/YJExtensions.h>
#import "YJBManager.h"

@interface YJBViewController ()<UINavigationControllerDelegate>
/** 加载中 */
@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIView *loadingGifView;
@property (strong, nonatomic) UIView *loadingFlowerView;
@property (strong, nonatomic) UILabel *loadingGifLab;
@property (strong, nonatomic) UILabel *loadingFlowerLab;
@property (strong, nonatomic) YJActivityIndicatorView *activityIndicatorView;
/** 数据为空 */
@property (strong, nonatomic) UIView *noDataView;
@property (strong, nonatomic) UILabel *noDataLab;
@property (strong, nonatomic) UIImageView *noDataImgView;
@property (strong, nonatomic) UIImageView *noDataSearchImgView;
/** 加载失败 */
@property (strong, nonatomic) UIView *loadErrorView;
@property (strong, nonatomic) UILabel *loadErrorLab;

/** 是否动图加载 */
@property (nonatomic,assign) NSInteger isLoadingGif;
@end

@implementation YJBViewController
- (instancetype)initWithDataModelName:(NSString *)dataModelName{
    if (self = [super init]) {
        if (dataModelName && dataModelName.length > 0) {
            Class ServiceClass = NSClassFromString(dataModelName);
            self.dataModel = [[ServiceClass alloc] initWithOwnController:self];
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;

    _yj_noDataImgOffsetY = -40;
    _yj_noDataSearchImgOffsetY = -70;
    _yj_loadErrorImgOffsetY = -15;
 
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![self.navigationController.view.gestureRecognizers containsObject:((YJBNavigationController *)self.navigationController).backGesture]) {
        [self.navigationController.view addGestureRecognizer:((YJBNavigationController *)self.navigationController).backGesture];
    }

    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] && self.closeSideslip) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        ((YJBNavigationController *)self.navigationController).backGesture.enabled = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] && self.closeSideslip) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        ((YJBNavigationController *)self.navigationController).backGesture.enabled = YES;
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)willMoveToParentViewController:(UIViewController *)parent{
    [super willMoveToParentViewController:parent];
    NSLog(@"%s,%@",__FUNCTION__,NSStringFromClass(self.class));
}
- (void)didMoveToParentViewController:(UIViewController *)parent{
    [super didMoveToParentViewController:parent];
    NSLog(@"%s,%@",__FUNCTION__,NSStringFromClass(self.class));
    if(!parent){
        [self yj_interactivePopGestureAction];
    }
}
- (void)yj_interactivePopGestureAction{
}
- (void)yj_setNavigationDelegate{
    self.navigationController.delegate = self;
}
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}

#pragma mark - Dealloc
- (void)dealloc {
    self.navigationController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"****** %@--dealloc *******", NSStringFromClass([self class]));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%@ didReceiveMemoryWarning", NSStringFromClass([self class]));
}

#pragma mark - LoadData
- (void)yj_loadData{
    self.isLoadingGif = NO;
    [self loadDataWithCompletion:nil];
}
- (void)yj_loadGifData{
    self.isLoadingGif = YES;
    [self loadDataWithCompletion:nil];
}
- (void)loadDataWithCompletion:(void (^)(BOOL))completion{
    if (self.isLoadingGif) {
        [self yj_setLoadingGifViewShow:YES];
    }else{
        [self yj_setLoadingViewShow:YES];
    }
    __weak typeof(self) weakSelf = self;
    [self.dataModel yj_loadDataWithSuccess:^(BOOL noData) {
        if (noData) {
            if (weakSelf.yj_searchNodata) {
                [weakSelf yj_setNoDataViewShow:YES isSearch:YES];
            }else{
                [weakSelf yj_setNoDataViewShow:YES];
            }
        }else{
            if (weakSelf.isLoadingGif) {
                [weakSelf yj_setLoadingGifViewShow:NO];
            }else{
                [weakSelf yj_setLoadingViewShow:NO];
            }
            if (completion) {
                completion(YES);
            }
            [weakSelf yj_updateData];
        }
    } failed:^(NSError *error) {
        [weakSelf yj_setLoadErrorViewShow:YES];
        weakSelf.yj_loadErrorTitle = error.localizedDescription;
        if (completion) {
            completion(NO);
        }
    }];
}
- (void)yj_updateData{
    
}
- (void)yj_loadErrorUpdate{
    if (self.isLoadingGif) {
        [self yj_loadGifData];
    }else{
        [self yj_loadData];
    }
}
#pragma mark - Setter
- (void)setYj_loadingGifTitle:(NSString *)yj_loadingGifTitle{
    _yj_loadingGifTitle = yj_loadingGifTitle;
    self.loadingGifLab.text = yj_loadingGifTitle;
}
- (void)setYj_loadingFlowerTitle:(NSString *)yj_loadingFlowerTitle{
    _yj_loadingFlowerTitle = yj_loadingFlowerTitle;
    self.loadingFlowerLab.text = yj_loadingFlowerTitle;
}
- (void)setYj_noDataTitle:(NSString *)yj_noDataTitle{
    _yj_noDataTitle = yj_noDataTitle;
    self.noDataLab.text = yj_noDataTitle;
}
- (void)setYj_loadErrorTitle:(NSString *)yj_loadErrorTitle{
    _yj_loadErrorTitle = yj_loadErrorTitle;
    self.loadErrorLab.text = yj_loadErrorTitle;
}
- (void)setSearchEmpty:(BOOL)isSearchEmpty{
    self.noDataImgView.hidden = isSearchEmpty;
    self.noDataSearchImgView.hidden = !self.noDataImgView.hidden;
    if (isSearchEmpty) {
        self.noDataLab.text = [YJBManager defaultManager].searchEmptyTitle;
    }else{
        self.noDataLab.text = [YJBManager defaultManager].loadEmptyTitle;
    }
}
#pragma mark - Loading
- (void)yj_setLoadingViewShow:(BOOL)show{
    [self yj_setLoadingViewShow:show backgroundColor:self.view.backgroundColor tintColor:[YJBManager defaultManager].loadingColor];
}
- (void)yj_setLoadingViewShow:(BOOL)show backgroundColor:(UIColor *)backgroundColor tintColor:(nonnull UIColor *)tintColor{
    [self resetLoadingView];
    self.loadingView.backgroundColor = backgroundColor;
    self.activityIndicatorView.tintColor = tintColor;
    [self setShowOnBackgroundView:self.loadingView show:show];
}
- (void)yj_setLoadingGifViewShow:(BOOL)show{
    [self resetLoadingView];
     [self setShowOnBackgroundView:self.loadingGifView show:show];
}
- (void)yj_setLoadingFlowerTitleViewShow:(BOOL)show{
    [self resetLoadingView];
     [self setShowOnBackgroundView:self.loadingFlowerView show:show];
}

- (void)yj_setNoDataViewShow:(BOOL)show{
    [self yj_setNoDataViewShow:show isSearch:NO belowView:nil];
}
- (void)yj_setNoDataViewShow:(BOOL)show isSearch:(BOOL)isSearch{
    [self yj_setNoDataViewShow:show isSearch:isSearch belowView:nil];
}
- (void)yj_setNoDataViewShow:(BOOL)show belowView:(UIView *)belowView{
     [self yj_setNoDataViewShow:show isSearch:NO belowView:belowView];
}
- (void)yj_setNoDataViewShow:(BOOL)show isSearch:(BOOL)isSearch belowView:(nullable UIView *)belowView{
    [self resetLoadingView];
    [self setSearchEmpty:isSearch];
    [self setShowOnBackgroundView:self.noDataView show:show];
}

- (void)yj_setLoadErrorViewShow:(BOOL)show{
    [self resetLoadingView];
    [self setShowOnBackgroundView:self.loadErrorView show:show];
}
- (void)setShowOnBackgroundView:(UIView *)aView show:(BOOL)show{
    [self setShowOnBackgroundView:aView show:show belowView:nil];
}
- (void)setShowOnBackgroundView:(UIView *)aView show:(BOOL)show belowView:(UIView *)belowView{
    if (!aView) {
        return;
    }
    if (show) {
        if (aView.superview) {
            [aView removeFromSuperview];
        }
        if (belowView) {
            [self.view insertSubview:aView belowSubview:belowView];
        }else{
            [self.view addSubview:aView];
            [self.view bringSubviewToFront:aView];
        }
        [aView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(self.yj_loadingViewTopSpace);
            make.centerX.left.bottom.equalTo(self.view);
        }];
    }else{
        [aView removeFromSuperview];
    }
}
- (void)resetLoadingView{
    [self.loadingView removeFromSuperview];
    [self.loadingGifView removeFromSuperview];
    [self.loadingFlowerView removeFromSuperview];
    
    [self.noDataView removeFromSuperview];
    [self.loadErrorView removeFromSuperview];
    
}
- (UIView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[UIView alloc]init];
        _loadingView.backgroundColor = self.view.backgroundColor;
        
        [_loadingView addSubview:self.activityIndicatorView];
        [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.loadingView);
            make.width.height.mas_equalTo(100);
        }];
        [self.activityIndicatorView startAnimating];
    }
    return _loadingView;
}
- (UIView *)loadingGifView{
    if (!_loadingGifView) {
        _loadingGifView = [[UIView alloc]init];
        _loadingGifView.backgroundColor = self.view.backgroundColor;
        
        UIImageView *gifImageView = [[UIImageView alloc]  initWithFrame:CGRectZero];
        gifImageView.animationImages = [YJBManager defaultManager].loadingImgs;
        gifImageView.animationDuration = [YJBManager defaultManager].loadingImgs.count * 0.05;
        [gifImageView startAnimating];
        
        [_loadingGifView addSubview:gifImageView];

        [gifImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.loadingGifView);
            make.centerY.equalTo(self.loadingGifView).offset(-10);
            make.width.mas_equalTo(140);
            make.height.equalTo(gifImageView.mas_width).multipliedBy(1.01);
        }];
        
        [_loadingGifView addSubview:self.loadingGifLab];
        [self.loadingGifLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.width.equalTo(self.loadingGifView);
            make.top.equalTo(gifImageView.mas_bottom).offset(10);
        }];
    }
    return _loadingGifView;
}

- (UIView *)loadingFlowerView{
    if (!_loadingFlowerView) {
        _loadingFlowerView = [[UIView alloc]init];
        _loadingFlowerView.backgroundColor = [UIColor whiteColor];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.color = [YJBManager defaultManager].loadingFlowerColor;
        [_loadingFlowerView addSubview:self.loadingFlowerLab];
        [self.loadingFlowerLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.loadingFlowerView);
            make.centerX.equalTo(self.loadingFlowerView).offset(12);
        }];
        [_loadingFlowerView addSubview:indicatorView];
        [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.loadingFlowerLab);
            make.right.equalTo(self.loadingFlowerLab.mas_left).offset(-5);
        }];
        [indicatorView startAnimating];
    }
    return _loadingFlowerView;
}

- (UIView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]init];
        _noDataView.backgroundColor = self.view.backgroundColor;
        
        [_noDataView addSubview:self.noDataImgView];

        [self.noDataImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.noDataView);
            make.centerY.equalTo(self.noDataView).offset(self.yj_noDataImgOffsetY);
        }];
        
        [_noDataView addSubview:self.noDataSearchImgView];
        
        [self.noDataSearchImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.noDataView);
            make.centerY.equalTo(self.noDataView).offset(self.yj_noDataSearchImgOffsetY);
        }];
        self.noDataSearchImgView.hidden = YES;
        [_noDataView addSubview:self.noDataLab];
        [self.noDataLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.noDataView);
            make.left.equalTo(self.noDataView).offset(20);
            make.top.equalTo(self.noDataImgView.mas_bottom).offset(18);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yj_loadErrorUpdate)];
        [_noDataView addGestureRecognizer:tap];
    }
    return _noDataView;
}
- (UIView *)loadErrorView{
    if (!_loadErrorView) {
        _loadErrorView = [[UIView alloc]init];
        _loadErrorView.backgroundColor = self.view.backgroundColor;
        UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage yj_imageNamed:[YJBManager defaultManager].loadErrorImgName atDir:@"Error" atBundle:[YJBManager defaultManager].currentBundle]];
        [_loadErrorView addSubview:img];
        [img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.loadErrorView);
            make.centerY.equalTo(self.loadErrorView).offset(self.yj_loadErrorImgOffsetY);
        }];
        [_loadErrorView addSubview:self.loadErrorLab];
        [self.loadErrorLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.loadErrorView);
            make.left.equalTo(self.loadErrorView).offset(20);
            make.top.equalTo(img.mas_bottom).offset(18);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yj_loadErrorUpdate)];
        [_loadErrorView addGestureRecognizer:tap];
    }
    return _loadErrorView;
}
- (YJActivityIndicatorView *)activityIndicatorView{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[YJActivityIndicatorView alloc] initWithType:YJActivityIndicatorAnimationTypeBallPulse tintColor:[YJBManager defaultManager].loadingColor];
    }
    return _activityIndicatorView;
}
- (UILabel *)loadingGifLab{
    if (!_loadingGifLab) {
        _loadingGifLab = [[UILabel alloc]init];
        _loadingGifLab.font = [UIFont systemFontOfSize:[YJBManager defaultManager].loadingGifTitleSize];
        _loadingGifLab.textAlignment = NSTextAlignmentCenter;
        _loadingGifLab.textColor = [YJBManager defaultManager].loadingGifTitleColor;
        _loadingGifLab.text = [YJBManager defaultManager].loadingGifTitle;
    }
    return _loadingGifLab;
}
- (UILabel *)loadingFlowerLab{
    if (!_loadingFlowerLab) {
        _loadingFlowerLab = [[UILabel alloc]init];
        _loadingFlowerLab.font = [UIFont systemFontOfSize:[YJBManager defaultManager].loadingFlowerTitleSize];
        _loadingFlowerLab.textAlignment = NSTextAlignmentCenter;
        _loadingFlowerLab.textColor = [YJBManager defaultManager].loadingFlowerTitleColor;
        _loadingFlowerLab.text = [YJBManager defaultManager].loadingFlowerTitle;
    }
    return _loadingFlowerLab;
}
- (UILabel *)noDataLab{
    if (!_noDataLab) {
        _noDataLab = [[UILabel alloc]init];
        _noDataLab.font = [UIFont systemFontOfSize:[YJBManager defaultManager].loadEmptyTitleSize];
        _noDataLab.numberOfLines = 3;
        _noDataLab.textAlignment = NSTextAlignmentCenter;
        _noDataLab.textColor = [YJBManager defaultManager].loadEmptyTitleColor;
        _noDataLab.text = [YJBManager defaultManager].loadEmptyTitle;
    }
    return _noDataLab;
}
- (UIImageView *)noDataImgView{
    if (!_noDataImgView) {
        _noDataImgView = [[UIImageView alloc] initWithImage:[UIImage yj_imageNamed:[YJBManager defaultManager].loadEmptyImgName atDir:@"Empty" atBundle:[YJBManager defaultManager].currentBundle]];
    }
    return _noDataImgView;
}

- (UIImageView *)noDataSearchImgView{
    if (!_noDataSearchImgView) {
        _noDataSearchImgView = [[UIImageView alloc] initWithImage:[UIImage yj_imageNamed:[YJBManager defaultManager].searchEmptyImgName atDir:@"SearchEmpty" atBundle:[YJBManager defaultManager].currentBundle]];
    }
    return _noDataSearchImgView;
}

- (UILabel *)loadErrorLab{
    if (!_loadErrorLab) {
        _loadErrorLab = [[UILabel alloc]init];
        _loadErrorLab.font = [UIFont systemFontOfSize:[YJBManager defaultManager].loadErrorTitleSize];
        _loadErrorLab.numberOfLines = 3;
        _loadErrorLab.textAlignment = NSTextAlignmentCenter;
        _loadErrorLab.textColor = [YJBManager defaultManager].loadErrorTitleColor;
        _loadErrorLab.text = [YJBManager defaultManager].loadErrorTitle;
    }
    return _loadErrorLab;
}

@end

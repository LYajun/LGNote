//
//  LGBaseTableView.m
//  LGAssistanter
//
//  Created by hend on 2018/5/17.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "LGNoteBaseTableView.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import "LGNoteConfigure.h"
#import "LGNoteMBAlert.h"
#import "NSBundle+Notes.h"
@interface LGNoteBaseTableView () <UIGestureRecognizerDelegate>

/** 加载中 */
//@property (nonatomic, strong) UIView *viewLoading;

/** 错误 */
@property (nonatomic, strong) UIView *viewError;
@end

@implementation LGNoteBaseTableView

- (void)dealloc{
    NSLog(@"%@ 释放了",NSStringFromClass([self class]));
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        [self allocInitRefreshHeader:NO allocInitFooter:NO];
        [self setDefaultValue];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setDefaultValue];
}

- (void)setDefaultValue{
    self.backgroundColor = kColorBackgroundGray;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)lg_bindViewModel:(id)viewModel{
    
}

- (void)allocInitRefreshHeader:(BOOL)header allocInitFooter:(BOOL)footer{
    
    weakSelf(wSelf);
    if (header) {
        self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            if (wSelf.cusDelegate && [wSelf.cusDelegate respondsToSelector:@selector(baseTableView:pullUpRefresh:pullDownRefresh:)]) {
                [wSelf.cusDelegate baseTableView:self pullUpRefresh:YES pullDownRefresh:NO];
            }
        }];
        ((MJRefreshNormalHeader *)self.mj_header).lastUpdatedTimeLabel.hidden = YES;
    } else {
        [self.mj_header removeFromSuperview];
        self.mj_header = nil;
    }
    
    if (footer) {
        self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            if (wSelf.cusDelegate && [wSelf.cusDelegate respondsToSelector:@selector(baseTableView:pullUpRefresh:pullDownRefresh:)]) {
                [self.cusDelegate baseTableView:self pullUpRefresh:NO pullDownRefresh:YES];
            }
        }];
        // 设置文字
        [(MJRefreshAutoNormalFooter *)self.mj_footer setTitle:@"上拉加载更多 ..." forState:MJRefreshStateIdle];
        [(MJRefreshAutoNormalFooter *)self.mj_footer setTitle:@"正在拼命加载 ..." forState:MJRefreshStateRefreshing];
        [(MJRefreshAutoNormalFooter *)self.mj_footer setTitle:@"已全部加载" forState:MJRefreshStateNoMoreData];
        // 设置字体
        ((MJRefreshAutoNormalFooter *)self.mj_footer).stateLabel.font = [UIFont systemFontOfSize:15];
        // 设置颜色
        ((MJRefreshAutoNormalFooter *)self.mj_footer).stateLabel.textColor = [UIColor lightGrayColor];
//        ((MJRefreshAutoNormalFooter *)self.mj_footer).automaticallyHidden = YES;
    } else {
        [self.mj_footer removeFromSuperview];
        self.mj_footer = nil;
    }
}


#pragma mark - setter
- (void)setRequestStatus:(LGBaseTableViewRequestStatus)requestStatus{
    _requestStatus = requestStatus;
    [self tableViewShowRequestStatus];
}

- (void)tableViewShowRequestStatus {
    switch (self.requestStatus) {
        case LGBaseTableViewRequestStatusStartLoading:{
            
           
            [kMBAlert showIndeterminateWithStatus:@"正在加载..."];
            
           
            [self tableViewShowStartLoading];
        }
            break;
            case LGBaseTableViewRequestDeleteLoading:{
                       
                      
                       [kMBAlert showIndeterminateWithStatus:@"删除中..."];
                       
                      
                       [self tableViewShowStartLoading];
                   }
                       break;
            case LGBaseTableViewRequestSearchLoading:{
                                  
                                 
            [kMBAlert showIndeterminateWithStatus:@"搜索中..."];
                                  
                                 
                                  [self tableViewShowStartLoading];
                              }
                                  break;
        case LGBaseTableViewRequestStatusNormal:{
            _tipsStr=@"";
            [kMBAlert hide];
            [self tableViewShowStartLoading];
            [self tableViewShowEndLoading];
        }
            break;
            // 以下几种情况先统一不做处理，看需求
        case LGBaseTableViewRequestStatusNoData:
        case LGBaseTableViewRequestStatusNoNetwork:
        case LGBaseTableViewRequestStatusOverTime:{
             _tipsStr=@"";
            [kMBAlert hide];
            [self tableViewShowEndLoading];
            self.viewError.hidden = NO;
        [self showRequestOnView:self.viewError];
//
            
            
//            if (kNetwork.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
//                self.errorInfoLabel.text = @"请检查网络是否正常";
//            } else {
//            }
        }
            break;
    }
}

- (void)tableViewShowEndLoading{
//    self.viewLoading.hidden = YES;
    self.scrollEnabled = YES;
    [self.mj_footer endRefreshing];
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshingWithNoMoreData];
}

- (void)tableViewShowStartLoading{
    self.viewError.hidden = YES;
//    self.viewLoading.hidden = NO;
    self.scrollEnabled = NO;
//    [self bringSubviewToFront:self.viewLoading];
}

- (void)showRequestOnView:(UIView *)view{
    
    if (!view) {
        return;
    }
    if (view.superview) {
        [view removeFromSuperview];
    }
    //    self.scrollEnabled = NO;
    [self addSubview:view];
    [self bringSubviewToFront:view];

    [self layoutIfNeeded];
    CGSize size = CGSizeEqualToSize(self.bounds.size, CGSizeZero) ? CGSizeMake(kMain_Screen_Width, kMain_Screen_Height*0.6) : self.bounds.size;
    view.frame = CGRectMake(0, 0, size.width, size.height+64);
    [self setContentOffset:CGPointZero animated:NO];
}

#pragma mark - lazy
- (UIView *)viewError{
    if (!_viewError) {
        
        _viewError = [[UIView alloc] init];
        [self addSubview:_viewError];
        [_viewError mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
         make.size.mas_equalTo(CGSizeMake(kMain_Screen_Width, kMain_Screen_Height));
        }];

        [self setContentOffset:CGPointZero animated:NO];
        _viewError.backgroundColor = kColorBackgroundGray;
        
        _errorImageView  = [[UIImageView alloc] init];
        [_viewError addSubview:_errorImageView];
   
        if(_isNotoSearchVC){
                _errorImageView.image = [NSBundle lg_imagePathName:@"NoSearchResult"];
        }else{
                 _errorImageView.image = [NSBundle lg_imagePathName:@"lg_empty"];
        }

        if(IS_PAD){
            
            [_errorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.viewError);
                      
                  make.width.mas_equalTo(kMain_Screen_Width/3);
                      make.height.mas_equalTo(kMain_Screen_Width/4);
                  make.top.equalTo(self.viewError).offset(kMain_Screen_Height/2-64-49);
                      
                  }];
        }else{
            
            [_errorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.viewError);
                      
            make.top.equalTo(self.viewError).offset(kMain_Screen_Height/2-64-49);
                      
                  }];
        }
        
      
        
        
        
        _errorInfoLabel = [[UILabel alloc] init];
        _errorInfoLabel.textAlignment = NSTextAlignmentCenter;
        if(_isNotoSearchVC){
              _errorInfoLabel.text = @"暂无搜索内容";
            
        }else{
            
            _errorInfoLabel.text = @"暂无笔记";
        }
   
        _errorInfoLabel.textColor = kLabelColorLightGray;
        if(IS_PAD){
            
             _errorInfoLabel.font = kSYSTEMFONT(20.f);
        }else{
             _errorInfoLabel.font = kSYSTEMFONT(14.f);
        }
        
        //_errorInfoLabel.font = kSYSTEMFONT(14.f);
        [_viewError addSubview:_errorInfoLabel];
        [_errorInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.errorImageView.mas_bottom).offset(15);
            make.centerX.equalTo(self.viewError);
        }];
    }
    return _viewError;
}




@end

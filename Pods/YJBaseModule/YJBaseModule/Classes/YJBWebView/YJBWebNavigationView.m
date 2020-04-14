//
//  YJBWebNavigationView.m
//  YJBaseModule
//
//  Created by 刘亚军 on 2019/9/12.
//

#import "YJBWebNavigationView.h"
#import "YJBMarqueeLabel.h"
#import <Masonry/Masonry.h>
#import "YJBManager.h"
#import <YJExtensions/YJExtensions.h>


@interface YJBWebNavigationView ()
@property (nonatomic,strong) UIButton *backBtn;
@property (nonatomic,strong) YJBMarqueeLabel *titleLab;
@end
@implementation YJBWebNavigationView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor yj_colorWithHex:0xE6E6E6];
        
        [self addSubview:self.backBtn];
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.top.left.equalTo(self);
            make.width.mas_equalTo(44);
        }];
        
        [self addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.top.equalTo(self);
            make.left.equalTo(self.backBtn.mas_right).offset(10);
            make.right.equalTo(self).offset(-10);
        }];
        
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor yj_colorWithHex:0xcccccc];
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.centerX.bottom.equalTo(self);
            make.width.mas_equalTo(1);
        }];
    }
    return self;
}
- (void)setTitleStr:(NSString *)titleStr{
    _titleStr = self.titleLab.text = titleStr;
}
- (void)backAction{
    if (self.backBlock) {
        self.backBlock();
    }
}
- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage yj_imageNamed:@"back" atDir:@"Other" atBundle:[YJBManager defaultManager].currentBundle] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
- (YJBMarqueeLabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[YJBMarqueeLabel alloc] initWithFrame:CGRectZero rate:10 andFadeLength:5];
        _titleLab.animationDelay = 2.0;
        _titleLab.font = [UIFont systemFontOfSize:18];
        _titleLab.textColor = [UIColor darkGrayColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.trailingBuffer = 24;
        _titleLab.marqueeType = YJBContinuous;
    }
    return _titleLab;
}
@end

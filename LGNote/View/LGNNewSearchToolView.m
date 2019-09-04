//
//  LGNNewSearchToolView.m
//  NoteDemo
//
//  Created by abc on 2019/8/21.
//  Copyright © 2019 hend. All rights reserved.
//

#import "LGNNewSearchToolView.h"

#import "LGNoteBaseTextField.h"
#import "LGNoteConfigure.h"
#import "LGNConfigure.h"
#import "NSBundle+Notes.h"

@interface LGNNewSearchToolView()
@property (nonatomic, strong, readwrite) LGNoteBaseTextField *searchBar;
@property (nonatomic, strong, readwrite) UIButton *enterSearchBtn;
@property (nonatomic, strong, readwrite) LGNSearchToolViewConfigure *configure;

@property (nonatomic,strong) UIImageView * bgImageView;
@property (nonatomic,strong) UIImageView * tipsImageView;

@end

@implementation LGNNewSearchToolView

- (instancetype)initWithFrame:(CGRect)frame configure:(LGNSearchToolViewConfigure *)configure{
    if (self = [super initWithFrame:frame]) {
        _configure = configure;
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews{
    [self addSubview:self.bgImageView];
    [self addSubview:self.tipsImageView];
    [self addSubview:self.seleteBtn];
    [self addSubview:self.searchBar];
    [self addSubview:self.enterSearchBtn];
    [self addSubview:self.filterBtn];
    
    
    [self setupSubviewsContraints];
}
- (void)setupSubviewsContraints{
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self);
    }];
    
    
    [self.tipsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.height.mas_offset(18);
        make.width.mas_offset(18);
    }];
    
    [self.seleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipsImageView.mas_right).offset(4);
        make.centerY.equalTo(self);
        make.height.mas_offset(20);
        make.width.mas_offset(67);
    }];
    
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.seleteBtn.mas_right).offset(1);
        make.right.equalTo(self.filterBtn.mas_left).offset(-8);
        make.centerY.equalTo(self);
        make.height.mas_offset(27);
    }];
    [self.enterSearchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.searchBar);
    }];
    
    [self.filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(21, 21));
    }];
    
  
}

- (void)enterSearchBtnClick:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(NewenterSearchEvent)]) {
        [self.delegate NewenterSearchEvent];
    }
}

- (void)remarkBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(NewSeleteEvent:)]) {
        [self.delegate NewSeleteEvent:sender.selected];
    }
}

- (void)filterBtnClick:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(NewfilterEvent)]) {
        [self.delegate NewfilterEvent];
    }
}
#pragma mark - layzy

- (UIImageView *)bgImageView{
    
    if(!_bgImageView){
        
        _bgImageView = [[UIImageView alloc]init];
        
//        if(NoteiPhoneXs){
//            _bgImageView.image = [NSBundle lg_imagePathName:@"note_navi_Xs"];
//        }else{
            _bgImageView.image = [NSBundle lg_imagePathName:@"note_navi"];
//        }
      
        
    }
    
    return _bgImageView;
}

- (UIImageView *)tipsImageView{
    
    if(!_tipsImageView){
        
        _tipsImageView = [[UIImageView alloc]init];
        
        _tipsImageView.image = [NSBundle lg_imagePathName:@"lgN_timesift"];
        
    }
    
    return _tipsImageView;
}


- (UIButton *)seleteBtn{
    if (!_seleteBtn) {
        _seleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _seleteBtn.frame = CGRectZero;
        [_seleteBtn setTitle:@"全   部" forState:UIControlStateNormal];
        _seleteBtn.titleLabel.font = LGFontSize(13);
        _seleteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        

        [_seleteBtn setImage:[NSBundle lg_imagePathName:@"lgN_pull"] forState:UIControlStateNormal];
        [_seleteBtn setImage:[NSBundle lg_imagePathName:@"lgN_up"] forState:UIControlStateSelected];
        
        _seleteBtn.imageEdgeInsets= UIEdgeInsetsMake(0, 47, 0, 0);
        _seleteBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 10);
        [_seleteBtn addTarget:self action:@selector(remarkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _seleteBtn;
}

- (UIButton *)enterSearchBtn{
    if (!_enterSearchBtn) {
        _enterSearchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _enterSearchBtn.frame = CGRectZero;
        [_enterSearchBtn setBackgroundColor:[UIColor clearColor]];
        [_enterSearchBtn addTarget:self action:@selector(enterSearchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterSearchBtn;
}


- (UIButton *)filterBtn{
    if (!_filterBtn) {
        _filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _filterBtn.frame = CGRectZero;
        [_filterBtn setImage:[NSBundle lg_imagePathName:@"lgN_mroebg"] forState:UIControlStateNormal];
        [_filterBtn addTarget:self action:@selector(filterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterBtn;
}


- (LGNoteBaseTextField *)searchBar{
    if (!_searchBar) {
        _searchBar = [[LGNoteBaseTextField alloc] init];
        _searchBar.layer.cornerRadius = 12;
        _searchBar.layer.masksToBounds = YES;
        _searchBar.borderStyle = UITextBorderStyleNone;
        _searchBar.placeholder = @"请输入笔记标题/来源搜索";
        [_searchBar setValue:kColorInitWithRGB(153, 153, 153, 1) forKeyPath:@"_placeholderLabel.textColor"];
        _searchBar.backgroundColor = kColorInitWithRGB(255, 255, 255, 1);
        _searchBar.userInteractionEnabled = NO;
        _searchBar.leftImageView.image = [NSBundle lg_imageName:@"lg_Newsearch"];
    }
    return _searchBar;
}


@end

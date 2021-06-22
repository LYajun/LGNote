//
//  YJNewNoteMarqueeButton.m
//  LGKnowledgeFramework
//
//  Created by 刘亚军 on 2019/10/31.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "YJNewNoteMarqueeButton.h"
#import <YJExtensions/YJExtensions.h>
#import <Masonry/Masonry.h>
#import "YJNewNoteManager.h"

@interface YJNewNoteMarqueeButton ()
@property (nonatomic,strong) UIButton *imgBtn;
@property (nonatomic,strong) UIButton *clickBtn;
@property (nonatomic,strong) YJNewNoteMarqueeLabel *titleLabel;
@end
@implementation YJNewNoteMarqueeButton
- (instancetype)initWithFrame:(CGRect)frame isLeftTitle:(BOOL)isLeftTitle{
    if (self = [super initWithFrame:frame]) {
        if (isLeftTitle) {
            [self addSubview:self.imgBtn];
            [self.imgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self);
                make.centerY.equalTo(self);
                make.left.equalTo(self);
                make.width.equalTo(self.imgBtn.mas_height);
            }];
            
            
            [self addSubview:self.titleLabel];
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self);
                make.centerY.top.equalTo(self);
                make.left.equalTo(self.imgBtn.mas_right);
            }];
            
            [self addSubview:self.clickBtn];
            [self.clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.left.equalTo(self.imgBtn);
                make.right.equalTo(self.titleLabel);
            }];
            
        }else{
            [self addSubview:self.imgBtn];
            [self.imgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self);
                make.centerY.equalTo(self);
                make.right.equalTo(self);
                make.width.equalTo(self.imgBtn.mas_height);
            }];
            
            
            [self addSubview:self.titleLabel];
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.centerY.top.equalTo(self);
                make.right.equalTo(self.imgBtn.mas_left);
            }];
            
            [self addSubview:self.clickBtn];
            [self.clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.left.equalTo(self.titleLabel);
                make.right.equalTo(self.imgBtn);
            }];
        }
        
    }
    return self;
}
- (void)dealloc{
    [self.titleLabel invalidateTimer];
}
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [self.clickBtn addTarget:target action:action forControlEvents:UIControlEventAllEvents];
}
- (void)setSelected:(BOOL)selected{
    _selected = selected;
    self.imgBtn.selected = selected;
}
- (UIButton *)clickBtn{
    if (!_clickBtn) {
        _clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _clickBtn;
}
- (UIButton *)imgBtn{
    if (!_imgBtn) {
        _imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_imgBtn setImage:[UIImage yj_imageNamed:@"kc_btn_video" atBundle:YJNewNoteManager.defaultManager.noteBundle] forState:UIControlStateNormal];
        [_imgBtn setImage:[UIImage yj_animatedImageNamed:@"kc_btn__video_gif" atDir:@"" duration:1 atBundle:YJNewNoteManager.defaultManager.noteBundle] forState:UIControlStateSelected];
        _imgBtn.userInteractionEnabled = NO;
    }
    return _imgBtn;
}
- (YJNewNoteMarqueeLabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[YJNewNoteMarqueeLabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.speed = 0.1f;
        _titleLabel.secondLabelInterval = 10;
    }
    return _titleLabel;
}
@end

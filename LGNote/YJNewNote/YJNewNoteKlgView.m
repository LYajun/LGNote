//
//  YJNewNoteKlgView.m
//  LGAlertHUD
//
//  Created by 刘亚军 on 2020/4/9.
//

#import "YJNewNoteKlgView.h"
#import <Masonry/Masonry.h>
#import <YJExtensions/YJExtensions.h>
#import "YJNewNoteMarqueeLabel.h"
#import "YJNewNoteMarqueeButton.h"
#import <YJUtils/YJAudioPlayer.h>
#import <LGAlertHUD/LGAlertHUD.h>
#import "YJNewNoteManager.h"

@interface YJNewNoteKlgView ()<YJAudioPlayerDelegate>
@property (nonatomic,strong) YJNewNoteMarqueeLabel *klgLab;
@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) UITextView *klgTextView;
@property (nonatomic,strong) YJNewNoteMarqueeButton *usBtn;
@property (nonatomic,strong) YJNewNoteMarqueeButton *unBtn;
@property (nonatomic,strong) YJAudioPlayer *audioPlayer;
@end
@implementation YJNewNoteKlgView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}
- (void)layoutUI{
    [self addSubview:self.klgLab];
    [self.klgLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).offset(35);
        make.right.equalTo(self).offset(-10);
        make.height.mas_equalTo(35);
    }];
    [self addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.klgLab).offset(2);
        make.right.equalTo(self.klgLab.mas_left);
        make.left.equalTo(self).offset(10);
    }];
    
    [self addSubview:self.usBtn];
   [self.usBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(self.klgLab.mas_bottom).offset(10);
       make.left.equalTo(self.titleLab).offset(-3);
       make.height.mas_equalTo(26);
       make.width.lessThanOrEqualTo(self).multipliedBy(0.42);
   }];
   
   [self addSubview:self.unBtn];
   [self.unBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       if (IsStrEmpty([YJNewNoteManager defaultManager].US_voice)) {
           make.left.equalTo(self.titleLab).offset(-3);;
       }else{
           make.left.equalTo(self.usBtn.mas_right).offset(20);
       }
       make.bottom.height.equalTo(self.usBtn);
       make.width.lessThanOrEqualTo(self).multipliedBy(0.42);
   }];
    self.usBtn.hidden = IsStrEmpty([YJNewNoteManager defaultManager].US_voice);
    self.unBtn.hidden = IsStrEmpty([YJNewNoteManager defaultManager].UN_voice);
    
    [self addSubview:self.klgTextView];
    [self.klgTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (IsStrEmpty([YJNewNoteManager defaultManager].US_voice) && IsStrEmpty([YJNewNoteManager defaultManager].UN_voice)) {
            make.top.equalTo(self.klgLab.mas_bottom).offset(10);
        }else{
            make.top.equalTo(self.usBtn.mas_bottom).offset(10);
        }
        make.left.equalTo(self.titleLab).offset(-3);
        make.right.equalTo(self.klgLab);
        make.bottom.equalTo(self);
    }];
    self.klgTextView.hidden = !([YJNewNoteManager defaultManager].ExplainAttr && !IsStrEmpty([YJNewNoteManager defaultManager].ExplainAttr.string));
    if ([YJNewNoteManager defaultManager].ExplainAttr && !IsStrEmpty([YJNewNoteManager defaultManager].ExplainAttr.string)) {
        NSMutableAttributedString *attr = [YJNewNoteManager defaultManager].ExplainAttr.mutableCopy;
        [attr yj_setFont:16];
        [attr yj_setColor:[UIColor yj_colorWithRed:37 green:37 blue:37]];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attr.length)];
        self.klgTextView.attributedText = attr;
    }
    self.usBtn.titleLabel.text = [@"美 " stringByAppendingString:(IsStrEmpty([YJNewNoteManager defaultManager].US_phonetic) ? @"":[YJNewNoteManager defaultManager].US_phonetic)];
    self.unBtn.titleLabel.text = [@"英 " stringByAppendingString:(IsStrEmpty([YJNewNoteManager defaultManager].UN_phonetic) ? @"":[YJNewNoteManager defaultManager].UN_phonetic)];
    
     self.klgLab.text = [YJNewNoteManager defaultManager].NoteTitle;
}

- (CGFloat)actualHeight{
    
    CGFloat btnHeight = 0;
    if (!IsStrEmpty([YJNewNoteManager defaultManager].US_voice) || !IsStrEmpty([YJNewNoteManager defaultManager].UN_voice)) {
        btnHeight = 10 + 26;
    }
    
    CGFloat textHeight = 0;
    if ([YJNewNoteManager defaultManager].ExplainAttr && !IsStrEmpty([YJNewNoteManager defaultManager].ExplainAttr.string)) {
        textHeight = 10 + [self.klgTextView.attributedText boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height+6;
        if (textHeight > 88) {
            textHeight = 88;
        }
    }
    return 35 + btnHeight + textHeight;
}
- (void)stopPlayVoice{
    [self.audioPlayer stop];
    self.usBtn.selected = NO;
    self.unBtn.selected = NO;
}
- (void)invalidatePlayer{
    self.usBtn.selected = NO;
    self.unBtn.selected = NO;
    [self.audioPlayer invalidate];
    [self.klgLab invalidateTimer];
}
- (void)unbtnClickAction{
    
    self.usBtn.selected = NO;
    [self.audioPlayer invalidate];
    self.audioPlayer.audioUrl = [YJNewNoteManager defaultManager].UN_voice;
    [self.audioPlayer play];
    self.unBtn.selected = YES;
}
- (void)usbtnClickAction{
    
    self.unBtn.selected = NO;
    [self.audioPlayer invalidate];
    self.audioPlayer.audioUrl =  [YJNewNoteManager defaultManager].US_voice;
    [self.audioPlayer play];
    self.usBtn.selected = YES;
}
#pragma mark - YJAudioPlayerDelegate
- (void)yj_audioPlayerDidPlayFailed{
    [LGAlert showErrorWithStatus:@"播放失败"];
    [self stopPlayVoice];
}
- (void)yj_audioPlayerDecodeError{
    [LGAlert showErrorWithStatus:@"播放失败"];
     [self stopPlayVoice];
}
- (void)yj_audioPlayerDidPlayComplete{
     [self stopPlayVoice];
}
- (void)yj_audioPlayerBeginInterruption{
     [self stopPlayVoice];
}

- (YJAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        _audioPlayer = [[YJAudioPlayer alloc] init];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}
- (YJNewNoteMarqueeButton *)unBtn{
    if (!_unBtn) {
        _unBtn = [[YJNewNoteMarqueeButton alloc] initWithFrame:CGRectZero isLeftTitle:YES];
        _unBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _unBtn.titleLabel.textColor = [UIColor yj_colorWithRed:152 green:152 blue:152];
        [_unBtn addTarget:self action:@selector(unbtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _unBtn;
}
- (YJNewNoteMarqueeButton *)usBtn{
    if (!_usBtn) {
        _usBtn = [[YJNewNoteMarqueeButton alloc] initWithFrame:CGRectZero isLeftTitle:YES];
        _usBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _usBtn.titleLabel.textColor = [UIColor yj_colorWithRed:152 green:152 blue:152];
        [_usBtn addTarget:self action:@selector(usbtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _usBtn;
}
- (UITextView *)klgTextView{
    if (!_klgTextView) {
        _klgTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _klgTextView.editable = NO;
        _klgTextView.selectable = NO;
        _klgTextView.textContainerInset = UIEdgeInsetsZero;//上下间距为零
       
    }
    return _klgTextView;
}
- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = [UIColor yj_colorWithRed:152 green:152 blue:152];
        _titleLab.text = @"ref:";
    }
    return _titleLab;
}
- (YJNewNoteMarqueeLabel *)klgLab{
    if (!_klgLab) {
        _klgLab = [[YJNewNoteMarqueeLabel alloc] init];
        _klgLab.font = [UIFont systemFontOfSize:18];
        _klgLab.textColor = [UIColor yj_colorWithRed:37 green:37 blue:37];
    }
    return _klgLab;
}
@end

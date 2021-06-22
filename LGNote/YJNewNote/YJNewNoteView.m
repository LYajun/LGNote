//
//  YJNewNoteView.m
//  YJNewNote_Example
//
//  Created by 刘亚军 on 2020/4/9.
//  Copyright © 2020 lyj. All rights reserved.
//

#import "YJNewNoteView.h"
#import <Masonry/Masonry.h>
#import <YJExtensions/YJExtensions.h>
#import "YJNewNoteKlgView.h"
#import "YJNewNoteDataModel.h"
#import "YJNewNoteTextView.h"
#import <LGAlertHUD/LGAlertHUD.h>

@interface YJNewNoteView ()<YJNewNoteTextViewDelegate>
@property(nonatomic,strong) YJNewNoteKlgView *klgView;
@property (nonatomic,strong) YJNewNoteTextView *textView;
@property (nonatomic,strong) UIView *mask;

@property (nonatomic,strong) UILabel *klgTextLab;
@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) UIButton *cancelBtn;
@property (nonatomic,strong) UIButton *saveBtn;
@property (nonatomic,strong) UILabel *remarkTitleLab;
@property (nonatomic,strong) UIButton *remarkBtn;
@property (nonatomic,strong) YJNewNoteDataModel *dataModel;
@property (nonatomic,assign) YJNewNoteType newNoteType;
@end

@implementation YJNewNoteView
- (instancetype)initWithFrame:(CGRect)frame newNoteType:(YJNewNoteType)newNoteType{
    if (self = [super initWithFrame:frame]) {
        [self layoutUIWithNewNoteType:newNoteType];
    }
    return self;
}
- (void)layoutUIWithNewNoteType:(YJNewNoteType)newNoteType{
    self.newNoteType = newNoteType;
    self.backgroundColor = [UIColor whiteColor];
    UIView *titleBgView = [UIView new];
    titleBgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:titleBgView];
     [titleBgView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.centerX.top.left.equalTo(self);
         make.height.mas_equalTo(44);
     }];
      [titleBgView yj_shadowWithWidth:0.1 borderColor:[UIColor yj_colorWithRed:235 green:235 blue:235] opacity:0.3 radius:0.3 offset:CGSizeMake(0, 0.5)];
      [titleBgView addSubview:self.titleLab];
      [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
          make.center.top.equalTo(titleBgView);
      }];
    
    [titleBgView addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.top.equalTo(titleBgView);
        make.left.equalTo(titleBgView).offset(10);
        make.width.mas_equalTo(40);
    }];
    [titleBgView addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.top.equalTo(titleBgView);
        make.right.equalTo(titleBgView).offset(-10);
        make.width.mas_equalTo(40);
    }];
    
    [self addSubview:self.remarkTitleLab];
    [self.remarkTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.top.equalTo(titleBgView.mas_bottom).offset(5);
        make.height.mas_equalTo(30);
    }];
    
    [self addSubview:self.remarkBtn];
    [self.remarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.remarkTitleLab);
        make.right.equalTo(self).offset(-10);
        make.width.height.mas_equalTo(28);
    }];
    
    UIView *botLine = [UIView new];
    botLine.backgroundColor = [UIColor yj_colorWithRed:240 green:240 blue:240];
    [self addSubview:botLine];
    [botLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remarkTitleLab.mas_bottom).offset(5);
        make.left.equalTo(self).offset(10);
        make.centerX.equalTo(self);
        make.height.mas_equalTo(0.8);
    }];
    
    
    if (newNoteType == YJNewNoteTypeKlg) {
        [self addSubview:self.klgView];
        [self.klgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.left.equalTo(self);
            make.top.equalTo(botLine.mas_bottom).offset(6);
            make.height.mas_equalTo([self.klgView actualHeight]);
        }];
    }else{
        
        [self addSubview:self.klgTextLab];
        [self.klgTextLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.top.equalTo(botLine.mas_bottom).offset(6);
            make.height.mas_equalTo(self.klgTextHeight);
        }];
    }
    
    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.left.equalTo(self);
        if (newNoteType == YJNewNoteTypeKlg) {
            make.top.equalTo(self.klgView.mas_bottom).offset(10);
        }else{
            make.top.equalTo(self.klgTextLab.mas_bottom).offset(10);
        }
        make.height.mas_equalTo(self.textViewOriginHeight);
    }];
    if ([YJNewNoteManager defaultManager].NoteContent && [YJNewNoteManager defaultManager].NoteContent.length > 0) {
        self.textView.text = [YJNewNoteManager defaultManager].NoteContent;
        [YJNewNoteManager defaultManager].NoteContent = @"";
    }
    [self bringSubviewToFront:titleBgView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewWillDidBeginEditingNoti:) name:YJNewNoteTextViewWillDidBeginEditingCursorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewWillDidEndEditingNoti:) name:YJNewNoteTextViewWillDidEndEditingNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundNoti) name:UIApplicationWillResignActiveNotification object:nil];
}
- (CGFloat)klgTextHeight{
    CGFloat height = [self.klgTextLab.attributedText boundingRectWithSize:CGSizeMake((LG_ScreenWidth-20), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height + 6;
    return height;
}
- (CGFloat)textViewOriginHeight{
    CGFloat infoHeight = 0;
     if (self.newNoteType == YJNewNoteTypeKlg) {
         infoHeight = self.klgView.actualHeight;
     }else{
         infoHeight = self.klgTextHeight;
     }
    
    return self.height - 44 - infoHeight - 20;
}
+ (void)showNewNoteViewOn:(UIView *)view newNoteType:(YJNewNoteType)newNoteType{
    CGFloat height = [view yj_customNavBarHeight] + 44 + (newNoteType == YJNewNoteTypeKlg ? 0 : 44);
    if (LG_ScreenWidth <= 375) {
        height =  [view yj_customNavBarHeight] + (newNoteType == YJNewNoteTypeKlg ? 0 : 40);
    }
    if ([view yj_isIPAD]) {
        height = [view yj_customNavBarHeight] + 88;
    }
    YJNewNoteView *noteView = [[YJNewNoteView alloc] initWithFrame:CGRectMake(0, LG_ScreenHeight, LG_ScreenWidth, (LG_ScreenHeight - height)) newNoteType:newNoteType];

   noteView.mask = [[UIView alloc] initWithFrame:view.bounds];
   noteView.mask.backgroundColor = [UIColor darkGrayColor];
   noteView.mask.alpha = 0.3;
//   UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:noteView action:@selector(hide)];
//   [noteView.mask addGestureRecognizer:tap];
   [view addSubview:noteView.mask];
   [view addSubview:noteView];
   [noteView show];
}

#pragma mark NSNotification action
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)enterBackgroundNoti{
    [self endEditing:YES];
}

- (void)textViewWillDidBeginEditingNoti:(NSNotification *) noti{
    NSDictionary *info = noti.userInfo;
    CGFloat overstep = [[info objectForKey:@"offset"] floatValue];
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.textViewOriginHeight-overstep);
    }];
}
- (void)textViewWillDidEndEditingNoti:(NSNotification *) noti{

    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.textViewOriginHeight);
    }];
}
- (BOOL)emptyText{
    
    NSString *text = self.textView.text;
    if (!IsStrEmpty(text) && IsStrEmpty([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        text = @"";
    }
    if (IsStrEmpty(text)) {
        return YES;
    }
    return NO;
}
- (void)cancelClickAction{
    [self.textView resignFirstResponder];
    if (!self.emptyText) {
        __weak typeof(self) weakSelf = self;
        [[YJLancooAlert lancooAlertWithTitle:@"温馨提示" msg:@"是否放弃此次编辑内容？" cancelTitle:@"我再想想" destructiveTitle:@"放弃" cancelBlock:^{
       } destructiveBlock:^{
           [weakSelf hide];
       }] show];
    }else{
        [self hide];
    }
}
- (void)saveClickAction{
    [self.textView resignFirstResponder];
    if (self.emptyText) {
        [LGAlert showInfoWithStatus:@"输入不能为空"];
    }else{
        self.dataModel.NoteContent = [self.textView.text yj_deleteWhitespaceAndNewlineCharacter];
        [LGAlert showIndeterminate];
        [self.dataModel uploadNoteDataWithComplete:^(BOOL isSuccess) {
            if (isSuccess) {
                [LGAlert showSuccessWithStatus:@"保存成功"];
                [self hide];
            }else{
                [LGAlert showErrorWithStatus:@"保存失败"];
            }
        }];
    }
}
- (void)remarkBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.dataModel.IsKeyPoint = @"1";
        [LGAlert showSuccessWithStatus:@"已标记为重点"];
    }else{
        self.dataModel.IsKeyPoint = @"0";
        [LGAlert showSuccessWithStatus:@"已取消标记"];
    }
}
- (void)show{
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.transform = CGAffineTransformMakeTranslation(0, - self.frame.size.height);
        
    } completion:^(BOOL finished) {
         [self.textView becomeFirstResponder];
    }];
}
- (void)hide{
    [self.klgView invalidatePlayer];
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.transform = CGAffineTransformMakeTranslation(0, LG_ScreenWidth + self.frame.size.height);
        self.mask.alpha = 0;
    } completion:^(BOOL isFinished) {
        [self.mask removeFromSuperview];
        [self removeFromSuperview];
    }];
}
- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = [UIFont systemFontOfSize:18];
        _titleLab.textColor = [UIColor yj_colorWithRed:37 green:37 blue:37];
        _titleLab.text = @"新建笔记";
    }
    return _titleLab;
}

- (UILabel *)klgTextLab{
    if (!_klgTextLab) {
        _klgTextLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _klgTextLab.numberOfLines = 0;
        NSMutableAttributedString *textTitleAtt = @"ref: ".yj_toMutableAttributedString;
        [textTitleAtt yj_setFont:16];
        [textTitleAtt yj_setColor:[UIColor yj_colorWithRed:152 green:152 blue:152]];
        NSMutableAttributedString *textAtt = [YJNewNoteManager defaultManager].NoteTitle.yj_toMutableAttributedString;
        [textAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, textAtt.length)];
        [textAtt yj_setColor:[UIColor yj_colorWithRed:37 green:37 blue:37]];
        [textTitleAtt appendAttributedString:textAtt];
        _klgTextLab.attributedText = textTitleAtt;
        
    }
    return _klgTextLab;
}
- (UILabel *)remarkTitleLab{
    if (!_remarkTitleLab) {
        _remarkTitleLab = [UILabel new];
        _remarkTitleLab.font = [UIFont systemFontOfSize:16];
        _remarkTitleLab.text = @"重点笔记";
        _remarkTitleLab.textColor = [UIColor yj_colorWithRed:37 green:37 blue:37];
    }
    return _remarkTitleLab;
}
- (YJNewNoteDataModel *)dataModel{
    if (!_dataModel) {
        _dataModel = [[YJNewNoteDataModel alloc] init];
    }
    return _dataModel;
}
- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor yj_colorWithRed:0 green:153 blue:255] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelBtn addTarget:self action:@selector(cancelClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}
- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor yj_colorWithRed:0 green:153 blue:255] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_saveBtn addTarget:self action:@selector(saveClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}
- (UIButton *)remarkBtn{
    if (!_remarkBtn) {
        _remarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_remarkBtn setImage:[UIImage yj_imageNamed:@"yjn_remark_unselected" atBundle:YJNewNoteManager.defaultManager.noteBundle] forState:UIControlStateNormal];
        [_remarkBtn setImage:[UIImage yj_imageNamed:@"yjn_remark_selected" atBundle:YJNewNoteManager.defaultManager.noteBundle] forState:UIControlStateSelected];
        [_remarkBtn addTarget:self action:@selector(remarkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _remarkBtn;
}
- (YJNewNoteKlgView *)klgView{
    if (!_klgView) {
        _klgView = [[YJNewNoteKlgView alloc] initWithFrame:CGRectZero];
    }
    return _klgView;
}
- (YJNewNoteTextView *)textView{
    if (!_textView) {
        _textView = [[YJNewNoteTextView alloc] initWithFrame:CGRectZero];
        [_textView setAutoCursorPosition:YES];
        _textView.placeholder = @"请输入笔记内容...";
        _textView.assistHeight = 44;
        _textView.font = [UIFont systemFontOfSize:17];
        _textView.textContainerInset = UIEdgeInsetsMake(10, 6, 0, 6);
        _textView.backgroundColor = [UIColor yj_colorWithRed:250 green:250 blue:250];
    }
    return _textView;
}
@end

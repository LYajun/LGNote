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
#import "LGNoteBaseTextView.h"
#import "LGNoteBaseTextField.h"
#import "CFMacro.h"
#import "LGNImagePickerViewController.h"
#import "LGNDrawBoardViewController.h"
#import "HPTextViewTapGestureRecognizer.h"

@interface YJNewNoteView ()<LGNoteBaseTextViewDelegate,LGNoteBaseTextFieldDelegate>
@property(nonatomic,strong) YJNewNoteKlgView *klgView;
@property (nonatomic,strong) LGNoteBaseTextField *titleTextField;
@property (nonatomic,strong) LGNoteBaseTextView *contentTextView;
@property (nonatomic, strong) NSMutableAttributedString *imgAttr;
@property (nonatomic, assign) NSInteger currentLocation;
@property (nonatomic, assign) BOOL isInsert;

@property (nonatomic,strong) UIView *mask;

@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) UIButton *cancelBtn;
@property (nonatomic,strong) UIButton *saveBtn;
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
    
    [self addSubview:self.titleTextField];
    [self.titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.top.equalTo(titleBgView.mas_bottom).offset(5);
        make.right.equalTo(self).offset(-50);
        make.height.mas_equalTo(30);
    }];
    
    [self addSubview:self.remarkBtn];
    [self.remarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleTextField);
        make.right.equalTo(self).offset(-10);
        make.width.height.mas_equalTo(28);
    }];
    
    UIView *botLine = [UIView new];
    botLine.backgroundColor = [UIColor yj_colorWithRed:240 green:240 blue:240];
    [self addSubview:botLine];
    [botLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleTextField.mas_bottom).offset(5);
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
    }
    
    [self addSubview:self.contentTextView];
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.centerX.left.equalTo(self);
        if (newNoteType == YJNewNoteTypeKlg) {
            make.top.equalTo(self.klgView.mas_bottom).offset(10);
        }else{
            make.top.equalTo(botLine.mas_bottom).offset(10);
        }
    }];
    if (self.dataModel.NoteContent_Att) {
        self.contentTextView.attributedText = self.dataModel.NoteContent_Att;
    }
    self.titleTextField.text = self.dataModel.NoteTitle;
    [self bringSubviewToFront:titleBgView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewKeyBoardDidShowNotification:) name:LGTextViewKeyBoardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewKeyBoardWillHiddenNotification:) name:LGTextViewKeyBoardWillHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postImageView:) name:LGNoteDrawBoardViewControllerFinishedDrawNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundNoti) name:UIApplicationWillResignActiveNotification object:nil];
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

- (void)textViewKeyBoardDidShowNotification:(NSNotification *)notification{
    [self.contentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-self.contentTextView.keyboardHeight);
    }];
}

- (void)textViewKeyBoardWillHiddenNotification:(NSNotification *)notification{
    [self.contentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.equalTo(self);
    }];
}
- (void)postImageView:(NSNotification *)notification{
    UIImage *image = notification.userInfo[@"image"];
    __weak typeof(self) weakSelf = self;
    [self.dataModel uploadNoteImg:image complete:^(NSString * _Nullable imgUrl) {
        if (!IsStrEmpty(imgUrl)) {
            weakSelf.contentTextView.placeholder=@"";
            [self settingImageAttributes:image imageFTPPath:imgUrl];
             [self.contentTextView becomeFirstResponder];
        }
    }];
}
- (void)settingImageAttributes:(UIImage *)image imageFTPPath:(NSString *)path{
   
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width - kNoteImageOffset;
    // 固定宽度
   width = width > screenW ? screenW:width;
    NSString *imgStr = [NSString stringWithFormat:@"<img src=\"%@\" width=\"%.f\" height=\"%.f\"/>",path,width,height];
    NSMutableAttributedString *currentAttr = [[NSMutableAttributedString alloc] initWithAttributedString:self.contentTextView.attributedText];
    self.imgAttr = imgStr.lg_changeforMutableAtttrubiteString;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6;// 字体的行间距
    NSDictionary *attributes = @{

                                 NSFontAttributeName:[UIFont systemFontOfSize:16],

                                 NSParagraphStyleAttributeName:paragraphStyle

                                 };

   [self.imgAttr addAttributes:attributes range:NSMakeRange(0, self.imgAttr.length)];
    [self.dataModel updateImageInfo:@{@"src":path,@"width":[NSString stringWithFormat:@"%.f",width],@"height":[NSString stringWithFormat:@"%.f",height]} imageAttr:self.imgAttr];
    self.currentLocation = [self.contentTextView offsetFromPosition:self.contentTextView.beginningOfDocument toPosition:self.contentTextView.selectedTextRange.start];
    [currentAttr insertAttributedString:self.imgAttr atIndex:self.currentLocation];
//    添加图片后加个行内容 方便输入
    [currentAttr insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n"] atIndex:currentAttr.length];
    self.contentTextView.attributedText = currentAttr;
    self.isInsert = YES;
    [self lg_textViewDidChange:self.contentTextView];
    
    
    NSRange rg = _contentTextView.selectedRange;
      rg.location = _contentTextView.text.length;
     _contentTextView.selectedRange = NSMakeRange(rg.location, 0);
    _contentTextView.font = [UIFont systemFontOfSize:16];
}

- (void)cancelClickAction{
    [self endCurrentEditing];
    if (!IsStrEmpty(self.dataModel.NoteContent)) {
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
    [self endCurrentEditing];
    self.dataModel.NoteTitle = self.titleTextField.text;
    if (IsStrEmpty(self.titleTextField.text)) {
        [LGAlert showImgInfoWithStatus:@"笔记标题不能为空"];
        return;
    }
    if (IsStrEmpty(self.dataModel.NoteContent)) {
        [LGAlert showImgInfoWithStatus:@"笔记内容不能为空"];
        return;
    }
    
    self.dataModel.NoteCreateTime = [NSDate date].yj_string.yj_longDateTimeString;
    [LGAlert showIndeterminateWithStatus:@"保存中..."];
    __weak typeof(self) weakSelf = self;
    [self.dataModel uploadNoteDataWithComplete:^(BOOL isSuccess) {
        if (isSuccess) {
            [LGAlert showSuccessWithStatus:@"保存成功"];
            [weakSelf hide];
        }else{
            [LGAlert showErrorWithStatus:@"保存失败"];
        }
    }];
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
- (void)endCurrentEditing{
    [self.titleTextField resignFirstResponder];
    [self.contentTextView resignFirstResponder];
}
- (void)show{
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.transform = CGAffineTransformMakeTranslation(0, - self.frame.size.height);
        
    } completion:^(BOOL finished) {
         [self.contentTextView becomeFirstResponder];
    }];
}
- (void)hide{
    [self endCurrentEditing];
    [self.klgView invalidatePlayer];
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.transform = CGAffineTransformMakeTranslation(0, LG_ScreenWidth + self.frame.size.height);
        self.mask.alpha = 0;
    } completion:^(BOOL isFinished) {
        [self.mask removeFromSuperview];
        [self removeFromSuperview];
    }];
}
#pragma mark - LGBaseTextFieldDelegate
- (BOOL)lg_textFieldShouldReturn:(LGNoteBaseTextField *)textField{
    [textField resignFirstResponder];
    return NO;
}
- (void)lg_textFieldDidEndEditing:(LGNoteBaseTextField *)textField{
    self.dataModel.NoteTitle = textField.text;
}
#pragma mark - LGNoteBaseTextViewDelegate
- (void)lg_textViewClear:(LGNoteBaseTextView *)textView{
    [self endCurrentEditing];
    if(self.contentTextView.text.length == 0)  return;
    __weak typeof(self) weakSelf = self;
    [[YJLancooAlert lancooAlertWithTitle:@"温馨提示" msg:@"您确定要清空当前笔记内容吗?" cancelTitle:@"取消" destructiveTitle:@"确定" cancelBlock:nil destructiveBlock:^{
        weakSelf.contentTextView.text = @"";
        NSRange rg = weakSelf.contentTextView.selectedRange;
        rg.location = weakSelf.contentTextView.text.length;
        weakSelf.contentTextView.selectedRange = NSMakeRange(rg.location, 0);
        [weakSelf lg_textViewDidChange:weakSelf.contentTextView];
    }] show];
}

- (void)lg_textViewDidChange:(LGNoteBaseTextView *)textView{
    if (self.isInsert) {
        self.contentTextView.selectedRange = NSMakeRange(self.currentLocation + self.imgAttr.length,0);
    }
    self.isInsert = NO;
    
    [self.dataModel updateText:self.contentTextView.attributedText];

}
- (BOOL)lg_textViewShouldInteractWithTextAttachment:(LGNoteBaseTextView *)textView{
    return YES;
}

- (BOOL)lg_textViewShouldBeginEditing:(LGNoteBaseTextView *)textView{
    return YES;
}
- (void)lg_textViewPhotoEvent:(LGNoteBaseTextView *)textView{
    if (self.dataModel.imageAllCont > 9) {
        [LGAlert showImgInfoWithStatus:@"仅允许最多上传9张图片!"];
        return;
    }
    if (![LGNImagePickerViewController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [LGAlert showImgInfoWithStatus:@"没有打开相册权限"];
        return;
    }
    LGNImagePickerViewController *picker = [[LGNImagePickerViewController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [picker pickerPhotoCompletion:^(UIImage * _Nonnull image) {
        LGNDrawBoardViewController *drawController = [[LGNDrawBoardViewController alloc] init];
        drawController.style = LGNoteDrawBoardViewControllerStyleDefault;
        drawController.isCamera = NO;
        drawController.size = image.size;
        drawController.drawBgImage = image ;
        drawController.modalPresentationStyle = UIModalPresentationFullScreen;
        [YJNewNoteManager.defaultManager.ownController presentViewController:drawController animated:YES completion:nil];
    }];
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [YJNewNoteManager.defaultManager.ownController presentViewController:picker animated:YES completion:nil];
}
- (void)lg_textViewCameraEvent:(LGNoteBaseTextView *)textView{
    if (self.dataModel.imageAllCont > 9) {
        [LGAlert showImgInfoWithStatus:@"仅允许最多上传9张图片!"];
        return;
    }
    if (![LGNImagePickerViewController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [LGAlert showImgInfoWithStatus:@"没有打开相机权限"];
        return;
    }
    LGNImagePickerViewController *picker = [[LGNImagePickerViewController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    __weak typeof(self) weakSelf = self;
    [picker pickerPhotoCompletion:^(UIImage * _Nonnull image) {
        LGNDrawBoardViewController *drawController = [[LGNDrawBoardViewController alloc] init];
        drawController.style = LGNoteDrawBoardViewControllerStyleDefault;
        drawController.isCamera = YES;
        drawController.drawBgImage =image ;
        drawController.size = image.size;
        drawController.modalPresentationStyle = UIModalPresentationFullScreen;
        [YJNewNoteManager.defaultManager.ownController presentViewController:drawController animated:YES completion:nil];
    }];
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [YJNewNoteManager.defaultManager.ownController presentViewController:picker animated:YES completion:nil];
}
- (void)lg_textViewDrawBoardEvent:(LGNoteBaseTextView *)textView{
    if (self.dataModel.imageAllCont > 9) {
        [LGAlert showImgInfoWithStatus:@"仅允许最多上传9张图片!"];
        return;
    }
    LGNDrawBoardViewController *drawController = [[LGNDrawBoardViewController alloc] init];
    drawController.style = LGNoteDrawBoardViewControllerStyleDraw;
       drawController.modalPresentationStyle = UIModalPresentationFullScreen;
    [YJNewNoteManager.defaultManager.ownController presentViewController:drawController animated:YES completion:nil];
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
- (LGNoteBaseTextField *)titleTextField{
    if (!_titleTextField) {
        _titleTextField = [[LGNoteBaseTextField alloc] initWithFrame:CGRectZero];
        _titleTextField.maxLength = 50;
        _titleTextField.tintColor = UIColorFromHex(0x989898);
        _titleTextField.textColor = UIColorFromHex(0x333333);
        _titleTextField.placeholder = @"请输入笔记标题(50字以内)";
        _titleTextField.font = [UIFont systemFontOfSize:16];
        _titleTextField.limitType = LGTextFiledKeyBoardInputTypeNoneEmoji;
        _titleTextField.returnKeyType = UIReturnKeyDone;
        _titleTextField.lgDelegate = self;
        _titleTextField.leftView = nil;
    }
    return _titleTextField;
}
- (LGNoteBaseTextView *)contentTextView{
    if (!_contentTextView) {
        _contentTextView = [[LGNoteBaseTextView alloc] initWithFrame:CGRectZero];
        _contentTextView.placeholder = @"请输入笔记内容...";
        _contentTextView.placeholderColor = UIColorFromHex(0x989898);
        _contentTextView.tintColor = UIColorFromHex(0x989898);
        _contentTextView.inputType = LGTextViewKeyBoardTypeEmojiLimit;
        _contentTextView.toolBarStyle = LGTextViewToolBarStyleDrawBoard;
        _contentTextView.maxLength = 50000;
        _contentTextView.textColor = UIColorFromHex(0x333333);
        _contentTextView.font = [UIFont systemFontOfSize:16];
        _contentTextView.lgDelegate = self;
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = 6;
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:16],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        _contentTextView.typingAttributes = attributes;
        [_contentTextView showMaxTextLengthWarn:^{
            [LGAlert showImgInfoWithStatus:@"字数已达限制"];
        }];
    }
    return _contentTextView;
}
@end

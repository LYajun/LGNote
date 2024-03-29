//
//  LGDrawBoardViewController.m
//  NoteDemo
//
//  Created by hend on 2018/10/19.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "LGNDrawBoardViewController.h"
#import "LGNNoteDrawView.h"
#import "LGNoteConfigure.h"
#import "NSBundle+Notes.h"
#import "LGNNoteCustomWindow.h"
#import "LGNNoteDrawSettingView.h"
#import "LGNNoteDrawSettingButtonView.h"
#import "LGNImagePickerViewController.h"
#import "LGNCutImageViewController.h"

@interface LGNDrawBoardViewController ()<NoteDrawSettingViewDelegate,NoteDrawSettingButtonViewDelegate>

@property (nonatomic, strong) LGNNoteDrawView *drawView;
@property (nonatomic, strong) UIImageView *bgImageView;
/** 取消 */
@property (nonatomic, strong) UIButton *cancelBtn;
/** 重做 */
@property (nonatomic, strong) UIButton *redoBtn;
@property (nonatomic, strong) LGNNoteCustomWindow *drawSettingWindow;
@property (nonatomic, strong) LGNNoteDrawSettingView *drawToolView;
@property (nonatomic, strong) LGNNoteDrawSettingButtonView *buttonView;

@property (nonatomic,assign)  CGFloat ImagWidth;
@property (nonatomic,assign)  CGFloat ImagHeigt;

@end

@implementation LGNDrawBoardViewController

- (void)dealloc{
    NSLog(@"LGDrawBoardViewController 释放了");
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self prefersStatusBarHidden];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"画板";
    
    [self createSubViews];
}

- (void)createSubViews{
    [self.view addSubview:self.drawView];
    [self.view addSubview:self.cancelBtn];
    [self.view addSubview:self.redoBtn];
    [self.view addSubview:self.buttonView];
    [self setupSubviewsContraints];
}

- (void)setupSubviewsContraints{
    self.cancelBtn.layer.cornerRadius = 15.0f;
    self.cancelBtn.layer.masksToBounds = YES;
    self.cancelBtn.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        if (LGNoteIsIphoneX()) {
            make.top.equalTo(self.view.mas_top).offset(44.0f + 6.0f);
        } else {
            make.top.equalTo(self.view.mas_top).offset(20.0f + 6.0f);
        }
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
    
    self.redoBtn.layer.cornerRadius = 15.0f;
    self.redoBtn.layer.masksToBounds = YES;
    self.redoBtn.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    [self.redoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        if (LGNoteIsIphoneX()) {
            make.top.equalTo(self.view.mas_top).offset(44.0f + 6.0f);
        } else {
            make.top.equalTo(self.view.mas_top).offset(20.0f + 6.0f);
        }
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
    
    [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(50);
        if (LGNoteIsIphoneX()) {
            make.bottom.equalTo(self.view.mas_bottom).offset(-10.0f);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
    }];
    
    if (self.style == LGNoteDrawBoardViewControllerStyleDefault) {
        [self.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_greaterThanOrEqualTo(self.view.mas_top).offset(LGNoteIsIphoneX() ? 88.0f : 64.0f);
            make.bottom.mas_lessThanOrEqualTo(self.view.mas_bottom).offset(- (LGNoteIsIphoneX() ? 10.0f : 0.0f) - 50.0f);
            make.left.mas_greaterThanOrEqualTo(self.view.mas_left);
            make.right.mas_lessThanOrEqualTo(self.view.mas_right);
            make.centerY.equalTo(self.view);
            make.centerX.equalTo(self.view);
            make.width.equalTo(self.drawView.mas_height).multipliedBy(self.size.width / self.size.height);
        }];
    } else {
        [self.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(LGNoteIsIphoneX() ? 88.0f : 64.0f);
            make.bottom.equalTo(self.view.mas_bottom).offset(- (LGNoteIsIphoneX() ? 10.0f : 0.0f) - 50.0f);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
        }];
    }
}

#pragma mark - NoteDrawSettingViewDelegate


- (void)drawSettingViewSelectedPenFontButton:(NSInteger)buttonTag{
    [self.buttonView penFontButtonSeleted];
    
    
    
}

- (void)drawSettingViewSelectedPenColorButton:(NSInteger)buttonTag{
    [self.buttonView penColorButtonSeleted];
    
    
}

- (void)drawSettingViewSelectedDrawBackgroudButton:(NSInteger)buttonTag{
    if (self.style == LGNoteDrawBoardViewControllerStyleDefault) {
        [self.drawSettingWindow hiddenAnimationWithDurationTime:0.25];
    }
    [self.buttonView drawBackgroudButtonSeleted];
}

- (void)drawSettingViewSelectedLastButton:(NSInteger)buttonTag{
    
    [self.buttonView lastButtonSeleted];
    [self.drawSettingWindow hiddenAnimationWithDurationTime:0.25];
    [self.drawView unDo];
}

- (void)drawSettingViewSelectedNextButton:(NSInteger)buttonTag{
    [self.buttonView nextButtonSeleted];
}

- (void)drawSettingViewSelectedFinishButton:(NSInteger)buttonTag{
    [self chooseFinishForButtonTag:MAXFLOAT];
}

- (void)drawSettingViewSelectedColorHex:(NSString *)colorHex{
    self.drawView.brushColor = [UIColor colorWithHexString:colorHex];
}

- (void)drawSettingViewChanegPenFont:(CGFloat)font{
    self.drawView.brushWidth = font;
}

- (void)drawSettingViewChangeBackgroudImage:(NSString *)imageName{
    if ([imageName isEqualToString:@"BoardBgChoosePickerImageKey"]) {
        [self.drawSettingWindow hiddenAnimationWithDurationTime:0.25];
        [self oppenedPicker];
    } else {
        self.drawView.backgroundImage = [NSBundle lg_imageName:imageName];
    }
}

- (void)oppenedPicker{
    if (![LGNImagePickerViewController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [[LGNoteMBAlert shareMBAlert] showErrorWithStatus:@"没有打开相册权限"];
    }
    LGNImagePickerViewController *picker = [[LGNImagePickerViewController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    @weakify(self);
    [picker pickerPhotoCompletion:^(UIImage * _Nonnull image) {
        @strongify(self);
        self.drawView.backgroundImage = image;
    }];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - ButtonViewDelegate
- (void)choosePenFontForButtonTag:(NSInteger)butonTag{
    [self.drawToolView showPenFont:YES showPenColor:NO showBoardView:NO buttonTag:butonTag];
    [self.drawSettingWindow showAnimationWithDurationTime:0.25];
    
}

- (void)choosePenColorForButtonTag:(NSInteger)butonTag{
    [self.drawToolView showPenFont:NO showPenColor:YES showBoardView:NO buttonTag:butonTag];
    [self.drawSettingWindow showAnimationWithDurationTime:0.25];
    
}

- (void)chooseBoardBackgroudImageForButtonTag:(NSInteger)butonTag{
    
    
    if (self.style == LGNoteDrawBoardViewControllerStyleDefault) {
        [kMBAlert showRemindStatus:@"该模式下暂不支持切换图片该功能"];
        [self.drawToolView closePenFont:NO closePenColor:NO closeBoardView:YES];
    } else {
        [self.drawToolView showPenFont:NO showPenColor:NO showBoardView:YES buttonTag:butonTag];
        [self.drawSettingWindow showAnimationWithDurationTime:0.25];
    }
}

- (void)chooseUndoForButtonTag:(NSInteger)butonTag{
    [self.drawView unDo];
}

- (void)chooseNextForButtonTag:(NSInteger)butonTag{
    [self.drawView reDo];
}

//裁剪
- (void)choosecutImageButtonTag:(NSInteger)butonTag{
    
    @weakify(self);
    
    
//    LGNCutImageViewController *cutController = [[LGNCutImageViewController alloc] init];
//    cutController.image = _drawBgImage;
//    cutController.isCamera = NO;
//    [self presentViewController:cutController animated:YES completion:nil];
    

    [self.drawView saveCompletion:^(UIImage * _Nonnull image, NSString * _Nonnull msg) {
  @strongify(self);
    
        _drawBgImage = image;
        
        
        LGNCutImageViewController *cutController = [[LGNCutImageViewController alloc] init];
        cutController.image = _drawBgImage;
        cutController.isCamera = NO;
         cutController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:cutController animated:YES completion:nil];
    }];
    
    
   
    

    
    
}

- (void)chooseFinishForButtonTag:(NSInteger)butonTag{
    [self.drawSettingWindow hiddenAnimationWithDurationTime:0.25];
//    if (self.style == LGNoteDrawBoardViewControllerStyleDraw) {
//    } else {
//        [[NSNotificationCenter defaultCenter] postNotificationName:LGNoteDrawBoardViewControllerFinishedDrawNotification object:nil userInfo:@{@"a":self.drawBgImage}];
//    }
    
    [self.drawView saveCompletion:^(UIImage * _Nonnull image, NSString * _Nonnull msg) {
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LGNoteDrawBoardViewControllerFinishedDrawNotification object:nil userInfo:@{@"image":image}];
    }];
    
    
    [self dismissTopViewController:YES];
    
}

#pragma mark - layzy
- (LGNNoteCustomWindow *)drawSettingWindow{
    if (!_drawSettingWindow) {
        _drawSettingWindow = [[LGNNoteCustomWindow alloc] initWithAnmationContentView:self.drawToolView];
        
    }
    return _drawSettingWindow;
}

- (LGNNoteDrawSettingView *)drawToolView{
    if (!_drawToolView) {
        _drawToolView = [[LGNNoteDrawSettingView alloc] initWithFrame:CGRectMake(0, kMain_Screen_Height, kMain_Screen_Width, 140)];
        //_drawToolView.backgroundColor = [UIColor redColor];
        _drawToolView.delegate = self;
    }
    return _drawToolView;
}

- (LGNNoteDrawSettingButtonView *)buttonView{
    if (!_buttonView) {
        
        if (self.style == LGNoteDrawBoardViewControllerStyleDefault) {
            
             _buttonView = [[LGNNoteDrawSettingButtonView alloc] initWithFrame:CGRectZero buttonNorImages:@[@"note_pencil_unselected",@"note_color_unselected",@"note_pho_newunselected",@"note_last_unselected",@"note_next_unselected",@"lg_notetool_image_ic_clik_checked"] buttonSelectedImages:@[@"note_pencil_selected",@"note_color_selected",@"note_pho_newunselected",@"note_last_selected",@"note_next_selected",@"lg_notetool_image_ic_clik_checked"] singleTitle:@"完成" ];
        }else{
             _buttonView = [[LGNNoteDrawSettingButtonView alloc] initWithFrame:CGRectZero buttonNorImages:@[@"note_pencil_unselected",@"note_color_unselected",@"note_pho_newunselected",@"note_last_unselected",@"note_next_unselected",@"lg_notetool_image_ic_clik_checked"] buttonSelectedImages:@[@"note_pencil_selected",@"note_color_selected",@"note_Newpho_selected",@"note_last_selected",@"note_next_selected",@"lg_notetool_image_ic_clik_checked"] singleTitle:@"完成" ];
        }
        
       
        _buttonView.backgroundColor = [UIColor blackColor];
        _buttonView.delegate = self;
    }
    return _buttonView;
}

- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        @weakify(self);
        [[_cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self dismissTopViewController:YES];
        }];
    }
    return _cancelBtn;
}

- (UIButton *)redoBtn{
    if (!_redoBtn) {
        _redoBtn = [[UIButton alloc] init];
        [_redoBtn setTitle:@"重做" forState:UIControlStateNormal];
        @weakify(self);
        [[_redoBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.drawView clean];
        }];
    }
    return _redoBtn;
}

- (LGNNoteDrawView *)drawView{
    if (!_drawView) {
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (LGNoteIsIphoneX() ? 88.0f : 64.0f), kMain_Screen_Width, kMain_Screen_Height - (LGNoteIsIphoneX() ? 88.0f : 64.0f) - (LGNoteIsIphoneX() ? 10.0f : 0.0f) - 50.0f)];
        bgImgView.image = [NSBundle lg_imagePathName:@"note_board_2"];
        
        _drawView = [[LGNNoteDrawView alloc] init];
        _drawView.brushColor = [UIColor redColor];
        _drawView.brushWidth = 2.4;
        _drawView.shapeType = DrawBoardShapeCurve;
        _drawView.style = self.style;
        _drawView.backgroundImage = (self.style == LGNoteDrawBoardViewControllerStyleDefault) ? self.drawBgImage:bgImgView.image;
        
    }
    return _drawView;
}




@end

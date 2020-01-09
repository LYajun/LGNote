//
//  NoteEditView.m
//  NoteDemo
//
//  Created by hend on 2019/3/11.
//  Copyright © 2019 hend. All rights reserved.
//

#import "LGNNoteEditView.h"
#import "LGNViewModel.h"
#import "LGNSubjectPickerView.h"
#import "LGNoteConfigure.h"
#import "LGNNoteSourceDetailView.h"
#import "YBImageBrowser.h"
#import "LGNImagePickerViewController.h"
#import "LGNDrawBoardViewController.h"
#import "LGNCutImageViewController.h"
#import "LGNSingleTool.h"
#import "HPTextViewTapGestureRecognizer.h"
#import "LGNNoteModel.h"
@interface LGNNoteEditView ()
<
LGNoteBaseTextFieldDelegate,
LGNoteBaseTextViewDelegate,
LGSubjectPickerViewDelegate,
HPTextViewTapGestureRecognizerDelegate
>

@property (nonatomic, strong) UIView *headerView;
/** 灰线(10高度) */
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *sourceBtn;
@property (nonatomic, strong) UIImageView *subjTipImageView;
@property (nonatomic, strong) UIImageView *sourceTipImageView;
@property (nonatomic,strong) UIScrollView * bgScrollView;

/** 标题下的线(0.7高度) */
@property (nonatomic, strong) UIView *line;



@property (nonatomic, strong) NSMutableAttributedString *imgAttr;
@property (nonatomic, assign) NSInteger currentLocation;
@property (nonatomic, assign) BOOL isInsert;

/** 当前选中的学科下标 */
@property (nonatomic, assign) NSInteger currentSelectedSubjectIndex;
@property (nonatomic, assign) NSInteger currentSelectedTopicIndex;

/** 头部视图的风格 */
@property (nonatomic, assign) NoteEditViewHeaderStyle style;
/** 题目筛选picker数据源 */
@property (nonatomic, copy)   NSArray *materialArray;
/** 学科筛选picker数据源 */
@property (nonatomic, copy)   NSArray *subjectArray;

@property (nonatomic, strong) LGNViewModel *viewModel;

@property (nonatomic,assign) int  photoIndex;

@property (nonatomic,strong) NSString * ResourceIOSLink;
//记录是否需要销毁通知
@property (nonatomic,assign) BOOL  isNeed;
//时时编辑的数据图片
@property (nonatomic, copy) NSArray *NowimgaeUrls;
@end

@implementation LGNNoteEditView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    
    
    if (newWindow == nil) {
       
        if(_isNeed){
            //移除通知
             [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
      
    }
}


- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame headerViewStyle:NoteEditViewHeaderStyleNoHidden];
}

- (instancetype)initWithFrame:(CGRect)frame headerViewStyle:(NoteEditViewHeaderStyle)style{
    if (self = [super initWithFrame:frame]) {
        _style = style;
        self.backgroundColor = [UIColor whiteColor];
        [self registNotifications];
        [self createSubviews];
    }
    return self;
}

- (void)registNotifications{
    
    _isNeed = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewKeyBoardDidShowNotification:) name:LGTextViewKeyBoardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewKeyBoardWillHiddenNotification:) name:LGTextViewKeyBoardWillHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postImageView:) name:LGNoteDrawBoardViewControllerFinishedDrawNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(destroyImageNoti) name:@"destroyImageNoti" object:nil];
}

- (void)destroyImageNoti{
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



- (void)createSubviews{
    switch (_style) {
        case NoteEditViewHeaderStyleNoHidden:
        case NoteEditViewHeaderStyleNoHiddenCanTouch:
        case NoteEditViewHeaderStyleHideSubject:
        case NoteEditViewHeaderStyleHideSource:{
            [self addSubview:self.headerView];
            [self.headerView addSubview:self.subjectBtn];
            [self.headerView addSubview:self.sourceBtn];
            [self.headerView addSubview:self.subjTipImageView];
            [self addSubview:self.bottomView];
            
            if(_style ==NoteEditViewHeaderStyleNoHiddenCanTouch){
                //小助手
                self.sourceBtn.hidden = NO;
                self.sourceBtn.enabled = YES;
                self.subjectBtn.hidden = NO;
                self.subjectBtn.enabled = YES;
                self.sourceTipImageView.hidden =NO;
                self.subjTipImageView.hidden = NO;

            }
            if(_style == NoteEditViewHeaderStyleNoHidden){
                self.sourceBtn.hidden = NO;
                self.sourceBtn.enabled = NO;
                self.subjectBtn.hidden = NO;
                self.subjectBtn.enabled = NO;
                self.sourceTipImageView.hidden =YES;
                [self.subjectBtn setImage:nil forState:UIControlStateNormal];
                }
            
            
            if (_style == NoteEditViewHeaderStyleHideSource) {
               // [self.subjectBtn setImage:nil forState:UIControlStateNormal];
                
            }
            //self.subjectBtn.userInteractionEnabled = !(_style == NoteEditViewHeaderStyleHideSource);
            self.subjectBtn.hidden = (_style == NoteEditViewHeaderStyleHideSubject) ? YES:NO;
            self.sourceBtn.hidden  = (_style == NoteEditViewHeaderStyleHideSource) ? YES:NO;
            

          
        }
            break;
        case NoteEditViewHeaderStyleHideAll: break;
    }
    
    
//
//    UIScrollView *bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,kMain_Screen_Width, kMain_Screen_Height-32)];
//    bgScrollView.contentSize = CGSizeMake(0, kMain_Screen_Height+300);
//    //bgScrollView.backgroundColor = LGRGB(238, 238, 238);
//    [self addSubview:self.bgScrollView=bgScrollView];

    
    
    [self addSubview:self.remarkBtn];
    [self addSubview:self.titleTextF];
    [self addSubview:self.line];
    [self addSubview:self.contentTextView];
    [self addSubview:self.sourceTipImageView];
    
    [self setupSubviewsContraints];
}

- (void)setupSubviewsContraints{
    CGFloat offsetX = 15.f;
    
    switch (_style) {
        case NoteEditViewHeaderStyleNoHidden:
        case NoteEditViewHeaderStyleNoHiddenCanTouch:
        case NoteEditViewHeaderStyleHideSubject:
        case NoteEditViewHeaderStyleHideSource:{
            [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self);
                make.height.mas_equalTo(40);
            }];
            [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.headerView.mas_bottom);
                make.left.right.equalTo(self);
                make.height.mas_equalTo(10);
            }];
            [self.subjTipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.headerView);
                make.left.equalTo(self.headerView).offset(offsetX);
                make.size.mas_equalTo(CGSizeMake(16, 16));
            }];
            [self.sourceTipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.headerView);
                make.right.equalTo(self.headerView).offset(-offsetX);
                //make.size.mas_equalTo(CGSizeMake(6, 8));
                 make.size.mas_equalTo(CGSizeMake(1, 1));
            }];
            [self.subjectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.subjTipImageView.mas_right).offset(5);
                make.centerY.equalTo(self.headerView);
                make.width.mas_equalTo(kMain_Screen_Width/2-50);
                
            }];
            [self.sourceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.sourceTipImageView.mas_left).offset(-1);
                make.centerY.equalTo(self.headerView);
                make.width.mas_equalTo(kMain_Screen_Width/2-50);
            }];
            [self.titleTextF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bottomView.mas_bottom);
                make.left.equalTo(self).offset(offsetX);
                make.right.equalTo(self.remarkBtn.mas_left).offset(-10);
                make.height.mas_equalTo(50);
            }];
        }
            break;
        case NoteEditViewHeaderStyleHideAll:{
            [self.titleTextF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self);
                make.left.equalTo(self).offset(offsetX);
                make.right.equalTo(self.remarkBtn.mas_left).offset(-10);
                make.height.mas_equalTo(50);
            }];
        }
            break;
    }
    
    [self.remarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleTextF);
        make.right.equalTo(self).offset(-offsetX);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleTextF);
        make.right.equalTo(self.remarkBtn);
        make.top.equalTo(self.titleTextF.mas_bottom);
        make.height.mas_equalTo(0.7);
    }];
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.line.mas_bottom);
        make.centerX.bottom.equalTo(self);
        make.left.equalTo(self.titleTextF).offset(-5);
        
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.subjectBtn setImagePosition:LGImagePositionRight spacing:5];
}

#pragma mark - API
- (void)bindViewModel:(LGNViewModel *)viewModel{
    self.viewModel = viewModel;
    self.titleTextF.text = viewModel.dataSourceModel.NoteTitle;
    
    
    self.contentTextView.attributedText = viewModel.dataSourceModel.NoteContent_Att;
    
    if([self.viewModel.dataSourceModel.SystemID isEqualToString:@"S21"] ||[self.viewModel.dataSourceModel.SystemID isEqualToString:@"S22"]||[self.viewModel.dataSourceModel.SystemID isEqualToString:@"000"]||[self.viewModel.dataSourceModel.SystemID isEqualToString:@"B30"]){
        
        self.subjectBtn.hidden = NO;
        self.subjectBtn.enabled = YES;
        
    }else{
        
        self.subjectBtn.hidden = NO;
        self.subjectBtn.enabled = NO;
        [self.subjectBtn setImage:nil forState:UIControlStateNormal];
    }
    
    

    //将图片总数同步
    self.viewModel.dataSourceModel.imageAllCont =self.viewModel.dataSourceModel.imgaeUrls.count;

    
    viewModel.dataSourceModel.SubjectName = IsStrEmpty(viewModel.dataSourceModel.SubjectName) ? @"英语":viewModel.dataSourceModel.SubjectName;
    
    
    [self.subjectBtn setTitle:viewModel.dataSourceModel.SubjectName forState:UIControlStateNormal];
    
    
    self.remarkBtn.selected = [viewModel.dataSourceModel.IsKeyPoint isEqualToString:@"1"] ? YES:NO;
    
    
    self.materialArray = [self.viewModel configureMaterialPickerDataSource];
    //    去除全部与其他学科
    self.subjectArray = [self.viewModel configureSubjectPickerDataSource];
    
    
if(self.viewModel.paramModel.SystemType==SystemType_HOME && self.canEditing ==YES){
        
        [self.sourceBtn setTitle:viewModel.paramModel.MaterialName forState:UIControlStateNormal];
}else if (self.viewModel.paramModel.SystemType==SystemType_DZJCK){
    
     [self.sourceBtn setTitle:viewModel.paramModel.MaterialName forState:UIControlStateNormal];
}

else{
        [self.sourceBtn setTitle:viewModel.dataSourceModel.ResourceName forState:UIControlStateNormal];
    }
    
    
    
   
    @weakify(self)
    [[self.viewModel getSubjectIDAndPickerSelectedForSubjectArray:viewModel.subjectArray subjectName:viewModel.dataSourceModel.SubjectName] subscribeNext:^(NSArray * _Nullable subjectSelectedData) {
        @strongify(self);
        self.currentSelectedSubjectIndex = [[subjectSelectedData firstObject] integerValue];
        self.viewModel.dataSourceModel.SubjectID = [subjectSelectedData lastObject];
        
        
        
    }];
    
    
    [self.viewModel.getDetailNoteSubject subscribeNext:^(id  _Nullable x) {

        LGNNoteModel * model = x;
        
    self.ResourceIOSLink = model.ResourceIOSLink;        
        //可以点击标注下划线
      
        if(!IsStrEmpty(model.ResourceIOSLink)){
            
            NSMutableAttributedString*str = [[NSMutableAttributedString alloc]initWithString:self.sourceBtn.titleLabel.text];
            NSRange strRange = {0,[str length]};
            [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]range:strRange];
            
            [self.sourceBtn setAttributedTitle:str forState:UIControlStateNormal];


        }
        
        
    }];
    
    
}

#pragma mark - TextViewDelegate
- (void)lg_textViewClear:(LGNoteBaseTextView *)textView{
    if(self.contentTextView.text.length == 0)  return;
    
    
    @weakify(self);
    [kMBAlert showAlertControllerOn:self.ownController title:@"提示" message:@"您确定要清空当前笔记内容吗?" oneTitle:@"确定" oneHandle:^(UIAlertAction * _Nonnull one) {
        @strongify(self);
        self.contentTextView.text = @"";

        //[self.contentTextView resignFirstResponder];
        NSRange rg = self.contentTextView.selectedRange;
        rg.location = self.contentTextView.text.length;
        self.contentTextView.selectedRange = NSMakeRange(rg.location, 0);


        [self lg_textViewDidChange:self.contentTextView];
    } twoTitle:@"取消" twoHandle:^(UIAlertAction * _Nonnull two) {
        
    } completion:^{
        
    }];
}

- (void)lg_textViewDidChange:(LGNoteBaseTextView *)textView{
    
    
    if (self.isInsert) {
        self.contentTextView.selectedRange = NSMakeRange(self.currentLocation + self.imgAttr.length,0);
    }
    self.isInsert = NO;
    
    
    
    [self.viewModel.dataSourceModel updateText:self.contentTextView.attributedText];

}

- (BOOL)lg_textViewShouldInteractWithTextAttachment:(LGNoteBaseTextView *)textView{
//    YBImageBrowser *browser = [YBImageBrowser new];
//    browser.dataSourceArray = [self configureUrls];
//    browser.currentIndex = 0;
//    [browser show];
    
    return YES;
}
//
- (BOOL)lg_textViewShouldBeginEditing:(LGNoteBaseTextView *)textView{
    
    if(_canEditing){
        
        return YES;

    }
    
    return NO;
}

- (NSArray *)configureUrls:(NSString*)urlStr{
    
    
    NSArray * imageArr = [NSArray array];
    
    if(!IsArrEmpty(_NowimgaeUrls)){
        
       imageArr = _NowimgaeUrls;
    }else{
      imageArr =self.viewModel.dataSourceModel.imgaeUrls;
    }
   
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:imageArr.count];
    
    for (int i = 0; i < imageArr.count; i ++) {
        YBImageBrowseCellData *data = [YBImageBrowseCellData new];
        data.url = imageArr[i];
       NSString *str1 = [data.url absoluteString];
        
        if ([urlStr containsString:@".jpg"]) {
            urlStr = [urlStr stringByReplacingOccurrencesOfString:@".png" withString:@""];
            
        }
        
     if([str1 containsString:urlStr]){
         //保存照片index
         _photoIndex = i;
       
     }
        
        
        [result addObject:data];
        
    }
    
    
    return result;
}

- (void)lg_textViewPhotoEvent:(LGNoteBaseTextView *)textView{
    
  
    
    if(self.viewModel.dataSourceModel.imageAllCont ==9 ||self.viewModel.dataSourceModel.imageAllCont>9){
        [[LGNoteMBAlert shareMBAlert] showErrorWithStatus:@"仅允许最多上传9张图片!"];
        
        return;
    }
    
    if (![LGNImagePickerViewController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [[LGNoteMBAlert shareMBAlert] showErrorWithStatus:@"没有打开相册权限"];
    }
      _isNeed = NO;

    LGNImagePickerViewController *picker = [[LGNImagePickerViewController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    @weakify(self);
    [picker pickerPhotoCompletion:^(UIImage * _Nonnull image) {
        @strongify(self);
        self.isNeed = NO;
        
//        LGNCutImageViewController *cutController = [[LGNCutImageViewController alloc] init];
//        cutController.image = image;
//        cutController.isCamera = NO;
//        [self.ownController presentViewController:cutController animated:YES completion:nil];
        
        LGNDrawBoardViewController *drawController = [[LGNDrawBoardViewController alloc] init];
        drawController.style = LGNoteDrawBoardViewControllerStyleDefault;
        drawController.isCamera = NO;
          drawController.size = image.size;
        drawController.drawBgImage =image ;
        
        drawController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.ownController presentViewController:drawController animated:YES completion:nil];
        
    }];
    
     picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.ownController presentViewController:picker animated:YES completion:nil];
}

- (void)lg_textViewCameraEvent:(LGNoteBaseTextView *)textView{
    
    if(self.viewModel.dataSourceModel.imageAllCont ==9 ||self.viewModel.dataSourceModel.imageAllCont>9){
        [[LGNoteMBAlert shareMBAlert] showErrorWithStatus:@"仅允许最多上传9张图片!"];
        
        return;
    }
    
    
    if (![LGNImagePickerViewController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [[LGNoteMBAlert shareMBAlert] showErrorWithStatus:@"没有打开照相机权限"];
    }
    
      _isNeed = NO;
    LGNImagePickerViewController *picker = [[LGNImagePickerViewController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    @weakify(self);
    [picker pickerPhotoCompletion:^(UIImage * _Nonnull image) {
        @strongify(self);
        
         self.isNeed = NO;
//        LGNCutImageViewController *cutController = [[LGNCutImageViewController alloc] init];
//        cutController.isCamera = YES;
//        cutController.image = image;
        
        LGNDrawBoardViewController *drawController = [[LGNDrawBoardViewController alloc] init];
        drawController.style = LGNoteDrawBoardViewControllerStyleDefault;
        drawController.isCamera = YES;
        drawController.drawBgImage =image ;
        drawController.size = image.size;

         drawController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.ownController presentViewController:drawController animated:YES completion:nil];
        
    }];
      picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.ownController presentViewController:picker animated:YES completion:nil];
}

- (void)lg_textViewDrawBoardEvent:(LGNoteBaseTextView *)textView{
    
    if(self.viewModel.dataSourceModel.imageAllCont ==9 ||self.viewModel.dataSourceModel.imageAllCont>9){
        [[LGNoteMBAlert shareMBAlert] showErrorWithStatus:@"仅允许最多上传9张图片!"];
        
        return;
    }
    
      _isNeed = NO;
    LGNDrawBoardViewController *drawController = [[LGNDrawBoardViewController alloc] init];
    drawController.style = LGNoteDrawBoardViewControllerStyleDraw;
       drawController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.ownController presentViewController:drawController animated:YES completion:nil];
}
//-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
//
//{
//    //
//    //    if(_canEditing){
//    //
//    //        return YES;
//    //
//    //    }
//    
//    return NO;
//    
//}


- (void)settingImageAttributes:(UIImage *)image imageFTPPath:(NSString *)path{
    
    

    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width - kNoteImageOffset;
    // 固定宽度
   width = width > screenW ? screenW:width;
   // 固定高度
   // height = height >= 220 ? 220:height;
    
    
    NSString *imgStr = [NSString stringWithFormat:@"<img src=\"%@\" width=\"%.f\" height=\"%.f\"/>",path,width,height];
    NSMutableAttributedString *currentAttr = [[NSMutableAttributedString alloc] initWithAttributedString:self.contentTextView.attributedText];
    self.imgAttr = imgStr.lg_changeforMutableAtttrubiteString;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];

    paragraphStyle.lineSpacing = 15;// 字体的行间距

    NSDictionary *attributes = @{

                                 NSFontAttributeName:[UIFont systemFontOfSize:15],

                                 NSParagraphStyleAttributeName:paragraphStyle

                                 };

   [self.imgAttr addAttributes:attributes range:NSMakeRange(0, self.imgAttr.length)];
  //  [self.imgAttr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} range:NSMakeRange(0, self.imgAttr.length)];
    
    [self.viewModel.dataSourceModel updateImageInfo:@{@"src":path,@"width":[NSString stringWithFormat:@"%.f",width],@"height":[NSString stringWithFormat:@"%.f",height]} imageAttr:self.imgAttr];
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

#pragma mark - NSNotification action
- (void)textViewKeyBoardDidShowNotification:(NSNotification *)notification{
    
    if(!_canEditing){
        return;
    }
    
    [self.contentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.line.mas_bottom);
        make.centerX.equalTo(self);
        make.left.equalTo(self.titleTextF).offset(-5);
        make.bottom.equalTo(self).offset(-self.contentTextView.keyboardHeight);
    }];
}

- (void)textViewKeyBoardWillHiddenNotification:(NSNotification *)notification{
    
    
    [self.contentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.line.mas_bottom);
        make.centerX.bottom.equalTo(self);
        make.left.equalTo(self.titleTextF).offset(-5);
    }];
}

- (void)postImageView:(NSNotification *)notification{
    UIImage *image = notification.userInfo[@"image"];
    
    _isNeed = YES;
    
    @weakify(self);
    [[self.viewModel uploadImages:@[image]] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (!x) {
            [[LGNoteMBAlert shareMBAlert] showErrorWithStatus:@"上传失败，请检查网络后再重试!"];
            return ;
        }
        
        _contentTextView.placeholder=@"";
        [self settingImageAttributes:image imageFTPPath:x];
        
        NSMutableArray *imageUrls = [self filterImageUrlWithHtml:self.viewModel.dataSourceModel.NoteContent];
        // 保存时时图片数组
          self.NowimgaeUrls = imageUrls;

         [self.contentTextView becomeFirstResponder];
    }];
}


- (NSMutableArray *)filterImageUrlWithHtml:(NSString *)html{
    NSMutableArray *resultArray = [NSMutableArray array];
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"<(img|IMG)(.*?)(/>|></img>|>)" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    NSArray *result = [regular matchesInString:html options:NSMatchingReportCompletion range:NSMakeRange(0, html.length)];
    for (NSTextCheckingResult *item in result) {
        NSString *imgHtml = [html substringWithRange:[item rangeAtIndex:0]];
        NSArray *tmpArray = nil;
        if ([imgHtml rangeOfString:@"src=\""].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"src=\""];
        } else if ([imgHtml rangeOfString:@"src="].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"src="];
        }
        
        if (tmpArray.count >= 2) {
            NSString *src = tmpArray[1];
            NSUInteger loc = [src rangeOfString:@"\""].location;
            if (loc != NSNotFound) {
                src = [src substringToIndex:loc];
                [resultArray addObject:src];
            }
        }
    }
    return resultArray;
}

#pragma mark HPTextViewTapGestureRecognizerDelegate
// 点击链接
//-(void)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer handleTapOnURL:(NSURL*)URL inRange:(NSRange)characterRange
//{
//    [[UIApplication sharedApplication] openURL:URL];
//}
// 点击图片
-(void)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer handleTapOnTextAttachment:(NSTextAttachment*)textAttachment inRange:(NSRange)characterRange
{

    _photoIndex = 0;
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSourceArray = [self configureUrls:textAttachment.fileWrapper.preferredFilename];
    browser.currentIndex = _photoIndex;
    [browser show];
  
}


#pragma mark - textFildDelegate
- (void)lg_textFieldDidChange:(LGNoteBaseTextField *)textField{
    self.viewModel.dataSourceModel.NoteTitle = textField.text;
}

- (void)lg_textFieldShowMaxTextLengthWarning{
    [[LGNoteMBAlert shareMBAlert] showRemindStatus:@"   标题最多只能输入50个字符哦!"];
}

#pragma mark - buttonClick
- (void)remarkBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.viewModel.dataSourceModel.IsKeyPoint = @"1";
       
        [[LGNoteMBAlert shareMBAlert] showSuccessWithStatus:@"已标记为重点"];
        
    } else {
        self.viewModel.dataSourceModel.IsKeyPoint = @"0";
     
         [[LGNoteMBAlert shareMBAlert] showSuccessWithStatus:@"  已取消标记  "];
    }
}

- (void)sourceBtnClick:(UIButton *)sender{
    if (IsStrEmpty(_ResourceIOSLink)) {
        return;
    }
    
    NSLog(@"%@",_ResourceIOSLink);
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        self.sourceTipImageView.transform = CGAffineTransformMakeRotation(M_PI/2);
    } else {
        self.sourceTipImageView.transform = CGAffineTransformMakeRotation(0);
    }
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    // 如果是添加操作的话，给出选择题目，否则直接查看详情
    if (self.viewModel.isAddNoteOperation) {
        LGNSubjectPickerView *pickerView = [LGNSubjectPickerView showPickerView];
        pickerView.delegate = self;
        [pickerView showPickerViewMenuForDataSource:self.materialArray matchIndex:self.currentSelectedTopicIndex];
    } else {
    
        
        
        [self openUrl:_ResourceIOSLink showErrorInfo:@"无法启动" needInstallAppName:@""];
        
    
//        @weakify(self);
//        [[LGNNoteSourceDetailView showSourceDatailView] loadDataWithUrl:_ResourceIOSLink didShowCompletion:^{
//            @strongify(self);
//            self.sourceBtn.selected = NO;
//            self.sourceTipImageView.transform = CGAffineTransformMakeRotation(0);
//        }];
    }
}


- (void)openUrl:(NSString *)url showErrorInfo:(NSString *)errorInfo needInstallAppName:(NSString *)appName{
    NSURL *schemUrl = [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    
    [kMBAlert showIndeterminateWithStatus:@"请稍等..."];
    if ([[UIApplication sharedApplication] canOpenURL:schemUrl]) {
        // 如果能打开应用的话，隐藏工作已经放到APPDelegate程序进入后台的backgroud方法中
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:schemUrl options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:schemUrl];
        }
        [kMBAlert hide];
        
    } else if (!IsStrEmpty(url)){
        [kMBAlert hide];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"应用尚未安装，是否前去App Store下载?" preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com"] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:schemUrl];
            }
            
        }];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            
            
        }];
        
        [alert addAction:action1];
        [alert addAction:action];
        
        
        
        [self.ownController presentViewController:alert animated:YES completion:nil];
        
        
    } else {
        [kMBAlert showRemindStatus:errorInfo];
    }
}



- (void)subjectBtnClick:(UIButton *)sender{
    
   // 对于系统ID为：S21、S22、000,B30,笔记编辑的时候允许调整学科。
   
    
    if([self.viewModel.dataSourceModel.SystemID isEqualToString:@"S21"] ||[self.viewModel.dataSourceModel.SystemID isEqualToString:@"S22"]||[self.viewModel.dataSourceModel.SystemID isEqualToString:@"000"]||[self.viewModel.dataSourceModel.SystemID isEqualToString:@"B30"]){
        
        sender.selected = !sender.selected;
        if (sender.selected) {
            sender.imageView.transform = CGAffineTransformMakeRotation(-M_PI);
        } else {
            sender.imageView.transform = CGAffineTransformMakeRotation(0);
        }
        
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        LGNSubjectPickerView *pickerView = [LGNSubjectPickerView showPickerView];
        pickerView.delegate = self;
        [pickerView showPickerViewMenuForDataSource:self.subjectArray matchIndex:self.currentSelectedSubjectIndex];
    }
    
    
    
}

#pragma mark - pickerDelegate
- (void)pickerView:(LGNSubjectPickerView *)pickerView didSelectedCellIndexPathRow:(NSInteger)row{
//    if (IsArrEmpty(self.subjectArray) || IsArrEmpty(self.materialArray)) {
//        return;
//    }
    
    
    if (self.subjectBtn.selected) {
        if (IsArrEmpty(self.subjectArray)) return;
        // 因为处理过数据源了
        LGNSubjectModel *model = self.viewModel.subjectArray[row+1];
        [self.subjectBtn setTitle:model.SubjectName forState:UIControlStateNormal];
        self.currentSelectedSubjectIndex = row;
        self.viewModel.dataSourceModel.SubjectID = model.SubjectID;
        
        self.viewModel.dataSourceModel.SubjectName = model.SubjectName;
        //刷新布局
        [self.subjectBtn setImagePosition:LGImagePositionRight spacing:5];
    }
    
    if (self.sourceBtn.selected) {
        if(IsArrEmpty(self.materialArray)) return;
        
        NSString *string = self.materialArray[row];
        [self.sourceBtn setTitle:string forState:UIControlStateNormal];
        self.currentSelectedTopicIndex = row;
        self.viewModel.dataSourceModel.MaterialIndex = row+1;
    }
}

- (void)dissmissPickerView{
    self.subjectBtn.selected = NO;
    self.sourceBtn.selected = NO;
    self.subjectBtn.imageView.transform = CGAffineTransformMakeRotation(0);
    self.sourceTipImageView.transform = CGAffineTransformMakeRotation(0);
}

#pragma mark - layzy
- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor whiteColor];
    }
    return _headerView;
}

- (UIImageView *)subjTipImageView{
    if (!_subjTipImageView) {
        _subjTipImageView = [[UIImageView alloc] init];
        _subjTipImageView.image = [NSBundle lg_imagePathName:@"note_subject"];
    }
    return _subjTipImageView;
}

- (UIImageView *)sourceTipImageView{
    if (!_sourceTipImageView) {
        _sourceTipImageView = [[UIImageView alloc] init];
        _sourceTipImageView.image = [NSBundle lg_imagePathName:@"note_source_unselected"];
        
    }
    return _sourceTipImageView;
}

- (UIButton *)remarkBtn{
    if (!_remarkBtn) {
        _remarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _remarkBtn.frame = CGRectZero;
        [_remarkBtn setImage:[NSBundle lg_imagePathName:@"note_remark_unselected"] forState:UIControlStateNormal];
        [_remarkBtn setImage:[NSBundle lg_imagePathName:@"note_remark_selected"] forState:UIControlStateSelected];
        
        [_remarkBtn setTitleColor:kColorWithHex(0x0099ff) forState:UIControlStateNormal];
        [_remarkBtn addTarget:self action:@selector(remarkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_remarkBtn setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
    }
    return _remarkBtn;
}

- (UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = LGRGB(231, 231, 231);
    }
    return _line;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = kColorInitWithRGB(242, 242, 242, 1);
    }
    return _bottomView;
}

- (UIButton *)sourceBtn{
    if (!_sourceBtn) {
        _sourceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sourceBtn.frame = CGRectZero;
        [_sourceBtn setTitle:@"来源:听句子选择" forState:UIControlStateNormal];
        [_sourceBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];

        _sourceBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _sourceBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

        [_sourceBtn setTitleColor:kColorInitWithRGB(249, 102, 2, 1) forState:UIControlStateNormal];
        
        [_sourceBtn addTarget:self action:@selector(sourceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sourceBtn;
}

- (UIButton *)subjectBtn{
    if (!_subjectBtn) {
        _subjectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _subjectBtn.frame = CGRectZero;
        
        [_subjectBtn setTitle:@"英语" forState:UIControlStateNormal];
        [_subjectBtn setImage:[NSBundle lg_imageName:@"note_subject_unselected"] forState:UIControlStateNormal];
        _subjectBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];

        [_subjectBtn setTitleColor:kColorWithHex(0x0099ff) forState:UIControlStateNormal];
        [_subjectBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
      [_subjectBtn addTarget:self action:@selector(subjectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _subjectBtn;
}


- (LGNoteBaseTextField *)titleTextF{
    if (!_titleTextF) {
        _titleTextF = [[LGNoteBaseTextField alloc] init];
        _titleTextF.borderStyle = UITextBorderStyleNone;
        _titleTextF.backgroundColor = [UIColor whiteColor];
        _titleTextF.userInteractionEnabled = YES;
        //_titleTextF.intrinsicContentSize
        _titleTextF.placeholder = @"请输入笔记标题(50字内)";
        _titleTextF.leftView = nil;
        _titleTextF.lgDelegate = self;
        _titleTextF.maxLength = 50;
        _titleTextF.limitType = LGTextFiledKeyBoardInputTypeNoneEmoji;
        _titleTextF.textColor = LGRGB(37, 37, 37);
        _titleTextF.font = kSYSTEMFONT(18.f);
    }
    return _titleTextF;
}

- (LGNoteBaseTextView *)contentTextView{
    if (!_contentTextView) {
        _contentTextView = [[LGNoteBaseTextView alloc] initWithFrame:CGRectZero];
        _contentTextView.placeholder = @"请输入笔记内容";
        _contentTextView.placeholderColor = LGRGB(201, 201, 206);
//        _contentTextView.contentSize = CGSizeMake(kMain_Screen_Width, kMain_Screen_Height+500);
        _contentTextView.inputType = LGTextViewKeyBoardTypeEmojiLimit;
        _contentTextView.toolBarStyle = LGTextViewToolBarStyleDrawBoard;
        _contentTextView.maxLength = 50000;
        _contentTextView.textColor = LGRGB(37, 37, 37);
        _contentTextView.font = [UIFont systemFontOfSize:16];
        _contentTextView.lgDelegate = self;
        // 破解UITextView编辑和点击图片无解之题
        HPTextViewTapGestureRecognizer *textViewTapGestureRecognizer = [[HPTextViewTapGestureRecognizer alloc] init];
        textViewTapGestureRecognizer.delegate = self;
        [_contentTextView addGestureRecognizer:textViewTapGestureRecognizer];
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        
        paragraphStyle.lineSpacing = 15;// 字体的行间距
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:15],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        _contentTextView.typingAttributes = attributes;
       
        [_contentTextView showMaxTextLengthWarn:^{
            [[LGNoteMBAlert shareMBAlert] showRemindStatus:@"字数已达限制"];
        }];
    }
    return _contentTextView;
}



@end

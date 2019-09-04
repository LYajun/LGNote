//
//  LGNNewSeleteDataView.m
//  NoteDemo
//
//  Created by abc on 2019/8/21.
//  Copyright © 2019 hend. All rights reserved.
//

#import "LGNNewSeleteDataView.h"
#import "LGNConfigure.h"
#import "LGNNoteFilterCollectionViewCell.h"
#import "LGNNoteFilterCollectionReusableViewHeader.h"

@interface LGNNewSeleteDataView ()<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UITextFieldDelegate
>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *whiteView;

//自定义时间
@property (nonatomic,strong)  UILabel * tipsLabel;
@property (nonatomic,strong)  UITextField *starTimeF;
@property (nonatomic,strong)  UILabel * centreLabel;
// 时间选择器
@property (nonatomic, strong) UIDatePicker *dataPicker;


@property (nonatomic,strong)  UITextField *endTimeF;
/** 重置按钮 */
@property (nonatomic, strong) UIButton *resetBtn;
/** 确认按钮 */
@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSIndexPath *selectedTimePath;

@property (nonatomic, copy)   NSString *currentTimeID;
@property (nonatomic,strong) NSString  * starTime;
@property (nonatomic,strong) NSString * endTime;


@end

@implementation LGNNewSeleteDataView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self layoutUI];
    }
    return self;
}

- (void)dealloc{
    
    NSLog(@"销毁了LGNNewSeleteDataView");
}

- (void)layoutUI {
    
    self.window = UIApplication.sharedApplication.keyWindow;
    self.frame = CGRectMake(0, NoteNAVIGATION_HEIGHT+45, kMain_Screen_Width, kMain_Screen_Height-(NoteNAVIGATION_HEIGHT+45));
    self.backgroundColor = UIColor.clearColor;
    
    self.backView = UIView.alloc.init;
    self.backView.backgroundColor = UIColor.blackColor;
    self.backView.frame = CGRectMake(0, NoteNAVIGATION_HEIGHT+45, kMain_Screen_Width, kMain_Screen_Height-(NoteNAVIGATION_HEIGHT+45));
    self.backView.alpha = 0.0f;
    [self addSubview:self.backView];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideViewT)];
    [self.backView addGestureRecognizer:tapGR];
    
    self.contentView = UIView.alloc.init;
    self.contentView.frame = CGRectMake(0, NoteNAVIGATION_HEIGHT+45, kMain_Screen_Width, 0);
    self.contentView.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.contentView];
 
    self.whiteView =UIView.alloc.init;
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.whiteView];
    
    self.whiteView.frame = CGRectMake(0, 0,kMain_Screen_Width , 190);
//    [self.whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self);
//        make.top.equalTo(self);
//        make.height.mas_equalTo(200);
//    }];
    
    
    [self addSubview:self.collectionView];
    
    //自定义时间
    UILabel * tipsLabel = [[UILabel alloc]init];
    tipsLabel.text = @"自定义时间范围";
    tipsLabel.font = LGFontSize(13);
    tipsLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:self.tipsLabel = tipsLabel];
    
    self.centreLabel = [[UILabel alloc]init];
    self.centreLabel.text = @"~";
    self.centreLabel.textAlignment = NSTextAlignmentCenter;
    self.centreLabel.font = LGFontSize(15);
    self.centreLabel.textColor = LGRGB(102, 102, 102);
    [self addSubview:self.centreLabel];
    
    [self addSubview:self.starTimeF];
    [self addSubview:self.endTimeF];
    
    [self addSubview:self.resetBtn];
    [self addSubview:self.sureBtn];
    
    self.endTimeF.hidden = YES;
    self.starTimeF.hidden = YES;
    self.tipsLabel.hidden = YES;
    self.centreLabel.hidden = YES;
    
    
   
    
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.whiteView).offset(-15);
        make.left.equalTo(self).offset(20);
        make.width.mas_equalTo((kMain_Screen_Width-50)/2);
        make.height.mas_equalTo(35);
    }];
    
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.whiteView).offset(-15);
      make.left.equalTo(self.resetBtn.mas_right).offset(10);
        make.width.mas_equalTo((kMain_Screen_Width-50)/2);
        make.height.mas_equalTo(35);
    }];
    
   
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(140);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.left.equalTo(self).offset(12);
        make.top.equalTo(self.collectionView.mas_bottom);
        make.height.mas_equalTo(20);
    }];
    
    [self.centreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self);
    make.top.equalTo(self.collectionView.mas_bottom).offset(40);
        make.height.mas_equalTo(20);
         make.width.mas_equalTo(20);
    }];
    
    [self.starTimeF mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.centreLabel);
        make.left.equalTo(self).offset(20);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo((kMain_Screen_Width-60)/2);
    }];
    
    
    [self.endTimeF mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.centreLabel);
        make.right.equalTo(self).offset(-20);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo((kMain_Screen_Width-60)/2);
    }];
    
}

- (void)showView {
    [self.window addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.backView.alpha = 0.5;
        self.contentView.frame = (CGRect){CGPointMake(0, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.contentView.bounds)), self.contentView.frame.size};
    }];
}
- (void)hideViewT{
    
    [self hideView];
    
    if(self.delegate &&[self.delegate respondsToSelector:@selector(ClickMBL)]){
        
        
        [self.delegate ClickMBL];
    }
    
}

- (void)hideView {
    [UIView animateWithDuration:0.1 animations:^{
        self.backView.alpha = 0.0f;
        self.contentView.frame = (CGRect){CGPointMake(0, self.bounds.size.height), self.contentView.frame.size};
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)hideViewForCelerity{
    
      [self removeFromSuperview];
}

#pragma mark - UICollectionViewDataSource && delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return  1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
   return  self.dataSource.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.collectionView.frame.size.width - 50)/4, 36);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.collectionView.frame.size.width, 40);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LGNNoteFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LGNNoteFilterCollectionViewCell class]) forIndexPath:indexPath];
    [self settingSubjectCell:cell indexPath:indexPath];
    return cell;
}

- (void)settingSubjectCell:(LGNNoteFilterCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath{
   
        cell.contentLabel.text = _dataSource[indexPath.row];
//        if (self.selectedTimePath == indexPath  || [_dataSource[indexPath.row] isEqualToString:self.currentTimeID]) {
//            cell.selectedItem = YES;
//        } else {
//            cell.selectedItem = NO;
//        }
    
    if ( [_dataSource[indexPath.row] isEqualToString:self.currentTimeID]) {
        cell.selectedItem = YES;
    } else {
        cell.selectedItem = NO;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
    if(indexPath.row !=4){
        
        self.endTimeF.text = @"";
        self.starTimeF.text = @"";
        [self endEditing:YES];
        //隐藏键盘
        [self hideViewKet];
        
    }else{
         //出示键盘
        
        [self showViewKEy];
        
    }
    
    
        [self configureSubjectFilterForCollectionView:collectionView indexPath:indexPath];
    
}

- (void)configureSubjectFilterForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath{
   
    self.currentTimeID = _dataSource[indexPath.row];
    
    LGNNoteFilterCollectionViewCell *celled = (LGNNoteFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:_selectedTimePath];
    celled.selectedItem = NO;
    
    _selectedTimePath = indexPath;
    LGNNoteFilterCollectionViewCell *cell = (LGNNoteFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedItem = YES;
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    }];
}

- (void)bindViewModelParam:(NSString *)type starTime:(NSString *)starT endTime:(NSString *)endT{
    
    _currentTimeID = type;
    
    if([type isEqualToString:@"自定义"]){
        
        self.endTimeF.text = endT;
        self.starTimeF.text = starT;
    }else{
        self.endTimeF.text = @"";
        self.starTimeF.text = @"";
        
    }
    
    [self.collectionView reloadData];
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    LGNNoteFilterCollectionReusableViewHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([LGNNoteFilterCollectionReusableViewHeader class]) forIndexPath:indexPath];
   
        headerView.reusableTitle = @"时间范围";
    
    return headerView;
}

- (void)showViewKEy {
    
    
    
 
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.endTimeF.hidden = NO;
        self.starTimeF.hidden = NO;
        self.tipsLabel.hidden = NO;
        self.centreLabel.hidden = NO;
    });
    
    [UIView animateWithDuration:0.1 animations:^{
        self.whiteView.frame = CGRectMake(0, 0,kMain_Screen_Width , 290);
        
    }];
    
   
}

- (void)hideViewKet {
    [UIView animateWithDuration:0.3 animations:^{
        
        self.endTimeF.hidden = YES;
         self.starTimeF.hidden = YES;
         self.tipsLabel.hidden = YES;
         self.centreLabel.hidden = YES;
         self.whiteView.frame = CGRectMake(0, 0,kMain_Screen_Width , 190);
        
    } completion:nil];
}



#pragma mark - 确认选项
- (void)sureBtnClick:(UIButton *)sender{
    
     [self endEditing:YES];
    
    
    
    if([self.currentTimeID isEqualToString:@"自定义"]){
        
        if(IsStrEmpty(self.starTimeF.text) ){
            
            [kMBAlert showStatus:@"请选择起始时间"];
            
            return;
        }
        
        if(IsStrEmpty(self.endTimeF.text) ){
            
            [kMBAlert showStatus:@"请选择结束时间"];
            
            return;
        }
        
    }
    
    
    
    NSString * startTime;
     NSString * endTime;
    
    if([self.currentTimeID isEqualToString:@"近一周"]){
        
        
        startTime = [[[self currentThisWeekInNowDate:[self currentDateNow] atDateType:NoteDateTypeWeek]componentsSeparatedByString:@"~"] firstObject];
        
        endTime =[[[self currentThisWeekInNowDate:[self currentDateNow] atDateType:NoteDateTypeWeek]componentsSeparatedByString:@"~"] lastObject];
        
        
    }else if ([self.currentTimeID isEqualToString:@"本   月"]){
        
        startTime = [[[self currentThisWeekInNowDate:[self currentDateNow] atDateType:NoteDateTypeMonth]componentsSeparatedByString:@"~"] firstObject];
        
        endTime =[[[self currentThisWeekInNowDate:[self currentDateNow] atDateType:NoteDateTypeMonth]componentsSeparatedByString:@"~"] lastObject];
    }else if ([self.currentTimeID isEqualToString:@"自定义"]){
        
        startTime =self.starTimeF.text;
        endTime =self.endTimeF.text;
        
    }else if ([self.currentTimeID isEqualToString:@"今天"]){
        
        startTime =[self getDateString];
        endTime =[self getDateString];
        
    }
    
    else if ([self.currentTimeID isEqualToString:@"全   部"]){
        
        startTime =@"";
        endTime =@"";
        
    }
    else{
        //本学期
        
        startTime = @"2019-02-15";
        endTime =@"2019-07-01";
    }
    
    
    
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterViewDidChooseCallBack:starTime:endTime:)]) {
       
        [self.delegate filterViewDidChooseCallBack:_currentTimeID starTime:startTime endTime:endTime];
      
    }
}

- (void)resetBtnClick:(UIButton *)sender{
    
    LGNNoteFilterCollectionViewCell *celled = (LGNNoteFilterCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:_selectedTimePath];
    celled.selectedItem = NO;
    
    if(self.delegate &&[self.delegate respondsToSelector:@selector(ClickresetBtn)]){
        
        [self.delegate ClickresetBtn];
    }
    
}

#pragma mark - lazy
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 15, 10);
        layout.headerReferenceSize = CGSizeMake(self.frame.size.width, 30);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[LGNNoteFilterCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([LGNNoteFilterCollectionViewCell class])];
        [_collectionView registerClass:[LGNNoteFilterCollectionReusableViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([LGNNoteFilterCollectionReusableViewHeader class])];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [[UIButton alloc] init];
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
       // _sureBtn.titleEdgeInsets = UIEdgeInsetsMake(-20, 0, 0, 0);
        [_sureBtn setBackgroundImage:[NSBundle lg_imagePathName:@"lgN_sureBtn_noml"] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

- (UIButton *)resetBtn{
    
    if (!_resetBtn) {
        _resetBtn = [[UIButton alloc] init];
        [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [_resetBtn setTitleColor:LGRGB(67, 177, 252) forState:UIControlStateNormal];
       // _resetBtn.titleEdgeInsets = UIEdgeInsetsMake(-20, 0, 0, 0);
        [_resetBtn setBackgroundImage:[NSBundle lg_imagePathName:@"lgN_resetBtn-noml"] forState:UIControlStateNormal];
    
       //  [_resetBtn setBackgroundImage:[NSBundle lg_imagePathName:@"lgN_resetBtn_selete"] forState:UIControlStateSelected];
        [_resetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}

- (UITextField *)starTimeF{
    
    if(!_starTimeF){
        
        _starTimeF = [[UITextField alloc]init];
         _starTimeF.inputView = self.dataPicker;
        _starTimeF.backgroundColor =LGRGB(247, 247, 247);
        _starTimeF.textAlignment = NSTextAlignmentCenter;
        _starTimeF.placeholder = @"起始时间";
        _starTimeF.delegate = self;
      //  _starTimeF.borderStyle = UITextBorderStyleRoundedRect;
        _starTimeF.font = LGFontSize(15);
        [_starTimeF setValue:LGRGB(194, 194, 194) forKeyPath:@"_placeholderLabel.textColor"];
         _starTimeF.textColor = LGRGB(138, 138, 138);

    }
    return  _starTimeF;
}

- (UITextField *)endTimeF{
    
    if(!_endTimeF){
        
        _endTimeF = [[UITextField alloc]init];
        _endTimeF.inputView = self.dataPicker;
        _endTimeF.backgroundColor =LGRGB(247, 247, 247);
        _endTimeF.textAlignment = NSTextAlignmentCenter;
        _endTimeF.placeholder = @"结束时间";
        _endTimeF.delegate = self;
        _endTimeF.font = LGFontSize(15);
        [_endTimeF setValue:LGRGB(194, 194, 194) forKeyPath:@"_placeholderLabel.textColor"];
        _endTimeF.textColor = LGRGB(138, 138, 138);
        
    }
    return  _endTimeF;
}


- (UIDatePicker *)dataPicker{
    if (!_dataPicker) {
        // 创建日期选择器
        _dataPicker = [[UIDatePicker alloc] init];
        // 设置时区
        _dataPicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
        // 设置时间模式
        _dataPicker.datePickerMode = UIDatePickerModeDate;
        //设置当前日期
        _dataPicker.maximumDate = [NSDate date];
        // 监听时间值改变事件
        [_dataPicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _dataPicker;
}

-(void)textFieldDidBeginEditing:(UITextField*)textField
{
    
    
    if(![self.currentTimeID isEqualToString:@"自定义"]){
        
        _currentTimeID = @"自定义";
        
        [self.collectionView reloadData];
    }
    
}

#pragma mark - 监听值的改变
- (void)datePickerValueChanged:(UIDatePicker *)datePicker{
    
    
    // 获得时间
    NSDate *date = datePicker.date;
    // 格式化时间
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    // 时间格式
    fmt.dateFormat = @"yyyy-MM-dd";
    if ([self.starTimeF isFirstResponder]) {
        self.starTimeF.text = [fmt stringFromDate:date];
    }else{
        self.endTimeF.text = [fmt stringFromDate:date];
    }
}

//获取当天日期
-(NSString*)getDateString{
    
    
    NSDate *currentDate = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    formatter.dateFormat = @"yyyy-MM-dd";
    
    return [formatter stringFromDate:currentDate];
}

- (NSDate *)currentDateNow{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    NSDate *date = [[NSDate alloc] init];
    
    return date;
}


-(NSString *)currentThisWeekInNowDate:(NSDate *)nowDate atDateType:(NoteDateType)atDateType{
    NSInteger type;
    switch (atDateType) {
        case NoteDateTypeWeek:{
            type = NSCalendarUnitWeekOfMonth;
        }
            break;
        case NoteDateTypeMonth:{
            type = NSCalendarUnitMonth;
        }
            break;
        case NoteDateTypeYear:{
            type = NSCalendarUnitYear;
        }
            break;
        default:
            break;
    }
    
    if (!nowDate) {
        nowDate = [NSDate date];
    }
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    BOOL isOK = [calendar rangeOfUnit:type startDate:&beginDate interval:&interval forDate:nowDate];
    if (!isOK) {
        return @"时间出现错误";
    }
    endDate = [beginDate dateByAddingTimeInterval:interval-1];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *beginString = [dateFormatter stringFromDate:beginDate];
    NSString *endString = [dateFormatter stringFromDate:endDate];
    NSString *dateStr = [NSString stringWithFormat:@"%@~%@",beginString,endString];
    return dateStr;
}

@end

//
//  LGNNewFilterViewController.m
//  NoteDemo
//
//  Created by abc on 2019/8/21.
//  Copyright © 2019 hend. All rights reserved.
//

#import "LGNNewFilterViewController.h"

#import "LGNNoteFilterCollectionViewCell.h"
#import "LGNNoteFilterCollectionReusableViewHeader.h"
#import "LGNSubjectModel.h"
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_PAD (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)
@interface LGNNewFilterViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>
/** 确认按钮 */
@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath *selectedSubjectPath;
@property (nonatomic, strong) NSIndexPath *selectedSystemPath;
@property (nonatomic, copy)   NSString *currentSubjectID;
@property (nonatomic, copy)   NSString *currenSystemID;

//查看重点笔记
@property (nonatomic,strong)  UILabel* TipsLabel;

@property (nonatomic,strong)  UILabel* markTipsLabel;
@property (nonatomic,strong) UISwitch * RemarkBtn;
@property (nonatomic,strong) UIView * lineView;
@end

@implementation LGNNewFilterViewController

- (void)dealloc{
    NSLog(@"LGNNewFilterViewController释放了");
}

- (void)navigationLeft_button_event:(UIBarButtonItem *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self creatSubviews];
}
- (void)bindViewModelParam:(NSArray *)param{
    self.currentSubjectID = param[0];
    self.currenSystemID = param [1];
    
    self.RemarkBtn.on =[param [2] isEqualToString:@"1"]?YES:NO;
}

- (void)creatSubviews{
    

    [self.view addSubview:self.TipsLabel];
    [self.view addSubview:self.markTipsLabel];
    [self.view addSubview:self.RemarkBtn];
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.sureBtn];

    [self setupSubViewsContraints];
}

- (void)setupSubViewsContraints{

    
    
    [self.TipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view).offset(NoteSTATUS_HEIGHT+30);
        make.left.equalTo(self.view).offset(13);
        make.height.mas_equalTo(11);
        make.width.mas_equalTo(35);
    }];
    
  
    
    
    [self.markTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NoteNAVIGATION_HEIGHT+18);
        
      make.left.equalTo(self.view).offset(13);
        make.height.mas_equalTo(25);
    }];
    
    [self.RemarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view).offset(NoteNAVIGATION_HEIGHT+15);
        make.right.equalTo(self.view).offset(-30);
//        make.height.mas_equalTo(22);
//        make.width.mas_equalTo(35);
    }];
    
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NoteNAVIGATION_HEIGHT+59);
        
        make.left.equalTo(self.view).offset(10); make.right.equalTo(self.view).offset(-10);
        make.height.mas_equalTo(1);
    }];
    
    
    if(IS_PAD){
        [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-15);
            make.centerX.equalTo(self.view);
            make.left.equalTo(self.view).offset(130);
            make.height.mas_equalTo(80);
        }];
        
    }else{
        
        [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-15);
            make.centerX.equalTo(self.view);
            make.left.equalTo(self.view).offset(30);
            make.height.mas_equalTo(60);
        }];
    }
    
    
    
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(NoteNAVIGATION_HEIGHT+60);
        make.bottom.equalTo(self.sureBtn.mas_top);
    }];
}


#pragma mark - UICollectionViewDataSource && delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return (self.filterStyle == NewFilterStyleDefault) ? 1:2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.filterStyle == NewFilterStyleDefault) {
        return self.subjectArray.count;
    }
    return section == 0 ? self.systemArray.count:self.subjectArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.collectionView.frame.size.width - 50)/3, 36);
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
    if (self.filterStyle == NewFilterStyleDefault || indexPath.section == 1) {
        LGNSubjectModel *subjectModel = self.subjectArray[indexPath.row];
        cell.contentLabel.text = subjectModel.SubjectName;
        if (self.selectedSubjectPath == indexPath  || [subjectModel.SubjectID isEqualToString:self.currentSubjectID]) {
            cell.selectedItem = YES;
        } else {
            cell.selectedItem = NO;
        }
    } else {
        SystemModel *systemModel = self.systemArray[indexPath.row];
        cell.contentLabel.text = systemModel.SystemName;
        if (self.selectedSystemPath == indexPath  || [systemModel.SystemID isEqualToString:self.currenSystemID]) {
            cell.selectedItem = YES;
        } else {
            cell.selectedItem = NO;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.filterStyle == NewFilterStyleDefault) {
        [self configureSubjectFilterForCollectionView:collectionView indexPath:indexPath];
    } else {
        // 系统筛选
        if (indexPath.section == 0) {
            [self configureSystemFilterForCollectionView:collectionView indexPath:indexPath];
        } else {
            [self configureSubjectFilterForCollectionView:collectionView indexPath:indexPath];
        }
    }
}

- (void)configureSubjectFilterForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath{
    LGNSubjectModel * subjectModel = self.subjectArray[indexPath.row];
    self.currentSubjectID = subjectModel.SubjectID;
    
    LGNNoteFilterCollectionViewCell *celled = (LGNNoteFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:_selectedSubjectPath];
    celled.selectedItem = NO;
    
    _selectedSubjectPath = indexPath;
    LGNNoteFilterCollectionViewCell *cell = (LGNNoteFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedItem = YES;
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    }];
}

- (void)configureSystemFilterForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath{
    SystemModel *systemModel = self.systemArray[indexPath.row];
    self.currenSystemID = systemModel.SystemID;
    LGNNoteFilterCollectionViewCell *celled = (LGNNoteFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:self.selectedSystemPath];
    celled.selectedItem = NO;
    
    self.selectedSystemPath = indexPath;
    LGNNoteFilterCollectionViewCell *cell = (LGNNoteFilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedItem = YES;
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    }];
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    LGNNoteFilterCollectionReusableViewHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([LGNNoteFilterCollectionReusableViewHeader class]) forIndexPath:indexPath];
    headerView.reusableTitle = (indexPath.section == 0) ? @"系统":@"学科";
    if (self.filterStyle == NewFilterStyleDefault) {
        headerView.reusableTitle = @"学科";
    }
    return headerView;
}

#pragma mark - 确认选项
- (void)sureBtnClick:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(NewfilterViewDidChooseCallBack:systemID:remake:)]) {
        [self.delegate NewfilterViewDidChooseCallBack:self.currentSubjectID systemID:self.currenSystemID remake:self.RemarkBtn.on];
        
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - lazy
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 15, 10);
        layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 30);
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
       
        if(IS_PAD){
            
            _sureBtn.titleEdgeInsets = UIEdgeInsetsMake(-30, 0, 0, 0);
        }else{
            
            _sureBtn.titleEdgeInsets = UIEdgeInsetsMake(-20, 0, 0, 0);
        }
        [_sureBtn setBackgroundImage:[NSBundle lg_imagePathName:@"note_sureBtn"] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}



- (UILabel *)TipsLabel{
    
    if(!_TipsLabel){
        
        _TipsLabel = [[UILabel alloc]init];
        
        _TipsLabel .text = @"笔记";
        
        _TipsLabel.textAlignment = NSTextAlignmentLeft;
        _TipsLabel.textColor = LGRGB(152, 152, 152);
        
        _TipsLabel.font = LGFontSize(13);
        
        
    }
    
    return _TipsLabel;
}

- (UILabel *)markTipsLabel{
    
    if(!_markTipsLabel){
        
        _markTipsLabel = [[UILabel alloc]init];
        
        _markTipsLabel .text = @"查看重点笔记";
        
        _markTipsLabel.textAlignment = NSTextAlignmentLeft;
        _markTipsLabel.textColor = LGRGB(37, 37, 37);
        
        _markTipsLabel.font = LGFontSize(14);
        
        
    }
    
    return _markTipsLabel;
}

- (UISwitch *)RemarkBtn{
    
    if(!_RemarkBtn){
        
        _RemarkBtn = [[UISwitch alloc]init];
        _RemarkBtn.transform = CGAffineTransformMakeScale(0.92, 0.92);

    }
    
    return _RemarkBtn;
}

- (UIView *)lineView {
    
    if(!_lineView){
        
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = LGRGB(239, 239, 239);
        

    }
    
    return _lineView;
}
@end

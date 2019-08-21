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
UICollectionViewDelegateFlowLayout
>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *contentView;

//自定义时间
@property (nonatomic,strong)  UILabel * tipsLabel;
@property (nonatomic,strong)  UITextField *starTimeF;
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


- (void)layoutUI {
    
    self.window = UIApplication.sharedApplication.keyWindow;
    self.frame = CGRectMake(0, NoteNAVIGATION_HEIGHT+45, kMain_Screen_Width, kMain_Screen_Height-(NoteNAVIGATION_HEIGHT+45));
    self.backgroundColor = UIColor.clearColor;
    
    self.backView = UIView.alloc.init;
    self.backView.backgroundColor = UIColor.blackColor;
    self.backView.frame = CGRectMake(0, NoteNAVIGATION_HEIGHT+45, kMain_Screen_Width, kMain_Screen_Height-(NoteNAVIGATION_HEIGHT+45));
    self.backView.alpha = 0.0f;
    [self addSubview:self.backView];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)];
    [self.backView addGestureRecognizer:tapGR];
    
    self.contentView = UIView.alloc.init;
    self.contentView.frame = CGRectMake(0, NoteNAVIGATION_HEIGHT+45, kMain_Screen_Width, 0);
    self.contentView.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.contentView];
 
    
    [self addSubview:self.collectionView];
    [self addSubview:self.resetBtn];
    [self addSubview:self.sureBtn];
    
    //自定义时间
    UILabel * tipsLabel = [[UILabel alloc]init];
    
    
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-15);
        make.left.equalTo(self).offset(20);
        make.width.mas_equalTo((kMain_Screen_Width-50)/2);
        make.height.mas_equalTo(60);
    }];
    
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-15);
      make.left.equalTo(self.resetBtn.mas_right).offset(10);
        make.width.mas_equalTo((kMain_Screen_Width-50)/2);
        make.height.mas_equalTo(60);
    }];
    
   
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(200);
    }];
    
    
    
}

- (void)showView {
    [self.window addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.backView.alpha = 0.5;
        self.contentView.frame = (CGRect){CGPointMake(0, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.contentView.bounds)), self.contentView.frame.size};
    }];
}
- (void)hideView {
    [UIView animateWithDuration:0.25 animations:^{
        self.backView.alpha = 0.0f;
        self.contentView.frame = (CGRect){CGPointMake(0, self.bounds.size.height), self.contentView.frame.size};
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
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
        if (self.selectedTimePath == indexPath  || [_dataSource[indexPath.row] isEqualToString:self.currentTimeID]) {
            cell.selectedItem = YES;
        } else {
            cell.selectedItem = NO;
        }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
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



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    LGNNoteFilterCollectionReusableViewHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([LGNNoteFilterCollectionReusableViewHeader class]) forIndexPath:indexPath];
   
        headerView.reusableTitle = @"时间范围";
    
    return headerView;
}

#pragma mark - 确认选项
- (void)sureBtnClick:(UIButton *)sender{
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterViewDidChooseCallBack:starTime:endTime:)]) {
       
        [self.delegate filterViewDidChooseCallBack:_currentTimeID starTime:_starTime endTime:_endTime];
      
    }
}

- (void)resetBtnClick:(UIButton *)sender{
    
    
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
        _sureBtn.titleEdgeInsets = UIEdgeInsetsMake(-20, 0, 0, 0);
        [_sureBtn setBackgroundImage:[NSBundle lg_imagePathName:@"note_sureBtn"] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

- (UIButton *)resetBtn{
    
    if (!_resetBtn) {
        _resetBtn = [[UIButton alloc] init];
        [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        _resetBtn.titleEdgeInsets = UIEdgeInsetsMake(-20, 0, 0, 0);
        [_resetBtn setBackgroundImage:[NSBundle lg_imagePathName:@"note_sureBtn"] forState:UIControlStateNormal];
        [_resetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}



@end

//
//  NoteMainTableView.m
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "LGNNoteMainTableView.h"
#import "LGNoteConfigure.h"
#import "LGNNoteMainTableViewCell.h"
#import "LGNViewModel.h"
#import "LGNNoteModel.h"
#import "LGNNoteEditViewController.h"
#import "LGNNoteMainImageTableViewCell.h"
#import "LGNNoteMoreImageTableViewCell.h"

@interface LGNNoteMainTableView () <UITableViewDataSource,UITableViewDelegate>{
    
     NSInteger  _allCount;
}

@property (nonatomic,assign) BOOL  isHvae;
@property (nonatomic, strong) LGNViewModel *viewModel;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation LGNNoteMainTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        self.delegate = self;
        self.dataSource = self;
        self.rowHeight = 170;

        
        [self registerClass:[LGNNoteMainTableViewCell class] forCellReuseIdentifier:NSStringFromClass([LGNNoteMainTableViewCell class])];
        [self registerClass:[LGNNoteMainImageTableViewCell class] forCellReuseIdentifier:NSStringFromClass([LGNNoteMainImageTableViewCell class])];
        [self registerClass:[LGNNoteMoreImageTableViewCell class] forCellReuseIdentifier:NSStringFromClass([LGNNoteMoreImageTableViewCell class])];
        
  
//            [self allocInitRefreshHeader:YES allocInitFooter:YES];
        
        
        
        
         
    }
    return self;
}


    

- (void)lg_bindViewModel:(id)viewModel{
    self.viewModel = viewModel;
    @weakify(self);
    
  
    
    [self.viewModel.refreshSubject subscribeNext:^(NSArray *  _Nullable x) {
        
        
        @strongify(self);
        self.dataArray = x;
        if (IsArrEmpty(self.dataArray)) {
            self.requestStatus = LGBaseTableViewRequestStatusNoData;
            
            if(self.notoDataCall){
            self.notoDataCall(0);
            }
            
        } else {
            
            self.isHvae = YES;
            if(self.notoDataCall){
                self.notoDataCall(1);
            }
            
            NSInteger papge;
           papge = self.viewModel.paramModel.PageIndex;
            NSInteger size  = self.viewModel.paramModel.PageSize;
            
            if(papge ==1){
                _allCount = 0;
            }
            
            //预防搜索内容编辑修改返回page==0崩溃
            if(papge == 0){
                self.requestStatus = LGBaseTableViewRequestStatusNormal;
                [self.mj_footer endRefreshing];
                return ;
            }
            
            
            if (self.viewModel.totalCount / (papge*size) == 0 || (self.viewModel.totalCount%(papge*size) == 0 && self.viewModel.totalCount == (papge*size))) {
                self.requestStatus = LGBaseTableViewRequestStatusNormal;
                [self.mj_footer endRefreshingWithNoMoreData];
            } else {
                self.requestStatus = LGBaseTableViewRequestStatusNormal;
                [self.mj_footer endRefreshing];
            }
        }
        [self reloadData];
    }];
    
    [self.viewModel.operateSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        
        if([x containsString:@"失败"]){
        self.requestStatus = LGBaseTableViewRequestStatusNormal;
            [self reloadData];
            return ;
        }
        
        if (x) {
            self.requestStatus = LGBaseTableViewRequestStatusStartLoading;
            [self.viewModel.refreshCommand execute:self.viewModel.paramModel];
            [self.mj_footer endRefreshing];
            _allCount = 0;
        }
    }];

    [self.viewModel.searchSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        
        
        self.dataArray = x;
        self.requestStatus = IsArrEmpty(x) ? LGBaseTableViewRequestStatusNoData:LGBaseTableViewRequestStatusNormal;
        // [self.mj_footer endRefreshing];
        [self reloadData];
        _allCount = 0;
    }];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LGNNoteModel *model = self.dataArray[indexPath.section];

    
    // 判断是不是图文混排类型
    if (model.imgaeUrls.count <= 0) {
        
//        static NSString * const MainTableViewCell = @"LGNNoteMainTableViewCell";
//
//        LGNNoteMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LGNNoteMainTableViewCell class]) forIndexPath:indexPath];
//
//        if (!cell) {
//            cell = [[LGNNoteMainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MainTableViewCell];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
        
//
        LGNNoteMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LGNNoteMainTableViewCell class]) forIndexPath:indexPath];
        
      //  cell.tag =1;
        cell.searchContent =_searchContent;
        cell.isSearchVC = _isSearchVC;
         cell.MaterialName = self.viewModel.paramModel.MaterialName;
        [cell configureCellForDataSource:model indexPath:indexPath];
       
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        return cell;
    } else if (model.imgaeUrls > 0 && model.mixTextImage) {
        
//        static NSString * const ImageTableViewCell = @"LGNNoteMainImageTableViewCell";
//
//        LGNNoteMainImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LGNNoteMainImageTableViewCell class]) forIndexPath:indexPath];
//
//        if (!cell) {
//            cell = [[LGNNoteMainImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ImageTableViewCell];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
        // cell.tag =1;
        
        LGNNoteMainImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LGNNoteMainImageTableViewCell class]) forIndexPath:indexPath];
        cell.searchContent =_searchContent;
        cell.isSearchVC = _isSearchVC;
          cell.MaterialName = self.viewModel.paramModel.MaterialName;
        [cell configureCellForDataSource:model indexPath:indexPath];
        
         cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    } else {
        
//        static NSString * const MoreImageTableViewCell = @"LGNNoteMoreImageTableViewCell";
//
//        LGNNoteMoreImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LGNNoteMoreImageTableViewCell class]) forIndexPath:indexPath];
//
//        if (!cell) {
//            cell = [[LGNNoteMoreImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MoreImageTableViewCell];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
//        // cell.tag =1;
        LGNNoteMoreImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LGNNoteMoreImageTableViewCell class]) forIndexPath:indexPath];
        cell.searchContent =_searchContent;
        cell.isSearchVC = _isSearchVC;
        cell.MaterialName = self.viewModel.paramModel.MaterialName;
        [cell configureCellForDataSource:model indexPath:indexPath];
      
         cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        //self.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
//    if(indexPath.section>3 ||_allCount>=10){
//        return;
//    }
    
//    if(cell.tag == 2){
//        return;
//    }
    

    NSLog(@"==%zd==",indexPath.section);
    
    if(self.isHvae == NO){
        
        return;
    }
    
    if(indexPath.section == self.dataArray.count-1){
        
        self.isHvae = NO;
    }
    

    
    _allCount +=indexPath.section;
    
    cell.tag = 2;
    
    CGRect cellFrameStart = cell.contentView.frame;
    cellFrameStart.origin.x = cellFrameStart.size.width;
    cell.contentView.frame = cellFrameStart;
    NSTimeInterval time = indexPath.section*0.1;
    
    
    [UIView animateWithDuration:0.6 delay:time options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect cellFrameEnd = cell.contentView.frame;
        cellFrameEnd.origin.x = 0;
        cell.contentView.frame = cellFrameEnd;
    } completion:^(BOOL finisahed){
        
    }];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 2:12;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.viewModel.isSearchOperation ? NO:YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
   
        LGNNoteModel *model = self.dataArray[indexPath.section];
        @weakify(self);
        [kMBAlert showAlertControllerOn:self.ownerController title:@"提示" message:@"您确定要删除该条笔记吗?" oneTitle:@"确定" oneHandle:^(UIAlertAction * _Nonnull one) {
            @strongify(self);
           
            self.requestStatus = LGBaseTableViewRequestDeleteLoading;
            
            NSDictionary *param = [self configureOperatedModel:model];
            [self.viewModel.operateCommand execute:param];
        } twoTitle:@"取消" twoHandle:^(UIAlertAction * _Nonnull two) {
            
        } completion:^{
            
        }];
       
    }];
    
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    config.performsFirstActionWithFullSwipe = NO;
    return config;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LGNNoteModel *model = self.dataArray[indexPath.section];
        @weakify(self);
        [kMBAlert showAlertControllerOn:self.ownerController title:@"提示" message:@"您确定要删除该条笔记吗?" oneTitle:@"确定" oneHandle:^(UIAlertAction * _Nonnull one) {
            @strongify(self);
            
           
            self.requestStatus = LGBaseTableViewRequestDeleteLoading;
            NSDictionary *param = [self configureOperatedModel:model];
            [self.viewModel.operateCommand execute:param];
        } twoTitle:@"取消" twoHandle:^(UIAlertAction * _Nonnull two) {
            
        } completion:^{
            
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    

    
    LGNNoteEditViewController *editVC = [[LGNNoteEditViewController alloc] init];
    editVC.updateSubject = [RACSubject subject];
    LGNNoteModel *model = self.dataArray[indexPath.section];
    
    
    NSDictionary *param = [self.viewModel.paramModel mj_keyValues];
    editVC.paramModel = [LGNParamModel mj_objectWithKeyValues:param];
    editVC.isNewNote = NO;
    editVC.isSearchNote = _isSearchVC;
    editVC.searchContent= _searchContent;
    editVC.subjectArray = self.viewModel.subjectArray;
    [editVC editNoteWithDataSource:model];

    [self.ownerController.navigationController pushViewController:editVC animated:YES];
    @weakify(self);
    [editVC.updateSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        
         self.viewModel.paramModel.PageIndex = 1;
        
        self.requestStatus = LGBaseTableViewRequestStatusStartLoading;
        [self.viewModel.refreshCommand execute:self.viewModel.paramModel];
    }];
}

- (NSDictionary *)configureOperatedModel:(LGNNoteModel *)model{
    model.UserID = self.viewModel.paramModel.UserID;
    model.SchoolID = self.viewModel.paramModel.SchoolID;
    model.UserType = self.viewModel.paramModel.UserType;
    model.OperateFlag = self.viewModel.paramModel.OperateFlag = 3;
    return [model mj_keyValues];
}



@end

//
//  NoteMainViewController.m
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "LGNNoteMainViewController.h"
#import "LGNNoteMainTableView.h"
#import "LGNViewModel.h"
#import "LGNNoteSearchViewController.h"
#import "LGNNoteFilterViewController.h"
#import "LGNNoteEditViewController.h"
#import "LGNoteConfigure.h"
#import "LGNSearchToolView.h"
#import "LGNNewSearchToolView.h"
#import "LGNNewSeleteDataView.h"
#import "LGNNewFilterViewController.h"

@interface LGNNoteMainViewController ()
<
LGNoteBaseTableViewCustomDelegate,
LGFilterViewControllerDelegate,
SearchToolViewDelegate,
NewSearchToolViewDelegate,
LGNNewSeleteDataViewDelegate,
LGNNewFilterDelegate
>

@property (nonatomic,strong) LGNNewFilterViewController* filterViewController;
// 记录遮盖按钮
@property (nonatomic, strong) UIButton *corverBtn;
@property (nonatomic, strong) LGNViewModel *viewModel;
@property (nonatomic, strong) LGNSearchToolView *toolView;
@property (nonatomic, strong) LGNNewSearchToolView *newToolView;
@property (nonatomic, strong) LGNNewSeleteDataView *seleteDataView;

@property (nonatomic, assign) NoteNaviBarLeftItemStyle style;
@property (nonatomic, assign) SystemUsedType systemType;
@property (nonatomic, copy)   LeftNaviBarItemBlock leftItemBlock;

//选择时间类型
@property (nonatomic,strong) NSString * DateType;
@property (nonatomic,strong) NSString * starTime;
@property (nonatomic,strong) NSString * endTime;

@end

@implementation LGNNoteMainViewController

- (instancetype)init{
    return [self initWithNaviBarLeftItemStyle:NoteMainViewControllerNaviBarStyleBack systemType:SystemUsedTypeAssistanter];
}

- (instancetype)initWithNaviBarLeftItemStyle:(NoteNaviBarLeftItemStyle)style systemType:(SystemUsedType)type{
    if (self = [super init]) {
        _style = style;
        _systemType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的笔记";
    [self lg_commonInit];
    [self creatSubViews];
    [self lg_bindData];
    
    
}


- (void)lg_commonInit{
    [self addRightNavigationBar];
    [self addLeftNavigationBar];
}

- (void)creatSubViews{
    if(self.systemType == SystemUsedTypeNew){
          [self.view addSubview: self.newToolView];
           [self.view addSubview:self.tableView];
         self.seleteDataView = [[LGNNewSeleteDataView alloc] init];
    
        self.DateType = @"全   部";
        
        self.seleteDataView.dataSource =@[@"今天",@"近一周",@"近一月",@"本学期",@"自定义"];
         self.seleteDataView.delegate = self;
      
        [self.newToolView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.centerX.top.equalTo(self.view);
            make.height.mas_equalTo(45);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
             make.top.equalTo(self.newToolView.mas_bottom);
        }];
    }else{
          [self.view addSubview:self.toolView];
        [self.view addSubview:self.tableView];
        
            [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.centerX.top.equalTo(self.view);
                make.height.mas_equalTo(45);
            }];
            [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self.view);
                make.top.equalTo(self.toolView.mas_bottom);
            }];
        
    }
    
  
 
   // [self setupSubViewsContraints];
}

- (void)setupSubViewsContraints{

    
   
}


- (void)addRightNavigationBar{
    UIImage *image = [NSBundle lg_imagePathName:@"note_add"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(rightNavigationBar:)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
}

- (void)addLeftNavigationBar{
    
    
    UIImage *image = [NSBundle lg_imagePathName:@"note_back"];
    _leftBarItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftNavigationBar:)];
    if (_style != NoteMainViewControllerNaviBarStyleUserIcon) {
        [_leftBarItem setTintColor:[UIColor whiteColor]];
        self.navigationItem.leftBarButtonItem = _leftBarItem;
    }
}

- (void)lg_bindData{
    self.viewModel.paramModel = self.paramModel;
    [self.viewModel.refreshCommand execute:self.viewModel.paramModel];
    
}

#pragma mark - AddNote
- (void)rightNavigationBar:(UIBarButtonItem *)sender{
     [self.seleteDataView hideViewForCelerity];
    self.newToolView.seleteBtn.selected = NO;
    
    LGNNoteEditViewController *editController = [[LGNNoteEditViewController alloc] init];
    editController.isNewNote = YES;
    editController.paramModel = self.paramModel;
    editController.updateSubject = [RACSubject subject];
    [self.navigationController pushViewController:editController animated:YES];
    @weakify(self,editController);
    [editController.updateSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
    
        [self reSettingParams];
        self.viewModel.paramModel.PageIndex = 1;
        self.tableView.requestStatus = LGBaseTableViewRequestStatusStartLoading;
        [self.viewModel.refreshCommand execute:self.viewModel.paramModel];
    }];
    
    
    [RACObserve(self.viewModel, subjectArray) subscribeNext:^(id  _Nullable x) {
        
        
        @strongify(editController);
        editController.subjectArray = x;
    }];
}

- (void)leftNavigationBar:(UIBarButtonItem *)sender{
    
    [self.seleteDataView hideViewForCelerity];
    self.newToolView.seleteBtn.selected = NO;
    
    if (_style == NoteMainViewControllerNaviBarStyleBack) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (self.leftItemBlock) {
        self.leftItemBlock();
    }
}

#pragma mark - Block
- (void)leftNaviBarItemClickEvent:(LeftNaviBarItemBlock)block{
    _leftItemBlock = block;
}

#pragma mark - TableViewdelegate
- (void)baseTableView:(LGNoteBaseTableView *)tableView pullUpRefresh:(BOOL)upRefresh pullDownRefresh:(BOOL)downRefresh{
    if (upRefresh) {
        self.viewModel.paramModel.PageIndex = 1;
        [self.viewModel.refreshCommand execute:self.viewModel.paramModel];
    }
    
    if (downRefresh) {
        self.viewModel.paramModel.PageIndex ++;
        [self.viewModel.nextPageCommand execute:self.viewModel.paramModel];
    }
}

#pragma mark - SearchToolDelegate
- (void)enterSearchEvent{
    
    LGNNoteSearchViewController *searchVC = [[LGNNoteSearchViewController alloc] init];
    searchVC.subjectArray =self.viewModel.subjectArray;
    [searchVC configureParam:self.viewModel.paramModel];
    searchVC.backRefreshSubject = [RACSubject subject];
    [self.navigationController pushViewController:searchVC animated:YES];
    @weakify(self);
    [searchVC.backRefreshSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.viewModel.paramModel.PageIndex = 1;
        [self reSettingParams];
        self.tableView.requestStatus = LGBaseTableViewRequestStatusStartLoading;
        [self.viewModel.refreshCommand execute:self.viewModel.paramModel];
       
    }];
}

- (void)filterEvent{
    
  
    LGNNoteFilterViewController *filterController = [[LGNNoteFilterViewController alloc] init];
    filterController.filterStyle = FilterStyleCustom;
    filterController.delegate = self;
    [filterController bindViewModelParam:@[self.viewModel.paramModel.C_SubjectID,self.viewModel.paramModel.C_SystemID]];
    @weakify(filterController);
    [RACObserve(self.viewModel, subjectArray) subscribeNext:^(id  _Nullable x) {
        @strongify(filterController);
        filterController.subjectArray = x;
    }];
    [RACObserve(self.viewModel, systemArray) subscribeNext:^(id  _Nullable x) {
        @strongify(filterController);
        filterController.systemArray = x;
    }];
    [self.navigationController pushViewController:filterController animated:YES];
}
#pragma mark - NewSearchToolViewDelegate
- (void)NewenterSearchEvent{
    [self.seleteDataView hideViewForCelerity];
    self.newToolView.seleteBtn.selected = NO;
    LGNNoteSearchViewController *searchVC = [[LGNNoteSearchViewController alloc] init];
    searchVC.subjectArray =self.viewModel.subjectArray;
    [searchVC configureParam:self.viewModel.paramModel];
    searchVC.backRefreshSubject = [RACSubject subject];
    [self.navigationController pushViewController:searchVC animated:YES];
    @weakify(self);
    [searchVC.backRefreshSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.viewModel.paramModel.PageIndex = 1;
        [self reSettingParams];
        self.tableView.requestStatus = LGBaseTableViewRequestStatusStartLoading;
        [self.viewModel.refreshCommand execute:self.viewModel.paramModel];
        
    }];
}

- (void)NewfilterEvent{
    
   [self.seleteDataView hideViewForCelerity];
    self.newToolView.seleteBtn.selected = NO;
    
    
    if (self.filterViewController == nil) {
          LGNNewFilterViewController *filterController = [[LGNNewFilterViewController alloc] init];
               filterController.view.frame = CGRectMake(kMain_Screen_Width, 0, kMain_Screen_Width-50, kMain_Screen_Height);
        
        self.filterViewController = filterController;
        
        filterController.filterStyle = FilterStyleCustom;
        filterController.delegate = self;
        [filterController bindViewModelParam:@[self.viewModel.paramModel.C_SubjectID,self.viewModel.paramModel.C_SystemID,self.viewModel.paramModel.IsKeyPoint]];
        @weakify(filterController);
        [RACObserve(self.viewModel, subjectArray) subscribeNext:^(id  _Nullable x) {
            @strongify(filterController);
            filterController.subjectArray = x;
        }];
        [RACObserve(self.viewModel, systemArray) subscribeNext:^(id  _Nullable x) {
            @strongify(filterController);
            filterController.systemArray = x;
        }];
       // [self.navigationController pushViewController:filterController animated:YES];
        
        
        [UIView animateWithDuration:0.25 animations:^{
                        filterController.view.frame = CGRectMake(50, 0, kMain_Screen_Width-50, kMain_Screen_Height);
            
                    }];

        
       [[UIApplication sharedApplication].keyWindow addSubview:filterController.view];
        
        
        // 创建遮盖按钮
                if (self.corverBtn == nil) {
                    UIButton *corverBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, kMain_Screen_Height)];
                    corverBtn.backgroundColor = [UIColor blackColor];
                    corverBtn.alpha = 0.2;
                    self.corverBtn = corverBtn;
                    [corverBtn addTarget:self action:@selector(corverBtnLisenter:) forControlEvents:UIControlEventTouchUpInside];
   
                   [[UIApplication sharedApplication].keyWindow addSubview:corverBtn];
                    
                }else{
                    self.corverBtn.hidden = NO;
                }
            }
            //如果不为空，将其加载出来
            else
            {
                [UIView animateWithDuration:0.25 animations:^{
                    self.filterViewController.view.frame = CGRectMake(50, 0, kMain_Screen_Width-50, kMain_Screen_Height);
                    // self.chooseVC = nil;
                    self.corverBtn.hidden = NO;
                }];
        
        
        
    }
  
    
   
}
# pragma mark - LGNNewFilterDelegate

- (void)NewfilterViewDidChooseCallBack:(NSString *)subjecID systemID:(NSString *)systemID remake:(BOOL)remake{
    [self corverBtnLisenter:self.corverBtn];
    
    // 是否是查看重点笔记；1表示查看重点笔记，-1是查看全部笔记
    
    self.viewModel.paramModel.IsKeyPoint = remake ? @"1":@"-1";
    
    self.viewModel.paramModel.C_SubjectID = subjecID;
    self.viewModel.paramModel.C_SystemID = systemID;
    self.tableView.requestStatus = LGBaseTableViewRequestStatusStartLoading;
    
    //筛选时重置PageIndex为1 查看全部的.
    self.viewModel.paramModel.PageIndex = 1;
    [self.viewModel.refreshCommand execute:self.viewModel.paramModel];
    

    
//    if([subjecID isEqualToString:@"All"] && [systemID isEqualToString:@"All"]){
//
//        [self.toolView.filterBtn setImage:[NSBundle lg_imagePathName:@"note_filter"] forState:UIControlStateNormal];
//    }else{
//
//        [self.toolView.filterBtn setImage:[NSBundle lg_imagePathName:@"note_filter_sel"] forState:UIControlStateNormal];
//    }
    
    
}

- (void)NewfilterViewDidChooseCallBack:(NSString *)subjecID systemID:(NSString *)systemID{
    
  
}


# pragma mark - 遮盖按钮的点击事件
- (void)corverBtnLisenter:(UIButton *)button{
    
    [UIView animateWithDuration:0.25 animations:^{
        self.filterViewController.view.frame = CGRectMake(kMain_Screen_Width, 0, kMain_Screen_Width-100, kMain_Screen_Height);
            self.filterViewController = nil;
        
       // [self.filterViewController removeFromParentViewController];
    }];
    button.hidden = YES;
}

/**
 *  监听拖拽手势回调
 */
- (void)panRecognizer:(UIPanGestureRecognizer *)panRecognizer{
//    // 获得移动点，以第一个点作为参考点
//   // CGPoint point = [panRecognizer translationInView:self.rightView];
//    //        NSLog(@"%f--%f",point.x,point.y);
//    if (panRecognizer.state == UIGestureRecognizerStateEnded && point.x < -5) {
//    }else if (panRecognizer.state == UIGestureRecognizerStateEnded && point.x > 10){
//        [UIView animateWithDuration:0.25 animations:^{
//            self.filterViewController.view.frame = CGRectMake(kMain_Screen_Width, 0, kMain_Screen_Width-100, kMain_Screen_Height);
//            self.filterViewController = nil;
//            self.corverBtn.hidden = YES;
//        }];
//    }
}

- (void)NewSeleteEvent:(BOOL)selete{
    
    if(selete){
        
        [self.seleteDataView bindViewModelParam:_DateType starTime:_starTime endTime:_endTime];
        
       [self.seleteDataView showView];
        
        
     if(IsStrEmpty(self.viewModel.paramModel.TermStartTime)){
            [self.viewModel.getTermTimeCommand execute:self.viewModel.paramModel];
        }
        
    }else{
        
         [self.seleteDataView hideView];
    }
    
    
    
    NSLog(@"选择时间");
}

#pragma mark -LGNNewSeleteDataViewDelegate
- (void)filterViewDidChooseCallBack:(NSString *)time starTime:(NSString *)starTime endTime:(NSString *)endTime{
    
    _DateType = time;
    _starTime = starTime;
    _endTime = endTime;
    
    if([time isEqualToString:@"本学期"]){
        
        _starTime = self.viewModel.paramModel.TermStartTime;
        _endTime = self.viewModel.paramModel.TermEndTime;
    }
      
    
    
     [self.newToolView.seleteBtn setTitle:time forState:UIControlStateNormal];
    
    [self.seleteDataView hideView];
     self.newToolView.seleteBtn.selected = NO;
    
      //根据时间请求数据
    self.viewModel.paramModel.StartTime = _starTime;
    self.viewModel.paramModel.EndTime = _endTime;
    
    self.tableView.requestStatus = LGBaseTableViewRequestStatusStartLoading;
    
    //筛选时重置PageIndex为1 查看全部的.
    self.viewModel.paramModel.PageIndex = 1;
    [self.viewModel.refreshCommand execute:self.viewModel.paramModel];
    
}

- (void)ClickresetBtn{
    
    _DateType =@"全   部";
    //重置时间为空
    
 
    
    [self.newToolView.seleteBtn setTitle:@"全   部" forState:UIControlStateNormal];
    self.newToolView.seleteBtn.selected = NO;
    
     [self.seleteDataView hideView];
    
    self.viewModel.paramModel.StartTime = @"";
    self.viewModel.paramModel.EndTime = @"";
    
    self.tableView.requestStatus = LGBaseTableViewRequestStatusStartLoading;
    
    //筛选时重置PageIndex为1 查看全部的.
    self.viewModel.paramModel.PageIndex = 1;
    [self.viewModel.refreshCommand execute:self.viewModel.paramModel];
    
}

- (void)ClickMBL{
    
     self.newToolView.seleteBtn.selected = NO;
}

#pragma mark - FilterDelegate
- (void)filterViewDidChooseCallBack:(NSString *)subjecID systemID:(NSString *)systemID{
    self.viewModel.paramModel.C_SubjectID = subjecID;
    self.viewModel.paramModel.C_SystemID = systemID;
    self.tableView.requestStatus = LGBaseTableViewRequestStatusStartLoading;
    
    //筛选时重置PageIndex为1 查看全部的.
    self.viewModel.paramModel.PageIndex = 1;
    [self.viewModel.refreshCommand execute:self.viewModel.paramModel];
    
    
    if([subjecID isEqualToString:@"All"] && [systemID isEqualToString:@"All"]){
        
          [self.toolView.filterBtn setImage:[NSBundle lg_imagePathName:@"note_filter"] forState:UIControlStateNormal];
    }else{
        
          [self.toolView.filterBtn setImage:[NSBundle lg_imagePathName:@"note_filter_sel"] forState:UIControlStateNormal];
    }
    
    
}

- (void)remarkEvent:(BOOL)remark{
    // 是否是查看重点笔记；1表示查看重点笔记，-1是查看全部笔记
    
    self.viewModel.paramModel.IsKeyPoint = remark ? @"1":@"-1";
    //筛选时重置PageIndex为1 查看全部的.
    self.viewModel.paramModel.PageIndex = 1;
    self.tableView.requestStatus = LGBaseTableViewRequestStatusStartLoading;
    
    [self.viewModel.refreshCommand execute:self.viewModel.paramModel];
}

// 重置参数（添加笔记之后的操作）
- (void)reSettingParams{
    if (self.systemType == SystemUsedTypeAssistanter) {
        self.viewModel.paramModel.C_SubjectID = @"All";
        self.viewModel.paramModel.C_SystemID = @"All";
    } else {
        self.viewModel.paramModel.C_SystemID = self.viewModel.paramModel.SystemID;
    }
    
     [self.toolView.filterBtn setImage:[NSBundle lg_imagePathName:@"note_filter"] forState:UIControlStateNormal];
    self.viewModel.paramModel.IsKeyPoint = @"-1";
    [self.toolView reSettingRemarkButtonUnSelected];
    
    if(self.systemType ==SystemUsedTypeNew){
        
        //重置时间
        self.viewModel.paramModel.StartTime = @"";
        self.viewModel.paramModel.EndTime = @"";
        self.DateType = @"全   部";
        [self.newToolView.seleteBtn setTitle:@"全   部" forState:UIControlStateNormal];
    }
    
    
}

#pragma mark - setter
- (void)setLeftBarItem:(UIBarButtonItem *)leftBarItem{
    _leftBarItem = leftBarItem;
    self.navigationItem.leftBarButtonItem = leftBarItem;
}

#pragma mark - lazy
- (LGNNoteMainTableView *)tableView{
    if (!_tableView) {
        _tableView = [[LGNNoteMainTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.isNotoSearchVC = NO;
        _tableView.ownerController = self;
        _tableView.cusDelegate = self;
        _tableView.requestStatus = LGBaseTableViewRequestStatusStartLoading;
    [_tableView lg_bindViewModel:self.viewModel];
    
        @weakify(self);

        self.tableView.notoDataCall = ^(NSInteger page) {
           
        @strongify(self);
//            [self.viewModel.paramModel.C_SubjectID isEqualToString:@"All"] && [self.viewModel.paramModel.C_SystemID isEqualToString:@"All"]&&
            
            if(page ==0 && self.viewModel.paramModel.PageIndex==1){
                if([self.viewModel.paramModel.IsKeyPoint isEqualToString:@"-1"]){
                    
                    self_weak_.toolView.filterBtn.hidden = YES;
                    self_weak_.toolView.remarkBtn.hidden = YES;
                    
                }
            }else{
                self_weak_.toolView.filterBtn.hidden = NO;
                self_weak_.toolView.remarkBtn.hidden = NO;
            }
            
           
            
        } ;
    
    }
    return _tableView;
}

- (LGNViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[LGNViewModel alloc] init];
    }
    return _viewModel;
}

- (LGNSearchToolView *)toolView{
    if (!_toolView) {
        LGNSearchToolViewConfigure *configure = [[LGNSearchToolViewConfigure alloc] init];
        configure.style = (_systemType == SystemUsedTypeAssistanter) ? SearchToolViewStyleFilter:SearchToolViewStyleDefault;
        _toolView = [[LGNSearchToolView alloc] initWithFrame:CGRectZero configure:configure];
        _toolView.delegate = self;
    }
    return _toolView;
}

- (LGNNewSearchToolView *)newToolView{
    
    if (!_newToolView) {
        LGNSearchToolViewConfigure *configure = [[LGNSearchToolViewConfigure alloc] init];
        configure.style = (_systemType == SystemUsedTypeAssistanter) ? SearchToolViewStyleFilter:SearchToolViewStyleDefault;
        _newToolView = [[LGNNewSearchToolView alloc] initWithFrame:CGRectZero configure:configure];
        _newToolView.delegate = self;
    }
    return _newToolView;
    
}


- (LGNParamModel *)paramModel{
    if (!_paramModel) {
        _paramModel = [[LGNParamModel alloc] init];
    }
    return _paramModel;
}


@end

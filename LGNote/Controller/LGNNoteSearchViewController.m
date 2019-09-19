//
//  NoteSearchViewController.m
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "LGNNoteSearchViewController.h"
#import "LGNViewModel.h"
#import "LGNNoteMainTableView.h"
#import "LGNoteBaseTextField.h"
#import "LGNoteConfigure.h"
@interface LGNNoteSearchViewController () <LGNoteBaseTextFieldDelegate,UITextFieldDelegate>

@property (nonatomic, strong) LGNoteBaseTextField *searchBar;
@property (nonatomic, strong) LGNNoteMainTableView *tableView;
@property (nonatomic, copy)   NSArray *searchResultArray;
@property (nonatomic, strong) UIButton *searchBtn;
@property (nonatomic, strong) UIView *searchBgView;
@property (nonatomic, strong) LGNViewModel *viewModel;

@property (nonatomic,assign) BOOL  iscomeblack;
@end

@implementation LGNNoteSearchViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    _iscomeblack = NO;
  
 
    
    if (!IsStrEmpty(self.searchBar.text) ) {
        self.viewModel.paramModel.SearchKeycon =self.searchBar.text;

        
        [self searchEvent];

    }
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
      [self.searchBar becomeFirstResponder];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    
    _iscomeblack = YES;
    
    [self.searchBar resignFirstResponder];
    
  

}

- (void)leftNavigationBar:(id)sender{
    if (self.backRefreshSubject) {
        [self.backRefreshSubject sendNext:@"back"];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = self.searchBgView;
    [self addLeftItem];
    
    [self createSubViews];
    
}

- (void)addLeftItem{
    UIImage *image = [NSBundle lg_imagePathName:@"note_back"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftNavigationBar:)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
}

- (void)createSubViews{
    self.tableView.isSearchVC = YES;
    [self.view addSubview:self.tableView];
    
//    self.tableView.frame = CGRectMake(0, 0, kMain_Screen_Width, kMain_Screen_Height);
//    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)configureParam:(LGNParamModel *)paramModel{
    NSDictionary *param = [paramModel mj_keyValues];
    self.viewModel.paramModel = [LGNParamModel mj_objectWithKeyValues:param];
    self.viewModel.paramModel.PageSize = 0;
    self.viewModel.paramModel.PageIndex = 0;
    
    self.viewModel.subjectArray = _subjectArray;

}

#pragma mark - TextFieldDelegate
- (void)lg_textFieldDidChange:(LGNoteBaseTextField *)textField{
    self.viewModel.paramModel.SearchKeycon = textField.text;
    
    self.tableView.searchContent = textField.text;
}

- (void)lg_textFieldDidEndEditing:(LGNoteBaseTextField *)textField{
   

    if(_iscomeblack){
        return;
    }
    
    [self searchEvent];
    
    
}



- (void)searchBtnEvent:(UIButton *)sender{
        
    [self.searchBar resignFirstResponder];
//   [self searchEvent];
}

// 搜索
- (void)searchEvent{
    

    if (IsStrEmpty(self.searchBar.text)) {
        [kMBAlert showRemindStatus:@"请输入搜索关键字!"];
        return;
    }
    
    self.tableView.requestStatus = LGBaseTableViewRequestStatusStartLoading;

    
      [self.viewModel.searchCommand execute:self.viewModel.paramModel];
    
    
 
  
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.searchBar resignFirstResponder];

    [self searchEvent];
    return YES;
}


-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    
    self.viewModel.paramModel.SearchKeycon =@"ResultEr-ro=r+C&ode";
    
    [self searchEvent];

    
    return YES;
}

#pragma mark - lazy
- (LGNoteBaseTextField *)searchBar{
    if (!_searchBar) {
        _searchBar = [[LGNoteBaseTextField alloc] init];
        _searchBar.layer.cornerRadius = 15.f;
        _searchBar.layer.masksToBounds = YES;
        _searchBar.borderStyle = UITextBorderStyleNone;
    _searchBar.clearButtonMode=UITextFieldViewModeAlways;
        _searchBar.limitType = LGTextFiledKeyBoardInputTypeNoneEmoji;
        _searchBar.placeholder = @"请输入笔记标题/来源关键字搜索";
        
        _searchBar.letItem.enabled = NO;
        _searchBar.letItem.title = @"";
        
        _searchBar.delegate = self;
        _searchBar.returnKeyType = UIReturnKeySearch;
        _searchBar.lgDelegate = self;
        _searchBar.tintColor= [UIColor lightGrayColor];

        
    }
    return _searchBar;
}

- (UIButton *)searchBtn{
    if (!_searchBtn) {
        _searchBtn = [[UIButton alloc] init];
        [_searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
        _searchBtn.titleLabel.font = kSYSTEMFONT(15);
        [_searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_searchBtn addTarget:self action:@selector(searchBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchBtn;
}

- (UIView *)searchBgView{
    if (!_searchBgView) {
        _searchBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMain_Screen_Width-65, 30)];
        _searchBgView.backgroundColor = [UIColor clearColor];
        [_searchBgView addSubview:self.searchBar];
        [_searchBgView addSubview:self.searchBtn];
        _searchBar.frame = CGRectMake(0, 0, _searchBgView.frame.size.width - 40, 30);
        _searchBtn.frame = CGRectMake(_searchBar.frame.size.width + 5, 0, 35, 30);
        
    }
    return _searchBgView;
}


- (LGNNoteMainTableView *)tableView{
    if (!_tableView) {
        _tableView = [[LGNNoteMainTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.isNotoSearchVC = YES;
        [_tableView allocInitRefreshHeader:NO allocInitFooter:NO];
        _tableView.ownerController = self;
        _tableView.isSearchVC = YES;
        self.viewModel.isSearchOperation = YES;
        [_tableView lg_bindViewModel:self.viewModel];
        _tableView.requestStatus = LGBaseTableViewRequestStatusNoData;
    }
    return _tableView;
}

- (LGNViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[LGNViewModel alloc] init];
//        _viewModel.paramModel.SystemID = @"S21";
//        _viewModel.paramModel.SubjectID = @"";
//        _viewModel.paramModel.PageSize = 0;
//        _viewModel.paramModel.PageIndex = 0;
    }
    return _viewModel;
}


@end

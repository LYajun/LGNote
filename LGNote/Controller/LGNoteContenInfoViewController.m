//
//  LGNoteContenInfoViewController.m
//  NoteDemo
//
//  Created by abc on 2020/6/23.
//  Copyright © 2020 hend. All rights reserved.
//

#import "LGNoteContenInfoViewController.h"
#import "LGNNoteEditViewController.h"
#import "LGNViewModel.h"
#import "LGNoteConfigure.h"
#import "LGNNoteEditView.h"
#import "NOteDropDownMenuView.h"
#import "LGNSubjectModel.h"
#import "LGNTextBookListModel.h"

#define MaxWith (kMain_Screen_Width-40)  / 3

#define MaxWithTY (kMain_Screen_Width-40)  / 2

#define SingleWith 12
@interface LGNoteContenInfoViewController ()
/** 操作类 */
@property (nonatomic, strong) LGNViewModel *viewModel;
/** model类 */
@property (nonatomic, strong) LGNNoteModel *sourceModel;
@property (nonatomic, strong) LGNNoteEditView *contentView;
@property (nonatomic,strong) NSString * NotoContent;
@property (nonatomic,strong) NSString * NotoTitle;
@property (nonatomic,strong) NSString * IsKeyPoint;
@property (nonatomic,strong) NSString * SubjectName;

@property (nonatomic,strong) NSString * OldSystemID;
@property (nonatomic,strong) NSString * OldSubjectID;

@property (nonatomic, strong) NOteDropDownMenuView *dropDownMenuView;
@property (nonatomic,assign) CGFloat  dropDown1With;

/* CFDropDownMenuView */
@property (nonatomic, strong) NOteDropDownMenuView *dropDownMenuView2;
@property (nonatomic,assign) CGFloat  dropDown2With;

@property (nonatomic, strong) NOteDropDownMenuView *dropDownMenuView3;
@property (nonatomic,assign) CGFloat  dropDown3With;


@property (nonatomic,strong) NSString * SeletSubjectID;
@property (nonatomic,strong) NSString * SeletSubjectName;

//章节目录数组
@property (nonatomic, copy)   NSMutableArray *sectionArray;
@property (nonatomic,strong) NSString * sectionID;
@property (nonatomic,strong) NSString * sectionName;


//节点目录数组
@property (nonatomic, copy)   NSMutableArray *nodeArray;
@property (nonatomic, strong)   NSString *nodeID;
@property (nonatomic,strong) NSString * nodeName;

@end

@implementation LGNoteContenInfoViewController
- (void)dealloc{
    NSLog(@"销毁了%@",NSStringFromClass([self class]));
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"笔记内容";
    
    [self addRightNavigationBar];

    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)addRightNavigationBar{
    
 
    NSString * title = @"编辑";
  
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItem:)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
 
}
- (void)rightBarButtonItem:(UIBarButtonItem *)sender{
   
    LGNNoteEditViewController * vc = [[LGNNoteEditViewController alloc]init];
    
}
#pragma mark - lazy
- (LGNViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[LGNViewModel alloc] init];
        _viewModel.isAddNoteOperation = self.isNewNote;
        _viewModel.paramModel = self.paramModel;
        _viewModel.dataSourceModel = self.sourceModel;
        _viewModel.subjectArray = self.subjectArray;
    }
    return _viewModel;
}
- (LGNNoteEditView *)contentView{
    if (!_contentView) {
        NSInteger style = NoteEditViewHeaderStyleInfoContenTYJX;
         _contentView = [[LGNNoteEditView alloc] initWithFrame:CGRectZero headerViewStyle:style];
        _contentView.ownController = self;
        self.contentView.canEditing = self.isNewNote;
        [_contentView bindViewModelLook:self.viewModel];
        

     
    }
    return _contentView;
}

- (LGNNoteModel *)sourceModel{
    if (!_sourceModel) {
        _sourceModel = [[LGNNoteModel alloc] init];
        _sourceModel.SystemID = self.paramModel.SystemID;
        _sourceModel.SubjectID = self.paramModel.SubjectID;
        _sourceModel.SubjectName = self.paramModel.SubjectName;
        _sourceModel.UserID = self.paramModel.UserID;
        _sourceModel.UserName = self.paramModel.UserName;
        _sourceModel.ResourceName = self.paramModel.ResourceName;
        _sourceModel.ResourceID = self.paramModel.ResourceID;
        _sourceModel.SchoolID = self.paramModel.SchoolID;
        
        _sourceModel.MaterialIndex = self.paramModel.MaterialIndex;
        _sourceModel.UserName = self.paramModel.UserName;
        _sourceModel.SystemName = self.paramModel.SystemName;
        _sourceModel.MaterialID = self.paramModel.MaterialID;
        _sourceModel.MaterialName = self.paramModel.MaterialName;
        
    }
    return _sourceModel;
}

@end

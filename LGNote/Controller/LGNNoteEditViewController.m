//
//  NoteEditViewController.m
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "LGNNoteEditViewController.h"
#import "LGNViewModel.h"
#import "LGNoteConfigure.h"
#import "LGNNoteEditView.h"


@interface LGNNoteEditViewController ()
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
@end

@implementation LGNNoteEditViewController

- (void)dealloc{
    NSLog(@"销毁了%@",NSStringFromClass([self class]));
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self createSubViews];
    
    
    
    _NotoContent = self.sourceModel.NoteContent;
    _NotoTitle = self.sourceModel.NoteTitle;
    _IsKeyPoint = self.sourceModel.IsKeyPoint;
    
    
    _SubjectName = self.sourceModel.SubjectName;
    
    if (self.viewModel.isAddNoteOperation) {
        _IsKeyPoint = @"0";
        self.sourceModel.IsKeyPoint = @"0";
    }
    
    
    if(!self.viewModel.isAddNoteOperation && self.paramModel.SystemType ==SystemType_ASSISTANTER){
    
    [self.viewModel.getDetailNoteCommand execute:self.sourceModel];
    }
    
    if(!self.viewModel.isAddNoteOperation && self.paramModel.SystemType ==SystemType_YPT){
        
        [self.viewModel.getDetailNoteCommand execute:self.sourceModel];
    }
    
    if(!_isNewNote){
        
        //禁止编辑  //禁止选择重难点
        
        self.contentView.titleTextF.enabled = NO;
        [self.contentView.contentTextView setEditable:NO];
        self.contentView.canEditing = NO;
       // self.contentView.remarkBtn.enabled = NO;
        self.contentView.remarkBtn.userInteractionEnabled = NO;
        
        if([self.sourceModel.IsKeyPoint isEqualToString:@"0"]){
             self.contentView.remarkBtn.hidden = YES;
        }
        
       

        
        self.contentView.subjectBtn.enabled = NO;
    }else{
        
        self.contentView.canEditing = YES;
         [self.contentView.titleTextF becomeFirstResponder];
    }
    
}

- (void)commonInit{
    self.title = self.isNewNote ? @"新建笔记":@"查看笔记";
}

- (void)editNoteWithDataSource:(LGNNoteModel *)dataSource{
    self.sourceModel = dataSource;
    
    
    self.sourceModel.UserID = self.paramModel.UserID;
    //self.sourceModel.SystemID = self.paramModel.SystemID;
    self.sourceModel.UserName = self.paramModel.UserName;
    self.sourceModel.SchoolID = self.paramModel.SchoolID;
    
    
    
    
}

- (void)addRightNavigationBar{
    
 
    NSString * title = self.isNewNote ? @"完成":@"编辑";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItem:)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
 
}

- (void)addLeftNavigationBar{
    UIImage *image = [NSBundle lg_imagePathName:@"note_back"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(back:)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
}

- (void)createSubViews{
    [self addRightNavigationBar];
    [self addLeftNavigationBar];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}




#pragma mark - 导航栏右按钮触发事件

- (void)rightBarButtonItem:(UIBarButtonItem *)sender{
    
    if(!self.contentView.canEditing){
        
        self.title = @"编辑笔记";
    
     self.navigationItem.rightBarButtonItem.title=@"完成";
        self.contentView.titleTextF.enabled = YES;
        [self.contentView.contentTextView setEditable:YES];
        self.contentView.canEditing = YES;
       // self.contentView.remarkBtn.enabled = YES;
        self.contentView.remarkBtn.hidden = NO;
        
         self.contentView.remarkBtn.userInteractionEnabled = YES;
        if(self.paramModel.SystemType ==SystemType_ASSISTANTER ||self.paramModel.SystemType ==SystemType_YPT ){
        self.contentView.subjectBtn.enabled = YES;
        }
        
        [self.contentView.titleTextF becomeFirstResponder];

       
        return;
    }
    

    self.paramModel.OperateFlag = self.isNewNote ? 1:0;
    self.sourceModel.OperateFlag = self.isNewNote ? 1:0;
    
   
    
    [self operatedNote];
}


- (void)back:(UIBarButtonItem *)sender{


    NSLog(@"%@===%@",_NotoContent,self.sourceModel.NoteContent);

        if(!IsStrEmpty(_NotoContent) && ![_NotoContent isEqualToString:self.sourceModel.NoteContent] ) {
            
            [self exti];
        }else if (!IsStrEmpty(self.sourceModel.NoteContent) && ![_NotoContent isEqualToString:self.sourceModel.NoteContent] ){
            
            [self exti];
            
        }
        else if (!IsStrEmpty(self.sourceModel.NoteTitle) && ![_NotoTitle isEqualToString:self.sourceModel.NoteTitle]){

              [self exti];

        }
        else if (![_SubjectName isEqualToString:self.sourceModel.SubjectName]){

             [self exti];
        }
    
    
        else if (![_IsKeyPoint isEqualToString:self.sourceModel.IsKeyPoint]  ){
            
            [self exti];
        }
    
        else{
            
            if(!_isSearchNote){
                
             
                if (self.updateSubject) {
                    [self.updateSubject sendNext:@"update"];
                }
                
            }
            
        [[NSNotificationCenter defaultCenter] postNotificationName:@"destroyImageNoti" object:nil userInfo:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
    
            
        }
    
    
  
}

- (void)exti{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"保存当前笔记内容吗?" preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.paramModel.OperateFlag = self.isNewNote ? 1:0;
        self.sourceModel.OperateFlag = self.isNewNote ? 1:0;
        [self operatedNote];
        
    }];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"不保存" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (self.updateSubject ) {
            [self.updateSubject sendNext:@"update"];
    
        }
       
        
        
          [self.navigationController popViewControllerAnimated:YES];
       
    }];
    
    [alert addAction:action1];
    [alert addAction:action];
    
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}

- (void)operatedNote{
    
    NSString *noteTitle = [self.sourceModel.NoteTitle stringByReplacingOccurrencesOfString:@" " withString:@""];
    
      NSString *noteContent = [self.contentView.contentTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
     NSString *noteContent1 = [noteContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    

    
    if (IsStrEmpty(self.sourceModel.NoteTitle) || IsStrEmpty(noteTitle)) {
        [kMBAlert showRemindStatus:@"标题不能为空!"];
          [self.contentView.titleTextF becomeFirstResponder];
        
        return;
    }
    
    
    
    
    if (IsStrEmpty(self.sourceModel.NoteContent)) {
        [kMBAlert showRemindStatus:@"内容不能为空!"];
          [self.contentView.contentTextView becomeFirstResponder];
        return;
    }
    
 if(IsStrEmpty(noteContent)&&self.sourceModel.imageAllCont==0){
        [kMBAlert showRemindStatus:@"内容不能为空!"];
     
     [self.contentView.contentTextView becomeFirstResponder];

        return;
    }
    
 if(IsStrEmpty(noteContent1)&&self.sourceModel.imageAllCont==0){
        [kMBAlert showRemindStatus:@"内容不能为空!"];
       [self.contentView.contentTextView becomeFirstResponder];
        return;
    }
    
    if([self.sourceModel.SystemName isEqualToString:@"课后作业"]){
        
        self.sourceModel.ResourceName = self.paramModel.MaterialName;
        self.viewModel.dataSourceModel.ResourceName =self.paramModel.MaterialName;
    }
    

    
    [kMBAlert showIndeterminateWithStatus:@"正在上传..."];
    
    
    
  


   [self.viewModel.operateCommand execute:[self.sourceModel mj_keyValues]];
    
    
    
     // [self.viewModel.operateCommand execute:self.sourceModel];
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    @weakify(self);
    [self.viewModel.operateSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        
        
        if (x && self.updateSubject) {
            [self.navigationController popViewControllerAnimated:YES];
            
            NSLog(@"%@",_searchContent);
            
            
            if(_isSearchNote && !IsStrEmpty(_searchContent)){
                return ;
            }
            
            [self.updateSubject sendNext:@"成功"];
        }
    }];
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
        NSInteger style = NoteEditViewHeaderStyleNoHidden;
        if ( self.paramModel.SystemType == SystemType_CP ) {
            style = NoteEditViewHeaderStyleHideSource;
            
        } else {
            if(self.paramModel.SystemType ==SystemType_ASSISTANTER &&_isNewNote){
                //小助手新建笔记需要隐藏来源选项
               style = NoteEditViewHeaderStyleHideSource;
                
            }
            else if (self.paramModel.SystemType ==SystemType_YPT &&_isNewNote){
                //云平台新建笔记需要隐藏来源选项

                style = NoteEditViewHeaderStyleHideSource;
            }else if (self.paramModel.SystemType ==SystemType_ASSISTANTER){
                
                style = NoteEditViewHeaderStyleNoHiddenCanTouch;
            }else if (self.paramModel.SystemType ==SystemType_YPT){
                
                style = NoteEditViewHeaderStyleNoHiddenCanTouch;
            }else{
                style = NoteEditViewHeaderStyleNoHidden;
                
            }
           
        }
        _contentView = [[LGNNoteEditView alloc] initWithFrame:CGRectZero headerViewStyle:style];
        _contentView.ownController = self;
        self.contentView.canEditing = self.isNewNote;
        [_contentView bindViewModel:self.viewModel];
        

     
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

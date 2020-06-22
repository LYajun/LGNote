
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
#import "NOteDropDownMenuView.h"
#import "LGNSubjectModel.h"
#import "LGNTextBookListModel.h"

#define MaxWith (kMain_Screen_Width-40)  / 3

#define MaxWithTY (kMain_Screen_Width-40)  / 2

#define SingleWith 12

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
        
        self.sourceModel.ResourceName = self.viewModel.paramModel.ResourceName;
        self.sourceModel.ResourceID = self.viewModel.paramModel.ResourceID;
        self.sourceModel.MaterialName = self.viewModel.paramModel.MaterialName;
             self.sourceModel.MaterialID = self.viewModel.paramModel.MaterialID;
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
    
    @weakify(self);

    [self.viewModel.getTextbookListRateSubject subscribeNext:^(id  _Nullable x) {
              @strongify(self);
              
              
              self.sectionArray = x;
             
        
        if(IsArrEmpty( self.sectionArray)){
            
            if(self.paramModel.MainTY ==1){
                
                NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
                                  LGNTextBookListModel *subjectModel =[[LGNTextBookListModel alloc]init];
                                  subjectModel.UnionName = self.viewModel.paramModel.ResourceName;
                                  subjectModel.UnionId = self.viewModel.paramModel.ResourceID;

                                  [subArr addObject:subjectModel];
                                
                                  self.sectionArray =subArr;
            }
            
          
            
        }
//        设置UI
        
        if(self.paramModel.MainTY ==1){
            //学习推荐的
            [self setZJUZTY];
            
        }else{
           [self setZJUZ];
            
            
        }
           
      
          }];
    
     [self.viewModel.getNodeInfoRateSubject subscribeNext:^(id  _Nullable x) {
                  @strongify(self);
                  
                  
                  self.nodeArray = x;
                 
            
            if(IsArrEmpty( self.nodeArray)){
                
                if(self.paramModel.MainTY ==1){
                    NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
                                           LGNTextBookListModel *subjectModel =[[LGNTextBookListModel alloc]init];
                                           subjectModel.UnionName = self.viewModel.paramModel.MaterialName;
                                           subjectModel.UnionId =self.viewModel.paramModel.MaterialID;

                                           [subArr addObject:subjectModel];
                                         
                                            self.nodeArray =subArr;
                }
                
               
                
            }
    //        设置UI
            
                
         if(self.paramModel.MainTY ==1){
                   //学习推荐的
                   [self setJDUITY];
                   
               }else{
                 [self setJDUI];
               }
          
              }];


            [self.viewModel.getCourseClassInfoRateSubject subscribeNext:^(id  _Nullable x) {
                      @strongify(self);
                      
                      
                      self.viewModel.paramModel.TeacherID = x;
                     
                   [self  getZJData];
    
              
                  }];

}

- (void)commonInit{
    self.title = self.isNewNote ? @"新建笔记":@"查看笔记";
}

- (void)editNoteWithDataSource:(LGNNoteModel *)dataSource{
    self.sourceModel = dataSource;
    
    NSLog(@"%@",dataSource.ResourceName);
    
    
    self.sourceModel.UserID = self.paramModel.UserID;
    //self.sourceModel.SystemID = self.paramModel.SystemID;
    self.sourceModel.UserName = self.paramModel.UserName;
    self.sourceModel.SchoolID = self.paramModel.SchoolID;
    
    

    if(self.paramModel.SystemType ==SystemType_TYJX){
        
        
    }
    
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

- (void)setTysubjectArray:(NSArray *)tysubjectArray {
    
    
    _tysubjectArray = tysubjectArray;
}


- (void)createSubViews{
    [self addRightNavigationBar];
    [self addLeftNavigationBar];
    [self.view addSubview:self.contentView];
    
if(self.paramModel.SystemType ==SystemType_TYJX){
    
    if(self.paramModel.MainTY ==1){
        
        //获取章节/节点
        
        NSLog(@"%@==%@==%@",self.paramModel.SubjectID,self.paramModel.ResourceID,self.paramModel.MaterialID);
        
        //获取章节数据
        [self  getZJData];
 
    }else{
        
      
        
        NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
        
        NSString * titleName;
                
        self.subjectArray = self.tysubjectArray;
        
        
        
  
        
        for(int i=0;i<self.subjectArray.count;i++){
            LGNSubjectModel *subjectModel = self.subjectArray[i];
            
            [subArr addObject:subjectModel.SubjectName];
            if (self.isNewNote) {
                if([subjectModel.SubjectID isEqualToString:self.viewModel.paramModel.SubjectID]){
                               titleName =subjectModel.SubjectName;
                               self.SeletSubjectID =subjectModel.SubjectID;
                    self.SeletSubjectName = subjectModel.SubjectName;
                           }
            }else{
                if([subjectModel.SubjectID isEqualToString:self.sourceModel.SubjectID]){
                               titleName =subjectModel.SubjectName;
                               self.SeletSubjectID =subjectModel.SubjectID;
                    self.SeletSubjectName = subjectModel.SubjectName;

                           }
            }
            
           
        }
        
        
  
        if(IsStrEmpty(titleName)){
             LGNSubjectModel *subjectModel = self.subjectArray[0];
            titleName =subjectModel.SubjectName;
            self.SeletSubjectID =subjectModel.SubjectID;
            self.SeletSubjectName = subjectModel.SubjectName;

        }
          
        
            CGFloat  with = SingleWith *titleName.length+20;
                 if(with > MaxWith){
                     with =MaxWith;
                 }
       self.dropDown1With = with;
        //设置学科
        NOteDropDownMenuView *dropDownMenuView = [[NOteDropDownMenuView alloc] initWithFrame:CGRectMake(20, 0, with, 45)];

                    dropDownMenuView.dataSourceArr = @[

                                                         subArr,

                                                        ].mutableCopy;

                    dropDownMenuView.defaulTitleArray = [NSArray arrayWithObjects:titleName, nil];


           // 下拉列表 起始y
                  dropDownMenuView.startY = CGRectGetMaxY(dropDownMenuView.frame);
        @weakify(self);

        dropDownMenuView.chooseConditionBlock = ^(NSString *currentTitle, NSArray *currentTitleArray){
        @strongify(self);

//                通过选择学科  去获取章节
                  for(int i=0;i<self.subjectArray.count;i++){
                             LGNSubjectModel *subjectModel = self.subjectArray[i];
                             
                      if([subjectModel.SubjectName isEqualToString:currentTitle]){
                          self.SeletSubjectID =subjectModel.SubjectID;
                          self.SeletSubjectName = subjectModel.SubjectName;

                         
                      }
                         }
                  
            CGFloat  with = SingleWith *currentTitle.length+20;
                  if(with > MaxWith){
                      with =MaxWith;
                  }
            
            self.dropDown1With = with;
                 self.dropDownMenuView.frame =CGRectMake(20, 0, with, 45);
            for(int i=0;i<self.subjectArray.count;i++){
                    LGNSubjectModel *subjectModel = self.subjectArray[i];
                                                                       
                    if([subjectModel.SubjectName isEqualToString:currentTitle]){
                          
                        if([currentTitle isEqualToString:@"全部"]){
                            
                            self.SeletSubjectID = @"";
                             self.viewModel.paramModel.SubjectID =@"";
                            self.SeletSubjectName = @"";

                        }else{
                            
                            for(int i=0;i<self.subjectArray.count;i++){
                                                  LGNSubjectModel *subjectModel = self.subjectArray[i];
                                                      
                                           if([subjectModel.SubjectName isEqualToString:currentTitle]){
                                               
                                               self.SeletSubjectID  = subjectModel.SubjectID;
                                                self.SeletSubjectName = subjectModel.SubjectName;

                                           }
                                             
                                                  }
                            
                        }
                        
                     
                        
                    }
                    }
            
            
            
            if([currentTitle isEqualToString:@"全部"]){
                self.sectionID =@"";
                self.nodeID =@"";
                self.SeletSubjectID =@"";
                self.SeletSubjectName =@"";

                [self.dropDownMenuView2 removeFromSuperview];
                [self.dropDownMenuView3 removeFromSuperview];
            }else{
                
                
                //先获取筛选教师ID
                           
            [self  getCourseClassInfo];
                //获取章节数据
//                [self  getZJData];
            }
            
               
                  
                  

                    };
               [self.view addSubview:self.dropDownMenuView =dropDownMenuView];
      
        if(![self.SeletSubjectID isEqualToString:@""] &&![self.SeletSubjectID isEqualToString:@"All"]){
            
            //先获取筛选教师ID
                                     
        [self  getCourseClassInfo];
//              [self  getZJData];
        }
//          [self  getZJData];
        
    }
    
   
    
    
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(50);
            make.left.right.bottom.equalTo(self.view);

           }];
        
    }else{
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.edges.equalTo(self.view);
           }];
    }
   
}

//获取教学班信息 筛选教师ID  然后通过ID获取教材列表

- (void)getCourseClassInfo{
    
         NSDictionary *paramse =@{
            @"appid":@"300",
            @"userID":self.viewModel.paramModel.UserID,
            @"access_token":self.viewModel.paramModel.Token_md5,
    
                                                  };
    
    self.viewModel.paramModel.SubjectID = self.SeletSubjectID;
    self.viewModel.paramModel.SubjectName = self.SeletSubjectName;
    [self.viewModel.getCourseClassInfoRateCommand execute:paramse];
    
}

//设置通用教学的数据
- (void)setJDUITY{
    
    [self.dropDownMenuView2 removeFromSuperview];
    
    NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
    NSString * titleName;
          for(int i=0;i<self.nodeArray.count;i++){
              LGNTextBookListModel *sectionModel = self.nodeArray[i];
              
              [subArr addObject:sectionModel.UnionName];
              if([sectionModel.UnionId isEqualToString:self.sourceModel.MaterialID]){
                  
                  titleName =sectionModel.UnionName;
                  self.nodeID =sectionModel.UnionId;
                self.nodeName =sectionModel.UnionName;
              }
          }
      
    if(IsStrEmpty(titleName)){
         LGNTextBookListModel *sectionModel = self.nodeArray[0];
        titleName = sectionModel.UnionName;
        self.nodeID =sectionModel.UnionId;
               self.nodeName =sectionModel.UnionName;
    }
    
    CGFloat  with = SingleWith *titleName.length+30;
              if(with > MaxWithTY){
                  with =MaxWithTY;
              }
        
    self.dropDown2With = with;

    NOteDropDownMenuView *dropDownMenuView2 = [[NOteDropDownMenuView alloc] initWithFrame:CGRectMake(20+self.dropDown1With+10, 0, with, 45)];

    dropDownMenuView2.withM =with-20;
                      dropDownMenuView2.dataSourceArr = @[

                                                           subArr,

                                                          ].mutableCopy;

                      dropDownMenuView2.defaulTitleArray = [NSArray arrayWithObjects:titleName, nil];
                // 下拉列表 起始y
                    dropDownMenuView2.startY = CGRectGetMaxY(_dropDownMenuView.frame);
                dropDownMenuView2.chooseConditionBlock = ^(NSString *currentTitle, NSArray *currentTitleArray){
                    
                    CGFloat  with = SingleWith *currentTitle.length+30;
                                 if(with > MaxWithTY){
                                     with =MaxWithTY;
                                 }
                          self.dropDownMenuView2.withM =with-20;

                       self.dropDown2With = with;

                    self.dropDownMenuView2.frame =CGRectMake(20+self.dropDown1With+10, 0, with, 45);
   //                 通过章节  去获取节点详情
                                   for(int i=0;i<self.nodeArray.count;i++){
                                              LGNTextBookListModel *subjectModel = self.nodeArray[i];
                                              
                                       if([subjectModel.UnionName isEqualToString:currentTitle]){
                                           self.nodeID =subjectModel.UnionId;
                                           self.nodeName =subjectModel.UnionName;
                                          
                                       }
                                          }
                                   
                                  

                      };
   
             [self.view addSubview:self.dropDownMenuView2 =dropDownMenuView2];
    if(IsArrEmpty(self.nodeArray)){
                [self.dropDownMenuView2 removeFromSuperview];
             self.nodeID = @"";
               
           }
       
}

//设置节点数据
- (void)setJDUI{
     [self.dropDownMenuView3 removeFromSuperview];
    
    if(IsArrEmpty(self.nodeArray)){
            self.nodeID =@"";
          self.nodeName =@"";
                
           return;
        }
    
    NSString * titleName;
    NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
          for(int i=0;i<self.nodeArray.count;i++){
              LGNTextBookListModel *sectionModel = self.nodeArray[i];
              
              [subArr addObject:sectionModel.UnionName];
              
              if(self.isNewNote){
                  if([sectionModel.UnionId isEqualToString:self.viewModel.paramModel.MaterialID]){
                                   titleName =sectionModel.UnionName;
                                   self.nodeID =sectionModel.UnionId;
                                   self.nodeName =sectionModel.UnionName;
                               }
              }else{
                  
                  if([sectionModel.UnionId isEqualToString:self.sourceModel.MaterialID]){
                                   titleName =sectionModel.UnionName;
                                   self.nodeID =sectionModel.UnionId;
                                   self.nodeName =sectionModel.UnionName;
                               }
              }
              
             
          }
    
    
    if(IsStrEmpty(titleName)){
        //默认选中第一个
            LGNTextBookListModel *sectionModel = self.nodeArray[0];
           self.nodeID =sectionModel.UnionId;
           self.nodeName = sectionModel.UnionName;
        titleName =sectionModel.UnionName;
        
    }
        CGFloat  with = SingleWith *titleName.length+30;
               if(with > MaxWith){
                   with =MaxWith;
               }
        self.dropDown3With = with;
     NOteDropDownMenuView *dropDownMenuView3 = [[NOteDropDownMenuView alloc] initWithFrame:CGRectMake(20+10+10+self.dropDown1With+self.dropDown2With, 0, with, 45)];

                       dropDownMenuView3.dataSourceArr = @[

                                                            subArr,

                                                           ].mutableCopy;

                       dropDownMenuView3.defaulTitleArray = [NSArray arrayWithObjects:titleName, nil];
                 // 下拉列表 起始y
                     dropDownMenuView3.startY = CGRectGetMaxY(_dropDownMenuView.frame);
                 dropDownMenuView3.chooseConditionBlock = ^(NSString *currentTitle, NSArray *currentTitleArray){
                     CGFloat  with = SingleWith *currentTitle.length+30;
                                                   if(with > MaxWith){
                                                       with =MaxWith;
                                                   }
                                                   self.dropDown3With = with;
                                    self.dropDownMenuView3.frame =CGRectMake(20+10+10+self.dropDown1With+self.dropDown2With, 0, with, 45);
                                   
    //                 通过章节  去获取节点详情
                                    for(int i=0;i<self.nodeArray.count;i++){
                                               LGNTextBookListModel *subjectModel = self.nodeArray[i];
                                               
                                        if([subjectModel.UnionName isEqualToString:currentTitle]){
                                            self.nodeID =subjectModel.UnionId;
                                            self.nodeName = subjectModel.UnionName;
                                           
                                        }
                                           }
                                    
                                   

                       };
              [self.view addSubview:self.dropDownMenuView3 =dropDownMenuView3];
}

//设置章节数据 - 通用教学
- (void)setZJUZTY{
    
    [self.dropDownMenuView removeFromSuperview];
     [self.dropDownMenuView2 removeFromSuperview];
    
    NSLog(@"==%@==",self.sourceModel.ResourceName);
    
    
    NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
    NSString * titleName;
        for(int i=0;i<self.sectionArray.count;i++){
            LGNTextBookListModel *sectionModel = self.sectionArray[i];
            
            [subArr addObject:sectionModel.UnionName];
            if([sectionModel.UnionId isEqualToString:self.sourceModel.ResourceID]){
//                aaaa
                titleName =sectionModel.UnionName;
                self.sectionID =sectionModel.UnionId;
                self.sectionName = sectionModel.UnionName;
            }
        }
    
    if(IsStrEmpty(titleName)){
        
        titleName =self.sourceModel.ResourceName;
        self.sectionID =self.sourceModel.ResourceID;
        self.sectionName =self.sourceModel.ResourceName;
    }
    
    CGFloat  with = SingleWith *titleName.length+30;
              if(with > MaxWithTY){
                  with =MaxWithTY;
              }

    self.dropDown1With = with;
    
    NOteDropDownMenuView *dropDownMenuView = [[NOteDropDownMenuView alloc] initWithFrame:CGRectMake(20, 0, with, 45)];
    dropDownMenuView.withM = with-20;
                        dropDownMenuView.dataSourceArr = @[

                                                             subArr,

                                                            ].mutableCopy;
    


                        dropDownMenuView.defaulTitleArray = [NSArray arrayWithObjects:titleName, nil];


               // 下拉列表 起始y
                      dropDownMenuView.startY = CGRectGetMaxY(dropDownMenuView.frame);
            @weakify(self);

            dropDownMenuView.chooseConditionBlock = ^(NSString *currentTitle, NSArray *currentTitleArray){
            @strongify(self);
                
                CGFloat  with = SingleWith *currentTitle.length+30;
                             if(with > MaxWithTY){
                                 with =MaxWithTY;
                             }

                   self.dropDown1With = with;
                
                self.dropDownMenuView.withM = with-20;
                
                self.dropDownMenuView.frame =CGRectMake(20, 0, with, 45);

                //                 通过章节  去获取节点详情
    for(int i=0;i<self.sectionArray.count;i++){
        LGNTextBookListModel *subjectModel = self.sectionArray[i];
                                                           
        if([subjectModel.UnionName isEqualToString:currentTitle]){
        self.sectionID =subjectModel.UnionId;
            self.sectionName =subjectModel.UnionName;
        }
        }
                                                
                //获取章节数据
                [self  getJDData];

                        };
    [self.view addSubview:self.dropDownMenuView =dropDownMenuView];
    
    
     [self  getJDData];
    
}
//设置章节数据
- (void)setZJUZ{
    
    [self.dropDownMenuView2 removeFromSuperview];
    [self.dropDownMenuView3 removeFromSuperview];
    if(IsArrEmpty(self.sectionArray)){
            
    //        数据为空
            self.sectionID =@"";
            self.sectionName =@"";
        self.nodeName =@"";
        self.nodeID =@"";
            return;
        }
    
    NSString * titleName;
    NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
        for(int i=0;i<self.sectionArray.count;i++){
            LGNTextBookListModel *sectionModel = self.sectionArray[i];
            
            [subArr addObject:sectionModel.UnionName];
            
            if(self.isNewNote){
                if([sectionModel.UnionId isEqualToString:self.viewModel.paramModel.ResourceID]){
                               titleName =sectionModel.UnionName;
                               self.sectionID =self.viewModel.paramModel.ResourceID;
                               self.sectionName =sectionModel.UnionName;
                           }
            }else{
                
                if([sectionModel.UnionId isEqualToString:self.sourceModel.ResourceID]){
                               titleName =sectionModel.UnionName;
                               self.sectionID =self.sourceModel.ResourceID;
                               self.sectionName =sectionModel.UnionName;
                           }
            }
            
           
        }
    
    if(IsStrEmpty(titleName)){
        LGNTextBookListModel *sectionModel = self.sectionArray[0];
             self.sectionID =sectionModel.UnionId;
           self.sectionName = sectionModel.UnionName;
        titleName =sectionModel.UnionName;
    }

  
          CGFloat  with = SingleWith *titleName.length+30;
                 if(with > MaxWith){
                     with =MaxWith;
                 }
          self.dropDown2With = with;
    
    NOteDropDownMenuView *dropDownMenuView2 = [[NOteDropDownMenuView alloc] initWithFrame:CGRectMake(30+self.dropDown1With, 0, with, 45)];

                   dropDownMenuView2.dataSourceArr = @[

                                                        subArr,

                                                       ].mutableCopy;

                   dropDownMenuView2.defaulTitleArray = [NSArray arrayWithObjects:titleName, nil];
             // 下拉列表 起始y
            dropDownMenuView2.startY = CGRectGetMaxY(_dropDownMenuView.frame);
             dropDownMenuView2.chooseConditionBlock = ^(NSString *currentTitle, NSArray *currentTitleArray){

                 CGFloat  with = SingleWith *currentTitle.length+30;
                                                if(with > MaxWith){
                                                    with =MaxWith;
                                                }
                                self.dropDown2With = with;
                                 self.dropDownMenuView2.frame =CGRectMake(30+self.dropDown1With, 0, with, 45);
                 
                 
//                 通过章节  去获取节点详情
                                for(int i=0;i<self.sectionArray.count;i++){
                                           LGNTextBookListModel *subjectModel = self.sectionArray[i];
                                           
                                    if([subjectModel.UnionName isEqualToString:currentTitle]){
                                        self.sectionID =subjectModel.UnionId;
                                        self.sectionName =subjectModel.UnionName;
                                       
                                    }
                                       }
                                
                                //获取章节数据
                                [self  getJDData];

                   };
          [self.view addSubview:self.dropDownMenuView2 =dropDownMenuView2];
    //获取章节数据
   [self  getJDData];
}

//获取章节  显示数据
- (void)getZJData{
    
    NSDictionary *paramse ;
      if(self.paramModel.MainTY ==1){
     
          NSInteger length =self.viewModel.paramModel.TermID.length-1;
             NSString * termId = [self.viewModel.paramModel.TermID substringFromIndex:length];
             
              paramse =@{
                 @"subjectId":self.viewModel.paramModel.SubjectID,
                 @"gradeId":self.viewModel.paramModel.GradeID,
                 @"termId":termId,
                 @"teacherId":self.viewModel.paramModel.TeacherID,
            

                                                       };
          
    }else{
       
        
        NSInteger length =self.viewModel.paramModel.TermID.length-1;
                   NSString * termId = [self.viewModel.paramModel.TermID substringFromIndex:length];
                   
                    paramse =@{
                       @"subjectId":Note_HandleParams(self.SeletSubjectID),
                       @"gradeId":Note_HandleParams(self.viewModel.paramModel.GradeID),
                       @"termId":Note_HandleParams(termId),
                       @"teacherId":Note_HandleParams(self.viewModel.paramModel.TeacherID),
                  

                                                             };
                
    }
    
     [self.viewModel.getTextbookListRateCommand execute:paramse];

   
    
}

//获取节点 数据
- (void)getJDData{
    
   self.nodeArray =[NSMutableArray arrayWithCapacity:10];
    
      for(int i=0;i<self.sectionArray.count;i++){
          
          LGNTextBookListModel *sectionModel = self.sectionArray[i];
          
          if([sectionModel.UnionId isEqualToString:self.sectionID]){
              self.nodeArray =sectionModel.chapters;
              
          }

          
      }
   
    if(self.paramModel.MainTY ==1){
                          //学习推荐的
                    [self setJDUITY];
                          
                      }else{
                        [self setJDUI];
                      }
    
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
    
    if(self.paramModel.SystemType ==SystemType_TYJX){
        
        if(!IsStrEmpty(self.sectionID)){
            self.sourceModel.ResourceID = self.sectionID;
            self.sourceModel.ResourceName = self.sectionName;
            self.paramModel.ResourceID = self.sectionID;
            self.paramModel.ResourceName = self.sectionName;

        }
        
        if(!IsStrEmpty(self.nodeID)){
       self.sourceModel.MaterialID = self.nodeID;
        self.sourceModel.MaterialName = self.nodeName;
        self.paramModel.MaterialID = self.nodeID;
        self.paramModel.MaterialName = self.nodeName;
        }
        if(self.paramModel.MainTY ==0){
            
            NSLog(@"%@===%@==%@==%@==%@",self.sectionID,self.sectionName,self.nodeName,self.nodeID,self.SeletSubjectID);
            if( IsStrEmpty(self.sectionID)){
                self.sectionID =@"";
                 self.sectionName =@"";
            }
            if( IsStrEmpty(self.nodeID)){
                self.nodeID =@"";
                self.nodeName =@"";
            }
            self.sourceModel.SystemID = @"300";
            self.sourceModel.SubjectID = self.SeletSubjectID;
            self.sourceModel.SubjectName = self.SeletSubjectName;
          self.sourceModel.MaterialID = self.nodeID;
         self.sourceModel.MaterialName = self.nodeName;
        self.paramModel.MaterialID = self.nodeID;
        self.paramModel.MaterialName = self.nodeName;
            
            self.sourceModel.ResourceID = self.sectionID;
            self.sourceModel.ResourceName = self.sectionName;
            self.paramModel.ResourceID = self.sectionID;
            self.paramModel.ResourceName = self.sectionName;

        }

    }

    NSLog(@"%@---%@",self.sourceModel.ResourceName,self.nodeID);


    
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
        if ( self.paramModel.SystemType == SystemType_TYJX ) {
       style = NoteEditViewHeaderStyleTYJX;

        
        }
        
       else if ( self.paramModel.SystemType == SystemType_CP ) {
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


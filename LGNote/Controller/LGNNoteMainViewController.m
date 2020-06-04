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
#import "NoteDragView.h"
#import "NOteDropDownMenuView.h"
#import "LGNTextBookListModel.h"
#import "LGNSubjectModel.h"

#define MaxWith (kMain_Screen_Width-105)  / 3
#define SingleWith 12

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


//=======通用教学的适配=======
//重点笔记筛选按钮
@property (nonatomic, strong, readwrite) UIButton *remarkBtn;
//添加笔记
@property (nonatomic,strong) NoteDragView * dragView;

@property (nonatomic, strong) NOteDropDownMenuView *dropDownMenuView;
@property (nonatomic,assign) CGFloat  dropDown1With;

/* CFDropDownMenuView */
@property (nonatomic, strong) NOteDropDownMenuView *dropDownMenuView2;
@property (nonatomic,assign) CGFloat  dropDown2With;

@property (nonatomic, strong) NOteDropDownMenuView *dropDownMenuView3;
@property (nonatomic,assign) CGFloat  dropDown3With;

@property (nonatomic, strong) NSMutableArray *subjectArray;


@property (nonatomic,strong) NSString * SeletSubjectID;
//章节目录数组
@property (nonatomic, copy)   NSMutableArray *sectionArray;
@property (nonatomic,strong) NSString * sectionID;
@property (nonatomic,strong) NSString * sectionName;


//节点目录数组
@property (nonatomic, copy)   NSMutableArray *nodeArray;
@property (nonatomic, strong)   NSString *nodeID;
@property (nonatomic,strong) NSString * nodeName;
//设置章节是否刷新数据
@property (nonatomic,assign) BOOL  isRefreshData;
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
- (void)dealloc{
    [self.dragView removeFromSuperview];

}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.dragView.hidden = NO;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.dragView.hidden=YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
 
  
    [self lg_commonInit];
    [self creatSubViews];
    
    if(self.systemType == SystemUsedTypeTYJX){
      self.title = @"学习笔记";
     //获取学科
        [self lg_bindSubjectData];

      }else{
      self.title = @"我的笔记";
      [self lg_bindData];
      }
    
 
    
     @weakify(self);

        [self.viewModel.getTextbookListRateSubject subscribeNext:^(id  _Nullable x) {
                  @strongify(self);
                  
                  
                  self.sectionArray = x;
                 
            
            if(IsArrEmpty( self.sectionArray)){
                NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
                                         LGNTextBookListModel *subjectModel =[[LGNTextBookListModel alloc]init];
                                         subjectModel.BookName = self.viewModel.paramModel.ResourceName;
                                         subjectModel.BookId = self.viewModel.paramModel.ResourceID;

                                         [subArr addObject:subjectModel];
                                  
               
                        self.sectionArray =subArr;
                
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
                    
                    NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
                            LGNTextBookListModel *subjectModel =[[LGNTextBookListModel alloc]init];
                            subjectModel.UnionName = self.viewModel.paramModel.MaterialName;
                            subjectModel.UnionId =self.viewModel.paramModel.MaterialID;

                            [subArr addObject:subjectModel];
                             self.nodeArray =subArr;
                    
                }
        //        设置UI
                
                    
             if(self.paramModel.MainTY ==1){
                       //学习推荐的
                       [self setJDUITY];
                       
                   }else{
                     [self setJDUI];
                   }
              
                  }];
}


- (void)lg_commonInit{
    [self addRightNavigationBar];
    [self addLeftNavigationBar];
}

- (void)creatSubViews{
    
    if(self.systemType == SystemUsedTypeTYJX){
        
        
        [self TYSETUI];
        
    }
    
    else if(self.systemType == SystemUsedTypeNew){
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
//通用教学的适配
- (void)TYSETUI{

    
    self.dragView = [[NoteDragView alloc] initWithFrame:CGRectMake(kMain_Screen_Width-44-15, kMain_Screen_Height-180-NoteSTATUS_HEIGHT, 44, 44)];

    self.dragView.layer.cornerRadius = 22;
       self.dragView.isKeepBounds = YES;

     self.dragView.imageView.image = [NSBundle lg_imagePathName:@"Note_AndNote"];
     self.dragView.freeRect = CGRectMake(10, NoteNAVIGATION_HEIGHT+44, kMain_Screen_Width-20, kMain_Screen_Height-220-NoteSTATUS_HEIGHT);

    @weakify(self);

     self.dragView.clickDragViewBlock = ^(NoteDragView *dragView){
          @strongify(self);

        [self rightNavigationBar];
     };


        UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;

        [currentWindow addSubview:self.dragView];

       

        [self.view addSubview:self.tableView];
//        [self.view addSubview:self.remarkBtn];
//        [self.remarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//              make.top.equalTo(self.view).offset(10);
//                make.right.equalTo(self.view).offset(-10);
//
//                make.width.mas_equalTo(85);
//                make.height.mas_equalTo(30);
//                    }];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self.view);
                make.top.equalTo(self.view).offset(45);
            }];

}



- (void)setupSubViewsContraints{

    
   
}


- (void)addRightNavigationBar{
    
    if(self.systemType == SystemUsedTypeTYJX){
        
        UIImage *image = [NSBundle lg_imagePathName:@"note_searchbtn"];
          self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(enterSearchEvent)];
          [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
        
    }else{
        
        UIImage *image = [NSBundle lg_imagePathName:@"note_add"];
          self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(rightNavigationBar)];
          [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    }
    
    
  
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
    
    NSLog(@"%@",self.viewModel.paramModel.ResourceID);
    
    
}

- (void)lg_bindSubjectData{
    
    self.viewModel.paramModel = self.paramModel;

//     [self  setuTopView];
//
//    return;
//
    NSDictionary *paramse =@{
    @"UserID":self.paramModel.UserID,
    @"UserType":@(self.paramModel.UserType),
   @"SystemID":@"All",
 @"SchoolID":self.paramModel.SchoolID,
@"Token":self.paramModel.Token,
};
//
    [self.viewModel.getAllSubjectCommand execute:paramse];

   @weakify(self);
    
    NSLog(@"==%@==",self.viewModel.subjectArray);

   [self.viewModel.getAllSubjectSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);


        self.subjectArray = x;
       
       if(IsArrEmpty(self.subjectArray))
       {
            NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
           LGNSubjectModel*subjectModel =[[LGNSubjectModel alloc]init];
           subjectModel.SubjectID =@"All";
           subjectModel.SubjectName =@"全部";
           [subArr addObject:subjectModel];
           
           LGNSubjectModel*subjectModel1 =[[LGNSubjectModel alloc]init];
                    subjectModel1.SubjectID =@"S2-English";
                    subjectModel1.SubjectName =@"英语";
                    [subArr addObject:subjectModel1];

           self.subjectArray = subArr;
       }
       
       self.viewModel.paramModel.TYSubjectArray =self.subjectArray;

       
       
      //设置UI

       [self  setuTopView];


        //[self lg_bindData];
    }];
    
    
}

- (void)setuTopView{

        if( self.viewModel.paramModel.MainTY ==1){
            
            //通用版教学
            //获取章节数据
            [self  getZJData];
    
             
        }else{
            //平台首页集成
            //获取学科列表  当选择某学科时 获取章节
    NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
        NSString * titleName;
        for( int y = 0; y < self.subjectArray.count; ++y ) {
        LGNSubjectModel*subjectModel =self.subjectArray[y];
            
            [subArr addObject:subjectModel.SubjectName];

            if([subjectModel.SubjectID isEqualToString:self.viewModel.paramModel.SubjectID]){
                
                        titleName =subjectModel.SubjectName;
                }
        }
   
            
             [self setupSubjectUI];
            
              self.viewModel.paramModel.ResourceID =@"";
            self.viewModel.paramModel.MaterialID =@"";
             self.viewModel.paramModel.SubjectID =@"";
            //请求数据
          [self lg_bindData];
        }

    
}
#pragma mark -通用版教学(首页)
- (void)setupSubjectUI{
    
     NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
           for(int i=0;i<self.subjectArray.count;i++){
               LGNSubjectModel *subjectModel = self.subjectArray[i];
               
               [subArr addObject:subjectModel.SubjectName];
               
           }
    NSString * titleName =subArr[0];
    CGFloat  with = SingleWith *titleName.length+20;
         if(with > MaxWith){
             with =MaxWith;
         }
    self.SeletSubjectID = @"";
    self.viewModel.paramModel.SubjectID =@"";
    self.dropDown1With = with;
    NOteDropDownMenuView *dropDownMenuView = [[NOteDropDownMenuView alloc] initWithFrame:CGRectMake(20, 0, with, 45)];
            
            dropDownMenuView.dataSourceArr = @[
                                               
                                                 subArr,
                                                
                                                ].mutableCopy;
            
            dropDownMenuView.defaulTitleArray = [NSArray arrayWithObjects:titleName, nil];
      // 下拉列表 起始y
          dropDownMenuView.startY = CGRectGetMaxY(_dropDownMenuView.frame);
    @weakify(self);

    dropDownMenuView.chooseConditionBlock = ^(NSString *currentTitle, NSArray *currentTitleArray){
          @strongify(self);
        
      

          for(int i=0;i<self.subjectArray.count;i++){
          LGNSubjectModel *subjectModel = self.subjectArray[i];
                                                             
          if([subjectModel.SubjectName isEqualToString:currentTitle]){
                
              if([currentTitle isEqualToString:@"全部"]){
                  
                  self.SeletSubjectID = @"";
                   self.viewModel.paramModel.SubjectID =@"";
              }else{
                  
                  for(int i=0;i<self.subjectArray.count;i++){
                                        LGNSubjectModel *subjectModel = self.subjectArray[i];
                                            
                                 if([subjectModel.SubjectName isEqualToString:currentTitle]){
                                     
                                     self.SeletSubjectID  = subjectModel.SubjectID;
                                      self.viewModel.paramModel.SubjectID =subjectModel.SubjectID;
                                 }
                                   
                                        }
                  
              }
              
           
              
          }
          }
        
           
        
        NSLog(@"%zd",currentTitle.length);
        CGFloat  with = SingleWith *currentTitle.length+20;
        if(with > MaxWith){
            with =MaxWith;
        }
        
        self.dropDown1With = with;
        self.dropDownMenuView.frame =CGRectMake(20, 0, with, 45);
        if([currentTitle isEqualToString:@"全部"]){
            
              self.viewModel.paramModel.ResourceID =@"";
                       self.viewModel.paramModel.MaterialID =@"";
                        self.viewModel.paramModel.SubjectID =@"";
                       //请求数据
                     [self lg_bindData];
            [self.dropDownMenuView2 removeFromSuperview];
             [self.dropDownMenuView3 removeFromSuperview];
        }else{
           
            //获取章节数据
                    [self  getZJData];

        }
          
        
           
          
            };
             [self.view addSubview:self.dropDownMenuView =dropDownMenuView];
      
    
}

//设置教材目录数据
- (void)setZJUZ{
    
    [self.dropDownMenuView2 removeFromSuperview];
    [self.dropDownMenuView3 removeFromSuperview];
    
    NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
        for(int i=0;i<self.sectionArray.count;i++){
            LGNTextBookListModel *sectionModel = self.sectionArray[i];
            
            [subArr addObject:sectionModel.BookName];
        }
    
    //默认选中第一个
       LGNTextBookListModel *sectionModel = self.sectionArray[0];
      self.sectionID =sectionModel.BookId;
    self.sectionName = sectionModel.BookName;
    
    NSString * titleName =subArr[0];
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
                                           
                                    if([subjectModel.BookName isEqualToString:currentTitle]){
                                        self.sectionID =subjectModel.BookId;
                                        self.sectionName = subjectModel.BookName;
                                       
                                    }
                                       }
                                
                                //获取章节数据
                                [self  getJDData];

                   };
          [self.view addSubview:self.dropDownMenuView2 =dropDownMenuView2];
      [self  getJDData];
}

//设置节点数据
- (void)setJDUI{
     [self.dropDownMenuView3 removeFromSuperview];
    
    NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
          for(int i=0;i<self.nodeArray.count;i++){
              LGNTextBookListModel *sectionModel = self.nodeArray[i];
              
              [subArr addObject:sectionModel.UnionName];
          }
    //默认选中第一个
     LGNTextBookListModel *sectionModel = self.nodeArray[0];
    self.nodeID =sectionModel.UnionId;
    
      CGFloat  with = (kMain_Screen_Width-105)-self.dropDown2With-self.dropDown1With;
    
     NOteDropDownMenuView *dropDownMenuView3 = [[NOteDropDownMenuView alloc] initWithFrame:CGRectMake(20+10+10+self.dropDown1With+self.dropDown2With, 0, with, 45)];

                       dropDownMenuView3.dataSourceArr = @[

                                                            subArr,

                                                           ].mutableCopy;

                       dropDownMenuView3.defaulTitleArray = [NSArray arrayWithObjects:subArr[0], nil];
                 // 下拉列表 起始y
                     dropDownMenuView3.startY = CGRectGetMaxY(_dropDownMenuView.frame);
                 dropDownMenuView3.chooseConditionBlock = ^(NSString *currentTitle, NSArray *currentTitleArray){
                       CGFloat  with = (kMain_Screen_Width-105)-self.dropDown2With-self.dropDown1With;
                     self.dropDown3With = with;
                    self.dropDownMenuView3.frame =CGRectMake(20+10+10+self.dropDown1With+self.dropDown2With, 0, with, 45);
                     
                     
                     
    //                 通过章节  去获取节点详情
                                    for(int i=0;i<self.nodeArray.count;i++){
                                               LGNTextBookListModel *subjectModel = self.nodeArray[i];
                                               
                                        if([subjectModel.UnionName isEqualToString:currentTitle]){
                                            self.nodeID =subjectModel.UnionId;
                                            
                                           
                                        }
                                           }
                                    
                self.viewModel.paramModel.ResourceID =self.sectionID;
                self.viewModel.paramModel.MaterialID =self.nodeID;
                [self lg_bindData];

                       };
              [self.view addSubview:self.dropDownMenuView3 =dropDownMenuView3];
    
    self.viewModel.paramModel.ResourceID =self.sectionID;
                 self.viewModel.paramModel.MaterialID =self.nodeID;

                 [self lg_bindData];
}

#pragma mark -通用版教学(学习推荐)

//获取章节  显示数据
- (void)getZJData{
    
//     NSDictionary *paramse =@{
//        @"subjectId":@"S2-English",
//        @"gradeId":@"",
//        @"termId":@"",
//
//                                              };
    
    NSDictionary *paramse =@{
          @"subjectId":self.viewModel.paramModel.SubjectID,

                                                };
     [self.viewModel.getTextbookListRateCommand execute:paramse];

   
    
}

//设置章节数据 - 通用教学
- (void)setZJUZTY{
    
    [self.dropDownMenuView removeFromSuperview];
    [self.dropDownMenuView2 removeFromSuperview];

    
    NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
    NSString * titleName;
        for(int i=0;i<self.sectionArray.count;i++){
            LGNTextBookListModel *sectionModel = self.sectionArray[i];
            
            [subArr addObject:sectionModel.BookName];
            if([sectionModel.BookId isEqualToString:self.viewModel.paramModel.ResourceID]){
                
                titleName =sectionModel.BookName;
            }
        }
    

    NOteDropDownMenuView *dropDownMenuView = [[NOteDropDownMenuView alloc] initWithFrame:CGRectMake(20, 0, 80, 45)];

                        dropDownMenuView.dataSourceArr = @[

                                                             subArr,

                                                            ].mutableCopy;
    


                        dropDownMenuView.defaulTitleArray = [NSArray arrayWithObjects:titleName, nil];


               // 下拉列表 起始y
                      dropDownMenuView.startY = CGRectGetMaxY(dropDownMenuView.frame);
            @weakify(self);

            dropDownMenuView.chooseConditionBlock = ^(NSString *currentTitle, NSArray *currentTitleArray){
            @strongify(self);

                //                 通过章节  去获取节点详情
    for(int i=0;i<self.sectionArray.count;i++){
        LGNTextBookListModel *subjectModel = self.sectionArray[i];
                                                           
        if([subjectModel.BookName isEqualToString:currentTitle]){
        self.sectionID =subjectModel.BookId;
            self.sectionName = subjectModel.BookName;
                                                       
        }
        }
                                                
                //获取章节数据
                [self  getJDData];

                        };
    [self.view addSubview:self.dropDownMenuView =dropDownMenuView];
    
    
    
    
     [self  getJDData];
    
}

//获取节点 数据
- (void)getJDData{
    
    if(IsStrEmpty(self.sectionID)){
        
        self.sectionID = self.viewModel.paramModel.ResourceID;
    }
      

     
    NSDictionary *paramse =@{
              @"bookId":self.sectionID,
       
                                                   };
    
    
     
     
         [self.viewModel. getNodeInfoRateCommand execute:paramse];

   
    
}

//设置通用教学的数据
- (void)setJDUITY{
    
    [self.dropDownMenuView2 removeFromSuperview];
    NSMutableArray * subArr = [NSMutableArray arrayWithCapacity:10];
    NSString * titleName;
          for(int i=0;i<self.nodeArray.count;i++){
              LGNTextBookListModel *sectionModel = self.nodeArray[i];
              
              [subArr addObject:sectionModel.UnionName];
              if([sectionModel.UnionId isEqualToString:self.viewModel.paramModel.MaterialID]){
                  
                  titleName =sectionModel.UnionName;
                  self.nodeID =sectionModel.UnionId;

              }
          }
      
    if(IsStrEmpty(titleName)){
        
        //若是没有就默认选中第一个
         LGNTextBookListModel *sectionModel = self.nodeArray[0];
        self.nodeID =sectionModel.UnionId;
        titleName =sectionModel.UnionName;
    }
        

    NOteDropDownMenuView *dropDownMenuView2 = [[NOteDropDownMenuView alloc] initWithFrame:CGRectMake(105, 0,kMain_Screen_Width-105-100, 45)];
    
                      dropDownMenuView2.dataSourceArr = @[

                                                           subArr,

                                                          ].mutableCopy;

                      dropDownMenuView2.defaulTitleArray = [NSArray arrayWithObjects:titleName, nil];
                // 下拉列表 起始y
                    dropDownMenuView2.startY = CGRectGetMaxY(_dropDownMenuView.frame);
                dropDownMenuView2.chooseConditionBlock = ^(NSString *currentTitle, NSArray *currentTitleArray){

   //                 通过章节  去获取节点详情
                                   for(int i=0;i<self.nodeArray.count;i++){
                                              LGNTextBookListModel *subjectModel = self.nodeArray[i];
                                              
                                       if([subjectModel.UnionName isEqualToString:currentTitle]){
                                           self.nodeID =subjectModel.UnionId;
                                           
                                          
                                       }
                                          }
                                   
    NSLog(@"%@---%@",self.sectionID,self.nodeID);
                //    [kMBAlert showStatus:@"请求接口"];
                    
    self.viewModel.paramModel.ResourceID =self.sectionID;
 self.viewModel.paramModel.MaterialID =self.nodeID;
                    [self lg_bindData];

                      };

    NSLog(@"%@---%@",self.sectionID,self.nodeID);
    

    
    [self.view addSubview:self.dropDownMenuView2 =dropDownMenuView2];
    
     [self.view addSubview:self.remarkBtn];
        [self.remarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                  make.top.equalTo(self.view).offset(10);
                    make.right.equalTo(self.view).offset(-10);
    
                    make.width.mas_equalTo(85);
                    make.height.mas_equalTo(30);
                        }];
    
       // [kMBAlert showStatus:@"请求接口"];
    self.viewModel.paramModel.ResourceID =self.sectionID;
    self.viewModel.paramModel.MaterialID =self.nodeID;
                       [self lg_bindData];
    
}


#pragma mark - AddNote
- (void)rightNavigationBar{
     [self.seleteDataView hideViewForCelerity];
    self.newToolView.seleteBtn.selected = NO;
    
    LGNNoteEditViewController *editController = [[LGNNoteEditViewController alloc] init];
    if(self.systemType == SystemUsedTypeTYJX && self.paramModel.MainTY ==0){
       editController.tysubjectArray = self.subjectArray;
    }

   
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
        
        self.isRefreshData = NO;
        [self setuTopView];
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

- (void)clickremarkEvent:(UIButton *)sender{
    // 是否是查看重点笔记；1表示查看重点笔记，-1是查看全部笔记

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

      UIAlertAction *action = [UIAlertAction actionWithTitle:@"查看全部笔记" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

         [_remarkBtn setTitleColor:LGRGB(37, 37, 37) forState:UIControlStateNormal];
        [_remarkBtn setTitle:@"全部笔记" forState:UIControlStateNormal];
         [_remarkBtn setImage:[NSBundle lg_imagePathName:@"note_remark_unselected"] forState:UIControlStateNormal];

          [self remarkEvent:NO];

      }];
      UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"只看重点笔记" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

           [_remarkBtn setTitle:@"重点笔记" forState:UIControlStateNormal];
         [_remarkBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_remarkBtn setImage:[NSBundle lg_imagePathName:@"note_remark_selected"] forState:UIControlStateNormal];

          [self remarkEvent:YES];

      }];

      UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

      }];

    if([_remarkBtn.titleLabel.text isEqualToString:@"重点笔记"]){
         [action setValue:LGRGB(94, 94, 94) forKey:@"titleTextColor"];
         [action2 setValue:LGRGB(41, 162, 252) forKey:@"titleTextColor"];

    }else{
         [action setValue:LGRGB(41, 162, 252) forKey:@"titleTextColor"];
           [action2 setValue:LGRGB(94, 94, 94) forKey:@"titleTextColor"];
    }


      [cancle setValue:LGRGB(94, 94, 94) forKey:@"titleTextColor"];


      [alert addAction:action];
      [alert addAction:action2];

      [alert addAction:cancle];
      [self presentViewController:alert animated:YES completion:nil];

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
    
        
        if (self.paramModel.SystemType ==SystemType_ALL || self.paramModel.SystemType ==SystemType_ASSISTANTER ||self.paramModel.SystemType ==SystemType_YPT||self.paramModel.SystemType ==SystemType_TYJX) {
            [self.tableView allocInitRefreshHeader:YES allocInitFooter:YES];
            
        }else{
//            其他集成进来的 不分页  每次加载全部 不支持上拉加载更多
            [self.tableView allocInitRefreshHeader:YES allocInitFooter:NO];
        }
        
 
   
        
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
        if(_systemType ==SystemUsedTypeAssistanter){
            _toolView.filterBtn.hidden = YES;
             _toolView.remarkBtn.hidden = YES;
        }
        
        
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


- (UIButton *)remarkBtn{
    if (!_remarkBtn) {
        _remarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _remarkBtn.frame = CGRectZero;
        [_remarkBtn setImage:[NSBundle lg_imagePathName:@"note_remark_unselected"] forState:UIControlStateNormal];
        [_remarkBtn setTitle:@"全部笔记" forState:UIControlStateNormal];
//        [_remarkBtn setImage:[NSBundle lg_imagePathName:@"note_remark_selected"] forState:UIControlStateSelected];
        _remarkBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10/2, 0, 10/2);
          _remarkBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10/2, 0, -10/2);
        _remarkBtn.titleLabel.font = LGFontSize(15);

        _remarkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_remarkBtn setTitleColor:LGRGB(37, 37, 37) forState:UIControlStateNormal];

        [_remarkBtn addTarget:self action:@selector(clickremarkEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _remarkBtn;
}
@end

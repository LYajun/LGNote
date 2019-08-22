//
//  NoteViewModel.m
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "LGNViewModel.h"
#import "LGNoteNetworkManager.h"
#import "LGNoteConfigure.h"
#import "LGNoteMBAlert.h"
#import <MJExtension/MJExtension.h>
#import "NoteXMLDictionary.h"
#import "LGNNoteModel.h"

NSString *const CheckNoteBaseUrlKey = @"CheckNoteBaseUrlKey";

@interface LGNViewModel ()
/** 数据源处理 */
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation LGNViewModel

- (instancetype)init{
    if (self = [super init]) {
        [self initViewModel];
        self.dataArray = [NSMutableArray array];
        self.paramModel = [[LGNParamModel alloc] init];
    }
    return self;
}

- (void)initViewModel{
    self.refreshSubject = [RACSubject subject];
    @weakify(self);
    self.refreshCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
//        NSString *checkUrl = [[NSUserDefaults standardUserDefaults] valueForKey:CheckNoteBaseUrlKey];
//        if (!IsStrEmpty(checkUrl)) {
//            self.paramModel.NoteBaseUrl = @"http://192.168.3.158:1212/";
//            self.paramModel.NoteBaseUrl = checkUrl;
//            [self p_getData];
//        } else {
        
        NSLog(@"%@",self.paramModel.NoteBaseUrl);
        
        if(IsStrEmpty(self.paramModel.NoteBaseUrl)){
            
               RACSignal *checkSignal = [self checkNoteBaseUrl];
            
            [checkSignal subscribeNext:^(NSString *  _Nullable url) {
                if (!IsStrEmpty(url)) {
                    [[NSUserDefaults standardUserDefaults] setObject:url forKey:CheckNoteBaseUrlKey];
                    self.paramModel.NoteBaseUrl = url;
                    
                    
                    [self p_getData];
                } else {
                    [self.refreshSubject sendNext:@[]];
                }
            }];
        }else{

             [[NSUserDefaults standardUserDefaults] setObject:self.paramModel.NoteBaseUrl forKey:CheckNoteBaseUrlKey];
                 [self p_getData];
        }
        
        
        
        
        
//        }
        
        return [RACSignal empty];
    }];
    
    
    self.nextPageCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        
        
        RACSignal *mainSignal = [self getNotesWithUserID: Note_HandleParams(self.paramModel.UserID) systemID:Note_HandleParams(self.paramModel.C_SystemID) subjectID: Note_HandleParams(self.paramModel.C_SubjectID) schoolID: Note_HandleParams(self.paramModel.SchoolID) pageIndex:self.paramModel.PageIndex pageSize:self.paramModel.PageSize keycon: Note_HandleParams(self.paramModel.SearchKeycon)];
        
        [mainSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            NSArray *notesArray = [x firstObject];
            self.totalCount = [[x lastObject] integerValue];
            [self.dataArray addObjectsFromArray:notesArray];
            [self.refreshSubject sendNext:self.dataArray];
        }];
        
        return [RACSignal empty];
    }];
    
    
    self.operateSubject = [RACSubject subject];
    self.operateCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        
        @strongify(self);
        [[self operatedNoteWithParams:input] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.operateSubject sendNext:x];
        }];
        return [RACSignal empty];
    }];
    
   /** 获取本学期开始和截止时间 */
    self.getTermTimeSubject = [RACSubject subject];
    self.getTermTimeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        @strongify(self);
        [[self getTermTimeWithParams:input] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.getTermTimeSubject sendNext:x];
        }];
        return [RACSignal empty];
    }];
    
    
    
//    self.deletedSubject = [RACSubject subject];
//    self.deletedCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NoteModel * _Nullable inputModel) {
//        @strongify(self);
//        [[self deletedNoteWithUserID:self.paramModel.UserID noteID:inputModel.NoteID schoolID:self.paramModel.SchoolID systemID:inputModel.SystemID subjectID:inputModel.SubjectID] subscribeNext:^(id  _Nullable x) {
//            @strongify(self);
//            [self.deletedSubject sendNext:x];
//        }];
//        return [RACSignal empty];
//    }];
    
    self.getDetailNoteSubject  = [RACSubject subject];
    self.getDetailNoteCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(LGNNoteModel * _Nullable inputModel) {
        @strongify(self);
        

        

        
        
        RACSignal * mainSignal = [self getOneNoteInfoWithNoteID: Note_HandleParams(inputModel.NoteID)];
        
        [mainSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.getDetailNoteSubject sendNext:x];
        }];
        return [RACSignal empty];
    }];
    
    self.searchSubject = [RACSubject subject];
    self.searchCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        
        
        
        RACSignal *mainSignal = [self getNotesWithUserID:Note_HandleParams(self.paramModel.UserID) systemID: Note_HandleParams(self.paramModel.C_SystemID) subjectID:Note_HandleParams(self.paramModel.C_SubjectID) schoolID: Note_HandleParams(self.paramModel.SchoolID) pageIndex:0 pageSize:0 keycon:Note_HandleParams(self.paramModel.SearchKeycon)];
        
        [mainSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            NSArray *notesArray = [x firstObject];
            [self.searchSubject sendNext:notesArray];
        }];
        return [RACSignal empty];
    }];
}

- (void)p_getData{
    
    //上传笔记来源信息
    //上传笔记相关联来源详细信息接口只在提供给各应用系统集成时，在他们的系统内启动笔记工具时调用。（学习小助手和提供给云平台的版本可以不调用）调用时如果判断ResourceID为空，可以直接不调用
    
    if(self.paramModel.SystemType == SystemType_ASSISTANTER ||self.paramModel.SystemType == SystemType_YPT){
        
        
        
        
    }else{
        
        if(!IsStrEmpty(self.paramModel.ResourceID)){
          
            
            RACSignal *uploadSignal = [self uploadNoteSourceInfo:@""];
            
            [uploadSignal subscribeNext:^(id  _Nullable x) {
                
            }];
        }
        
       
    }
    

   
    
    //获取当前学生笔记列表
    RACSignal *mainSignal = [self getNotesWithUserID: Note_HandleParams(self.paramModel.UserID) systemID:Note_HandleParams(self.paramModel.C_SystemID) subjectID:Note_HandleParams(self.paramModel.C_SubjectID) schoolID:Note_HandleParams(self.paramModel.SchoolID) pageIndex:self.paramModel.PageIndex pageSize:self.paramModel.PageSize keycon:Note_HandleParams(self.paramModel.SearchKeycon)];
    
    
    //获取当前学生学科列表
    RACSignal *subjectSignal ;
   // 获取系统列表
    RACSignal *getSystemSigal ;
    
    //课前课后不获取学科列表和系统列表接口
    
    if(self.paramModel.SystemType == SystemType_KQ ||self.paramModel.SystemType == SystemType_HOME){
        
        self.paramModel.Skip = -1;
    }else{
         //获取当前学生学科列表
        subjectSignal = [self getAllSubjectInfo];
        // 获取系统列表
         getSystemSigal = [self getAllSystemInfo];
    }
   
    
    
    
    
    // 如果skip == -1 的则表示跳过了 获取学科或者系统这两个接口
    @weakify(self);
    if (self.paramModel.Skip == -1) {
        [mainSignal subscribeNext:^(NSArray * _Nullable notesInfo) {
            // 清空笔记数据
            [self.dataArray removeAllObjects];
            NSArray *notesArray = [notesInfo firstObject];
            [self.dataArray addObjectsFromArray:notesArray];
            self.totalCount = [[notesInfo lastObject] integerValue];
            [self.refreshSubject sendNext:self.dataArray];
        }];
    } else {
        // 信号聚合
        RACSignal *combineSignal = [RACSignal combineLatest:@[mainSignal,subjectSignal,getSystemSigal]];
        [combineSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            RACTupleUnpack(NSArray *notesInfo, NSArray *subjectArray, NSArray *systemArray) = x;
            // 清空笔记数据
            [self.dataArray removeAllObjects];
            NSArray *notesArray = [notesInfo firstObject];
            [self.dataArray addObjectsFromArray:notesArray];
            self.totalCount = [[notesInfo lastObject] integerValue];
            
            _subjectArray = subjectArray;
            _systemArray = systemArray;
            
            // 判断是否请求到学科或者系统数据
            if (IsArrEmpty(subjectArray) || IsArrEmpty(systemArray)) {
                self.paramModel.Skip = 0;
            } else {
                self.paramModel.Skip = -1;
            }
            
            [self.refreshSubject sendNext:self.dataArray];
        }];
    }
}

- (RACSignal *)checkNoteBaseUrl{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSString *url = [self.paramModel.CPBaseUrl stringByAppendingFormat:@"/Base/WS/Service_Basic.asmx/WS_G_GetSubSystemServerInfo?sysID=%@&subjectID=",@"S22"];
        
        
        [kNetwork.setRequestUrl(url).setRequestType(GETXML)starSendRequestSuccess:^(id respone) {
            
            NSDictionary *dic = [NSDictionary NotedictionaryWithXMLString:respone];
            
            // 配置笔记工具Uurl
            NSArray *noteSystemAllkey = [dic NotearrayValueForKeyPath:@"string"];
            NSString *baseUrl = IsArrEmpty(noteSystemAllkey) ? @"":[noteSystemAllkey lastObject];
            
            [subscriber sendNext:baseUrl];
            [subscriber sendCompleted];
            
        } failure:^(NSError *error) {
            
            
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}
//获取当前学生学科列表
- (RACSignal *)getAllSubjectInfo{
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSString *url = [self.paramModel.NoteBaseUrl stringByAppendingString:@"api/V2/Notes/GetSubjectInfo"];
        
        NSLog(@"%@",url);
       // Note_HandleParams(self.paramModel.Token)
       
        NSDictionary *params = @{
                                 @"UserID":Note_HandleParams(self.paramModel.UserID),
                                 @"UserType":@(self.paramModel.UserType),
                                 @"SecretKey": Note_HandleParams(self.paramModel.Secret),
                                 @"SchoolID":Note_HandleParams(self.paramModel.SchoolID),
                                 @"Token":Note_HandleParams(self.paramModel.Token),
                                 @"BackUpOne":@"",
                                 @"BackUpTwo":@""
                                 };
       
       [kNetwork.setRequestUrl(url).setRequestType(POSTENCRY).setEncryKey(Note_HandleParams(self.paramModel.UserID)).setToken( Note_HandleParams(self.paramModel.Token)).setParameters(params)starSendRequestSuccess:^(id respone) {
            
            NSLog(@"==UserID%@==Token%@==Secret%@==SchoolID%@",self.paramModel.UserID,self.paramModel.Token,self.paramModel.Secret,self.paramModel.SchoolID);
            
            
            NSLog(@"%@",respone);
            
            if (![respone[kErrorcode] hasSuffix:kSuccess]) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return;
            }
            
            NSArray *dataArray = respone[kResult];
            dataArray = [[dataArray.rac_sequence map:^id _Nullable(id  _Nullable value) {
                LGNSubjectModel *model = [LGNSubjectModel mj_objectWithKeyValues:value];
                return model;
            }] array];
            [subscriber sendNext:dataArray];
            [subscriber sendCompleted];
            
        } failure:^(NSError *error) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

//获取当前学生系统列表
- (RACSignal *)getAllSystemInfo{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSString *url = [self.paramModel.NoteBaseUrl stringByAppendingString:@"api/V2/Notes/GetSystemInfo"];
        
        
        NSDictionary *params = @{
                                
                                 
                                 @"UserID":Note_HandleParams(self.paramModel.UserID),
                                 @"UserType":@(self.paramModel.UserType),
                                 @"SecretKey": Note_HandleParams(self.paramModel.Secret),
                                 @"Token":Note_HandleParams(self.paramModel.Token),
                                 @"BackUpOne":@"",
                                 @"BackUpTwo":@""
                                 };
       [kNetwork.setRequestUrl(url).setRequestType(POSTENCRY).setEncryKey( Note_HandleParams(self.paramModel.UserID)).setToken( Note_HandleParams(self.paramModel.Token)).setParameters(params)starSendRequestSuccess:^(id respone) {
            
            if (![respone[kErrorcode] hasSuffix:kSuccess]) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return;
            }
            
            NSArray *dataArray = respone[kResult];
            dataArray = [[dataArray.rac_sequence map:^id _Nullable(id  _Nullable value) {
                SystemModel *model = [SystemModel mj_objectWithKeyValues:value];
                return model;
            }] array];
            [subscriber sendNext:dataArray];
            [subscriber sendCompleted];
            
        } failure:^(NSError *error) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}
  //获取某条笔记的全部信息
- (RACSignal *)getOneNoteInfoWithNoteID:(NSString *)noteID{
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSString *url = [self.paramModel.NoteBaseUrl stringByAppendingString:@"api/V2/Notes/GetNoteInfoByID"];
        
       
        NSDictionary *params = @{
                                 @"UserID":Note_HandleParams(self.paramModel.UserID),
                                 @"UserType":@(self.paramModel.UserType),
                                 @"NoteID":noteID,
                                 @"SecretKey": Note_HandleParams(self.paramModel.Secret),
                                 @"BackUpOne":@"",
                                 @"BackUpTwo":@""
                                 };
         [kNetwork.setRequestUrl(url).setRequestType(POSTENCRY).setEncryKey(Note_HandleParams(self.paramModel.UserID)).setToken( Note_HandleParams(self.paramModel.Token)).setParameters(params)starSendRequestSuccess:^(id respone) {
            
            NSLog(@"%@",respone);
            
            if (![respone[kErrorcode] hasSuffix:kSuccess]) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return;
            }
            

            LGNNoteModel * model =  [LGNNoteModel mj_objectWithKeyValues:respone[kResult]];
        
            [subscriber sendNext:model];
            [subscriber sendCompleted];
            
           
        
            
        } failure:^(NSError *error) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

 //获取当前学生笔记列表
- (RACSignal *)getNotesWithUserID:(NSString *)userID systemID:(NSString *)systemID subjectID:(NSString *)subjectID schoolID:(NSString *)schoolID pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)size keycon:(NSString *)keycon{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSString *url = [self.paramModel.NoteBaseUrl stringByAppendingString:@"api/V2/Notes/GetNotesInformation"];
        
        
        
                NSDictionary *params;
        if (self.paramModel.SystemType ==SystemType_ALL || self.paramModel.SystemType ==SystemType_ASSISTANTER ||self.paramModel.SystemType ==SystemType_YPT) {
            params = @{
                                     @"UserID":Note_HandleParams(self.paramModel.UserID),
                                     @"UserType":@(self.paramModel.UserType),
                                     @"ResourceID":Note_HandleParams(self.paramModel.ResourceID),
                                     @"SubjectID":subjectID,
                                     @"SecretKey":Note_HandleParams(self.paramModel.Secret),
                                     @"SchoolID":schoolID,
                                     @"MaterialID":Note_HandleParams(self.paramModel.MaterialID),
                                     @"IsKeyPoint":Note_HandleParams(self.paramModel.IsKeyPoint),
                                     @"SysID":systemID,
                                     @"Keycon":keycon,
                                     @"Page":@(pageIndex),
                                     @"StartTime":Note_HandleParams(self.paramModel.StartTime),
                                     @"EndTime":Note_HandleParams(self.paramModel.EndTime),
                                     
                                     @"Size":@(size),
                                     @"BackUpOne":@"All",
                                     @"BackUpTwo":@""
                                     };
            
        }else{
            
          params = @{
                                     @"UserID": Note_HandleParams(self.paramModel.UserID),
                                     @"UserType":@(self.paramModel.UserType),
                                     @"ResourceID":@"",
                                     @"SubjectID":subjectID,
                                     @"SecretKey": Note_HandleParams(self.paramModel.Secret),
                                     @"SchoolID":schoolID,
                                     @"MaterialID":@"",
                                     @"IsKeyPoint":Note_HandleParams(self.paramModel.IsKeyPoint),
                                     @"SysID":systemID,
                                     @"Keycon":keycon,
                                     @"Page":@(pageIndex),
                                     @"StartTime":Note_HandleParams(self.paramModel.StartTime),
                                     @"EndTime":Note_HandleParams(self.paramModel.EndTime),
                                     
                                     @"Size":@(size),
                                     @"BackUpOne":@"",
                                     @"BackUpTwo":@""
                                     };
            
        }
        
       
        [kNetwork.setRequestUrl(url).setRequestType(POSTENCRY).setEncryKey( Note_HandleParams(self.paramModel.UserID)).setToken(Note_HandleParams(self.paramModel.Token)).setParameters(params)starSendRequestSuccess:^(id respone) {
            
            
            
            if (![respone[kErrorcode] hasSuffix:kSuccess]) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return;
            }
            
            NSDictionary *jsDic = respone[kResult];
            if (!jsDic) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return;
            }
            
            NSArray *dataArray = jsDic[@"NoteList"];
            NSString *totalCount = jsDic[@"TotalCount"];
            dataArray = [[dataArray.rac_sequence map:^id _Nullable(id  _Nullable value) {
                LGNNoteModel *model = [LGNNoteModel mj_objectWithKeyValues:value];
                
                NSMutableArray *imageUrls = [self filterImageUrlWithHtml:model.NoteContent];
                // 如果有多张图片，只取前三张用来在首页展示
                if (imageUrls.count > 3 && imageUrls.count != 0) {
                    model.imgaeUrls = [imageUrls subarrayWithRange:NSMakeRange(0, imageUrls.count)];
                } else {
                    model.imgaeUrls = imageUrls;
                }
                
                // 判断是否是图文混排
                NSString *contentString = model.NoteContent_Att.string;
                contentString = [contentString stringByReplacingOccurrencesOfString:@" " withString:@""];
                contentString = [contentString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                contentString = [contentString stringByReplacingOccurrencesOfString:@"\uFFFC" withString:@""];
                   contentString = [contentString stringByReplacingOccurrencesOfString:@"\U00002028" withString:@""];
                
                
                if (!IsArrEmpty(imageUrls) && !IsStrEmpty(contentString)) {
                    model.mixTextImage = YES;
                    
                } else {
                    model.mixTextImage = NO;
                    
                }
                
                model.TotalCount = [jsDic[@"TotalCount"] integerValue];
                return model;
            }] array];
            [subscriber sendNext:@[dataArray,totalCount]];
            [subscriber sendCompleted];
            
        } failure:^(NSError *error) {
           

            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

/** 获取本学期开始和截止时间 */

- (RACSignal *)getTermTimeWithParams:(id)params{
    
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSString *url = [self.paramModel.NoteBaseUrl stringByAppendingString:@"api/V2/Notes/GetTermInformation"];
        
        NSLog(@"%@",url);
        
        
        // Note_HandleParams(self.paramModel.Token)
        
        NSDictionary *params = @{
                                 @"UserID":Note_HandleParams(self.paramModel.UserID),
                                 @"UserType":@(self.paramModel.UserType),
                                 @"SecretKey": Note_HandleParams(self.paramModel.Secret),
                                 @"SchoolID":Note_HandleParams(self.paramModel.SchoolID),
                                 
                                 @"BackUpOne":@"",
                                 @"BackUpTwo":@""
                                 };
        
        [kNetwork.setRequestUrl(url).setRequestType(POSTENCRY).setEncryKey(Note_HandleParams(self.paramModel.UserID)).setToken( Note_HandleParams(self.paramModel.Token)).setParameters(params)starSendRequestSuccess:^(id respone) {
            
          
            
            if (![respone[kErrorcode] hasSuffix:kSuccess]) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return;
            }

            
            
            self.paramModel.TermStartTime = respone[@"Result"][@"TermStartDate"];
            self.paramModel.TermEndTime = respone[@"Result"][@"TermEndDate"];

            
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            
        } failure:^(NSError *error) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}



//添加、编辑和删除当前学生笔记   1添加  0编辑  3 删除
- (RACSignal *)operatedNoteWithParams:(id)params{
    
    
    
    
   // 学习小助手 和后期提供给平台集成的整体版本，[ResourceID]和[MaterialID]这两个值都赋值为SystemID
    if (self.paramModel.SystemType ==SystemType_ALL || self.paramModel.SystemType ==SystemType_ASSISTANTER ||self.paramModel.SystemType ==SystemType_YPT) {
        
        if(IsStrEmpty(params[@"MaterialID"])){
            
            [params setValue:params[@"SystemID"] forKey:@"MaterialID"];
        }
        
        if(IsStrEmpty(params[@"ResourceID"])){
            
            [params setValue:params[@"SystemID"] forKey:@"ResourceID"];
        }
    }

   

    
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        NSString *url = [self.paramModel.NoteBaseUrl stringByAppendingString:@"api/V2/Notes/OperateNote"];
       
        
        [kNetwork.setRequestUrl(url).setRequestType(POSTENCRY).setEncryKey(Note_HandleParams(self.paramModel.UserID)).setToken( Note_HandleParams(self.paramModel.Token)).setParameters(params)starSendRequestSuccess:^(id respone) {
            
     
        
            if (![respone[kErrorcode] hasSuffix:kSuccess]) {
                NSString *message;
                if (self.paramModel.OperateFlag == 1) {
                    message = @"添加失败";
                } else if (self.paramModel.OperateFlag == 0) {
                    message = @"保存失败";
                } else {
                    message = @"删除失败";
                }
                
                [kMBAlert showErrorWithStatus:message];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return;
            }
            
            NSString *message;
            if (self.paramModel.OperateFlag == 1) {
                message = @"新建笔记成功";
            } else if (self.paramModel.OperateFlag == 0) {
                message = @"编辑笔记成功";
            } else {
                message = @"删除笔记成功";
            }
            [kMBAlert showSuccessWithStatus:message afterDelay:1 completetion:^{
                [subscriber sendNext:message];
                [subscriber sendCompleted];
            }];
            
        } failure:^(NSError *error) {
            [kMBAlert showErrorWithStatus:@"操作失败，请检查网络后重试"];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (RACSignal *)deletedNoteWithUserID:(NSString *)userID noteID:(NSString *)noteID schoolID:(NSString *)schoolID systemID:(NSString *)systemID subjectID:(NSString *)subjectID{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSString *url = [self.paramModel.NoteBaseUrl stringByAppendingString:@"api/V2/Notes/DeleteNote"];
        NSDictionary *params = @{
                                 @"UserID":self.paramModel.UserID,
                                 @"UserType":@(self.paramModel.UserType),
                                 @"SubjectID":subjectID,
                                 @"SecretKey":self.paramModel.Secret,
                                 @"SchoolID":self.paramModel.SchoolID,
                                 @"NoteID":noteID,
                                 @"SysID":systemID,
                                 @"BackUpOne":@"",
                                 @"BackUpTwo":@""
                                 };
        [kNetwork.setRequestUrl(url).setRequestType(POST).setParameters(params)starSendRequestSuccess:^(id respone) {
            
            if (![respone[kErrorcode] hasSuffix:kSuccess]) {
                [kMBAlert showErrorWithStatus:@"删除失败,请检查网络后再重试!"];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return;
            }
            
            [kMBAlert showSuccessWithStatus:@"删除成功!" afterDelay:1 completetion:^{
                [subscriber sendNext:@"成功"];
                [subscriber sendCompleted];
            }];
            
            [subscriber sendNext:respone[kResult]];
            [subscriber sendCompleted];
            
        } failure:^(NSError *error) {
            [kMBAlert showErrorWithStatus:@"删除失败,请检查网络后再重试!"];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

//   上传图片
- (RACSignal *)uploadImages:(NSArray<UIImage *> *)images{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSString *url = [self.paramModel.NoteBaseUrl stringByAppendingString:@"api/V2/Notes/UploadImg"];
        NSArray *uploadDatas = [images.rac_sequence map:^id _Nullable(UIImage * _Nullable value) {
            return [self LGUIImageJPEGRepresentationImage:value];
        }].array;
        [kMBAlert showBarDeterminateWithProgress:0];
        [kNetwork.setRequestUrl(url).setRequestType(UPLOAD).setUploadDatas(uploadDatas) startSendRequestWithProgress:^(NSProgress *progress) {
            [kMBAlert showBarDeterminateWithProgress:progress.fractionCompleted];
        } success:^(id respone) {
            
            
            if (![respone[kErrorcode] hasSuffix:kSuccess]) {
                [kMBAlert showErrorWithStatus:respone[kReason]];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return;
            }
            
            NSArray *dataArray = respone[kResult];
            // 图片上传后，暂时取返回的第一个数据，因为每次只上传一张图片，如果后期要一次上传多张，则这里返回一个数组
            
            if (IsArrEmpty(dataArray)) {
                
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                
                return;
            }
            
            NSString *imagePath = [dataArray objectAtIndex:0];
            
           // [kMBAlert showSuccessWithStatus:@"上传成功"];
            [subscriber sendNext:imagePath];
            [subscriber sendCompleted];
            
        } failure:^(NSError *error) {
            [kMBAlert showErrorWithStatus:@"上传失败,请检查网络后再重试!"];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            
        }];
        
        return nil;
    }];
}
 //获取上传笔记相关来源详细信息
- (RACSignal *)uploadNoteSourceInfo:(id)sourceInfo{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSString *url = [self.paramModel.NoteBaseUrl stringByAppendingString:@"api/V2/Notes/UploadNoteSourceInfo"];
        
        
        
        if(IsStrEmpty(self.paramModel.ResourceAndroidLink)){
            
            self.paramModel.ResourceAndroidLink=@"";
            
            
        }
        if(IsStrEmpty(self.paramModel.ResourcePCLink)){
            
            self.paramModel.ResourcePCLink=@"";
            
        }
        
        
        
        NSDictionary *params = @{
                                 @"SystemType":[NSString stringWithFormat:@"%zd",self.paramModel.SystemType],
                                 @"ResourceID":Note_HandleParams(self.paramModel.ResourceID),
                                 @"MaterialID":Note_HandleParams(self.paramModel.MaterialID),
                                 @"ResourceName": Note_HandleParams(self.paramModel.ResourceName),
                                 @"MaterialName":Note_HandleParams(self.paramModel.MaterialName),
                                 @"ResourcePCLink":Note_HandleParams(self.paramModel.ResourcePCLink),
                                 @"ResourceIOSLink":Note_HandleParams(self.paramModel.ResourceIOSLink),
                                 @"ResourceAndroidLink":Note_HandleParams(self.paramModel.ResourceAndroidLink),
                                 @"MaterialURL":@"",
                                 @"MaterialContent":@"",
                                 @"MaterialTotal":Note_HandleParams(self.paramModel.MaterialTotal)
                                 };
        
 [kNetwork.setRequestUrl(url).setRequestType(POSTENCRY).setEncryKey(Note_HandleParams(self.paramModel.UserID)).setToken(Note_HandleParams(self.paramModel.Token)).setParameters(params)starSendRequestSuccess:^(id respone) {
            
            
            
            if (![respone[kErrorcode] hasSuffix:kSuccess]) {
//                [kMBAlert showErrorWithStatus:@"上传失败,请检查网络后再重试!"];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return;
            }
            
//            [kMBAlert showSuccessWithStatus:@"上传成功!" afterDelay:1 completetion:^{
//                [subscriber sendNext:@"成功"];
//                [subscriber sendCompleted];
//            }];
            
            [subscriber sendNext:respone[kResult]];
            [subscriber sendCompleted];
            
        } failure:^(NSError *error) {
//            [kMBAlert showErrorWithStatus:@"上传失败,请检查网络后再重试!"];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

/**
 将图片转化成data （上传图片使用）
 
 @param image <#image description#>
 @return <#return value description#>
 */
- (NSData *)LGUIImageJPEGRepresentationImage:(UIImage *)image{
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    return data;
}


- (RACSignal *)getSubjectIDAndPickerSelectedForSubjectArray:(NSArray *)subjectArray subjectName:(NSString *)subjectName{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        if (IsArrEmpty(subjectArray)) {
            [subscriber sendNext:@[@"0",self.paramModel.SubjectID]];
            [subscriber sendCompleted];
            return nil;
        }
        
        for (int i = 0; i < subjectArray.count; i ++) {
            LGNSubjectModel *subjectN = [subjectArray objectAtIndex:i];
            if ([subjectN.SubjectName isEqualToString:subjectName]) {
                // 第0个学科是"全部"，所以下标需-1
                [subscriber sendNext:@[@(i-1),subjectN.SubjectID]];
                [subscriber sendCompleted];
            }
        }
        return nil;
    }];
}


- (NSMutableArray *)filterImageUrlWithHtml:(NSString *)html{
    NSMutableArray *resultArray = [NSMutableArray array];
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"<(img|IMG)(.*?)(/>|></img>|>)" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    NSArray *result = [regular matchesInString:html options:NSMatchingReportCompletion range:NSMakeRange(0, html.length)];
    for (NSTextCheckingResult *item in result) {
        NSString *imgHtml = [html substringWithRange:[item rangeAtIndex:0]];
        NSArray *tmpArray = nil;
        if ([imgHtml rangeOfString:@"src=\""].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"src=\""];
        } else if ([imgHtml rangeOfString:@"src="].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"src="];
        }
        
        if (tmpArray.count >= 2) {
            NSString *src = tmpArray[1];
            NSUInteger loc = [src rangeOfString:@"\""].location;
            if (loc != NSNotFound) {
                src = [src substringToIndex:loc];
                [resultArray addObject:src];
            }
        }
    }
    return resultArray;
}


- (NSArray *)configureMaterialPickerDataSource{
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:self.paramModel.MaterialCount];
    for (int i = 0; i < self.paramModel.MaterialCount; i ++) {
        NSString *topicTitle = [NSString stringWithFormat:@"第%d大题",i+1];
        [resultArray addObject:topicTitle];
    }
    return resultArray;
}

- (NSArray *)configureSubjectPickerDataSource{
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:self.subjectArray.count];
    for (int i = 0; i < self.subjectArray.count; i ++) {
        // 去除第一个“全部”选项的学科
        if (i != 0) {
            LGNSubjectModel *model = self.subjectArray[i];
            // 去除其他选项的学科
            if(![model.SubjectName isEqualToString:@"其他学科"]){
                [resultArray addObject:model.SubjectName];
            }
        }
    }
    return resultArray;
}



@end

//
//  ViewController.m
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "ViewController.h"
#import "LGNNoteMainViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(80, 300, 100, 44)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"进入笔记" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(enterNoteViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
  //去除text
}


- (void)enterNoteViewController:(UIButton *)sender {

    LGNNoteMainViewController *noteController = [[LGNNoteMainViewController alloc] initWithNaviBarLeftItemStyle:NoteMainViewControllerNaviBarStyleBack systemType:SystemUsedTypeAssistanter];
    // 配置笔记首页所需参数
    noteController.paramModel = [self configureParams];
    
    [self.navigationController pushViewController:noteController animated:YES];
}
/*
 {"SchoolID":"S27-410-731E","UserID":"tcstu105","IsKeyPoint":"-1","SubjectName":"英语","SystemType":0,"MaterialCount":10,"UserName":"userName_null","OperateFlag":0,"SystemID":"630","PageSize":10,"SearchKeycon":"","PageIndex":1,"Token":"22F1C394-6599-438E-9590-ED16A6E4D20C","StartTime":"","CPBaseUrl":"http:\/\/192.168.3.151:10103\/\/","ResourceID":"YXRW-tcldy1-00000000000000000000000000000000000005-7592b5ae-c958-4456-a2f0-3dcbc82f1192","MaterialID":"Local1","Skip":0,"ResourceName":"第五课教学方案_课前预习","UserType":2,"EndTime":"","Secret":"","C_SubjectID":"S2-English","SubjectID":"S2-English","C_SystemID":"630"}
 
 */
- (LGNParamModel *)configureParams{
    LGNParamModel *params = [[LGNParamModel alloc] init];
    
 //   S27-508-EC82==EF3DFC6C-B95F-431D-ABED-301B4037EAB3==g1==2==g1姓名==http://192.168.3.158:10103//===
//S27-508-EC82==0A33CAF1-3279-4D2A-8DD5-9B3BDF20A788==g3==2==g3姓名==http://192.168.3.158:10103//===
    
    params.SystemID = @"S21";
    params.SubjectID = @"All";
    params.C_SystemID = @"All";
    params.PageSize = 10;
    params.PageIndex = 1;
    params.MaterialIndex = -1;
    params.MaterialCount = 10;
    params.SubjectName = @"";
    params.IsKeyPoint = @"-1";
    params.SchoolID = @"S27-508-EC82";
    params.Token = @"0A33CAF1-3279-4D2A-8DD5-9B3BDF20A788";
    params.ResourceName = @"我的笔记";
    params.ResourceID = @"";
    params.MaterialName = @"";
    params.MaterialTotal = @"-1";
    params.ResourceIOSLink = @"";
    params.UserID = @"g3";
    params.UserType = 2;
    params.UserName = @"g3姓名";
    params.CPBaseUrl = @"http://192.168.3.158:10103//";
    params.SystemType = SystemType_ASSISTANTER;
    
    return params;
    
    
    
    
    // 系统ID，传All表示获取全部系统的数据
    params.SystemID = @"630";
    // 学科ID，传All表示获取全部学科数据
    params.SubjectID = @"S2_English";
    // 学科名
    params.SubjectName = @"英语";
    // 学校ID
    params.SchoolID = @"S27-410-731E";
    // token值，需要必须传，不然学科信息获取不到
    params.Token = @"14AD5E09-ED75-40ED-BC00-922F96ABFBCD";
    // 每页数据容量
    params.PageSize = 10;
    // 页面
    params.PageIndex = 1;
    // 是否查看重点笔记，-1表示查看全部，1表示查看重点，0表示非重点
    params.IsKeyPoint = @"-1";
    // 课后标准资料来源第几大题,默认传-1
    params.MaterialIndex = -1;
    // 笔记来源对应学习任务ID （比如作业ID，课前预习ID，自学资料ID）
    params.ResourceID = @"YXRW-tcldy1-00000000000000000000000000000000000005-7592b5ae-c958-4456-a2f0-3dcbc82f1192";
    // 笔记来源名称
    params.ResourceName = @"第五课教学方案_课前预习YXRW-tcldy1-000000000000000000000000000000000";
    // 学习任务相关的学习资料ID，用于取某个资料下的所有笔记
    params.MaterialID = @"Local1";
    params.MaterialName = @"Local1";
    params.ResourceIOSLink = @"";
    params.MaterialTotal = @"-1";
    // 用户ID
    params.UserID = @"tcstu105";
    params.UserName = @"招伟江";
    // 用户类型; 2-学生   3-家长 1-教师 0-管理员
    params.UserType = 2;
    // 基础平台地址,用来获取笔记库url使用
    params.CPBaseUrl = @"http://192.168.3.151:10103/";
    // 大题数目（课后作业专属）
    params.MaterialCount = 10;
    // 调用的系统类型
    /*
     SystemType_HOME,             // 课后
     SystemType_ASSISTANTER,      // 小助手
     SystemType_KQ,               // 课前
     SystemType_CP,               // 基础平台
     SystemType_KT                // 课堂
     */
    params.SystemType = SystemType_KQ;
    
    return params;
}

@end

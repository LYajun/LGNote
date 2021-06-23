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

    LGNNoteMainViewController *noteController = [[LGNNoteMainViewController alloc] initWithNaviBarLeftItemStyle:NoteMainViewControllerNaviBarStyleBack systemType:SystemUsedTypeTYJX];
    
    // 配置笔记首页所需参数
    noteController.paramModel = [self configureParams];
                                 
  
    [self.navigationController pushViewController:noteController animated:YES];
}

- (LGNParamModel *)configureParams{
    LGNParamModel *params = [[LGNParamModel alloc] init];
    
    params.SystemID = @"300";
      params.SubjectID = @"";
      params.C_SystemID =@"300";
      params.SubjectName = @"";
      params.PageSize = 10;
      params.PageIndex = 1;
      params.IsKeyPoint = @"-1";
      params.MaterialIndex = -1;
      params.ResourceID = @"";
      params.ResourceName = @"";
      params.MaterialName = @"";
      params.ResourceIOSLink = @"";
      params.ResourceAndroidLink = @"";
      params.ResourcePCLink = @"";
      params.MaterialTotal = @"-1";
      params.MaterialCount = 10;
      params.MainTY =0;
      params.SystemType = SystemType_TYJX;
     
    
    
      //根据实际的传
      params.SchoolID =@"S27-511-AF57";
      //根据实际的传
      params.Token = @"E6BA4951-CCE0-49E2-BEAE-64B19D999A03";
      //根据实际的传
      params.UserID =@"Stu079";
      //根据实际的传
      params.UserName = @"刘易";
      params.UserType = 2;
      //基础平台地址根据实际的传
      params.CPBaseUrl = @"http://192.168.129.1:30103//";


         params.TermID =  @"2019-202002";
         params.GradeID = @"05B5B9FC-A0ED-4D2E-AEE1-2EE9A1FEBC6B";
      
  
    params.SystemType = SystemType_TYJX;
    
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
//    params.ResourcePCLink = @"";
//    params.ResourceAndroidLink = @"";
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
     SystemType_ALL,              // 全部
     SystemType_HOME,             // 课后
     SystemType_ASSISTANTER,      // 小助手
     SystemType_KQ,               // 课前
     SystemType_CP,               // 基础平台
     SystemType_KT,                // 课堂
     SystemType_ZNT ,               //重难题辅导
     SystemType_YPT                 //云平台
     */
    params.SystemType = SystemType_ZNT;
    
    return params;
}

@end

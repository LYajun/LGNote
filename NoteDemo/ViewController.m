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

- (LGNParamModel *)configureParams{
    LGNParamModel *params = [[LGNParamModel alloc] init];
    
    //S27-508-EC82==684C8D5E-F197-4DD9-BCC5-2FE8A0DFC248==g2==2==g2姓名==http://192.168.3.158:10103//===
    
    params.SystemID = @"S21";
    params.SubjectID = @"All";
    params.C_SystemID = @"All";
    params.PageSize = 10;
    params.PageIndex = 1;
    params.MaterialIndex = -1;
    params.MaterialCount = 10;
    params.SubjectName = @"英语";
    params.IsKeyPoint = @"-1";
    params.SchoolID = @"S14-411-F5DE";
    params.Token = @"E490FADF-D97B-4B17-9F84-E3DA3F2EB09C";
    params.ResourceName = @"我的笔记";
    params.ResourceID = @"YXRW-tcxzl1-00000000000000000000000000000000000033-eb5e4f7e-d8d5-4d75-ab67-e2100d5f08cf";
    params.MaterialName = @"4f166e3330c43040bfc3ba24c89d7050.jpeg";
    params.MaterialID = @"";
    params.MaterialTotal = @"-1";
    params.ResourceIOSLink = @"";
    params.ResourcePCLink = @"";
    params.ResourceAndroidLink=@"";
    params.UserID = @"tcstu161";
    params.UserType = 2;
    params.UserName = @"林进添";
    params.CPBaseUrl = @"http://192.168.129.130:10103//";
    
    params.NoteBaseUrl= @"http://192.168.129.8:10154/";
  
    params.SystemType = SystemType_HOME;
    
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
    params.SystemType = SystemType_ASSISTANTER;
    
    return params;
}

@end

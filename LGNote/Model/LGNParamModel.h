//
//  ParamModel.h
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIkit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

/** 各个项目系统类型 */
typedef NS_ENUM(NSInteger, SystemType) {
    SystemType_ALL,              // 全部
    SystemType_HOME,             // 课后
    SystemType_ASSISTANTER,      // 小助手
    SystemType_KQ,               // 课前
    SystemType_CP,               // 基础平台
    SystemType_DZJC,             //电子素材
    SystemType_XYTJ,             //学友推荐
    SystemType_KT,                // 课堂
    SystemType_ZNT ,               //重难题辅导
    SystemType_YPT ,                //云平台
    SystemType_ZHJS ,                //智慧教室
     SystemType_DZJCK,              //电子教材库
    SystemType_TYJX                //通用版教学

};

@interface LGNParamModel : NSObject
/** 课后标准资料来源第几大题， 默认传 -1 */
@property (nonatomic, assign) NSInteger MaterialIndex;
/** 系统类型，集成时赋值 */
@property (nonatomic, assign) SystemType SystemType;
/** 基础平台地址 */
@property (nonatomic, copy) NSString *CPBaseUrl;
/** 笔记库的url ：各个系统在登录成功时获取，同获取各个系统url一样，笔记库SystemID为:S22 */
@property (nonatomic, copy) NSString *NoteBaseUrl;
/** 笔记ID */
@property (nonatomic, copy) NSString *NoteID;
/** 用户名 */
@property (nonatomic, copy) NSString *UserName;
/** 用户ID */
@property (nonatomic, copy) NSString *UserID;
/** 学校ID */
@property (nonatomic, copy) NSString *SchoolID;
@property (nonatomic, copy) NSString *SchoolLevel; // 传空
/** 学科ID */
@property (nonatomic, copy) NSString *SubjectID;
/** 学科名 */
@property (nonatomic, copy) NSString *SubjectName;
/** 系统ID */
@property (nonatomic, copy) NSString *SystemID;
/** 系统名 */
@property (nonatomic, copy) NSString *SystemName;
@property (nonatomic, copy) NSString *Secret;    // 传空
/** token：必须要传 */
@property (nonatomic, copy) NSString *Token;
/** 笔记来源 */
@property (nonatomic, copy) NSString *ResourceName;
/** 笔记来源ID */  //通用笔记: 章节ID
@property (nonatomic, copy) NSString *ResourceID;
/** 用于取某个资料下的所有笔记 与学习任务相关的学习资料ID((对应任务里面多份资料)) */  //通用教学:资料ID
@property (nonatomic, copy) NSString *MaterialID;
/** 资料名 */
@property (nonatomic, copy) NSString *MaterialName;
/** 跳转笔记来源链接 对应学习任务详情IOS端地址 */
@property (nonatomic, copy) NSString *ResourceIOSLink;
/** 跳转笔记来源链接 对应学习任务详情PC端地址 */
@property (nonatomic, copy) NSString *ResourcePCLink;
/** 跳转笔记来源链接 对应学习任务详情Android端地址 */
@property (nonatomic, copy) NSString *ResourceAndroidLink;
/** 题目大题数量 */
@property (nonatomic, assign) NSInteger MaterialCount;
/** 该份学习资料的总题目数  如无传 -1  */
@property (nonatomic, copy) NSString *MaterialTotal;
/** 1 重点   0 非重点   -1所有 */
@property (nonatomic, copy) NSString *IsKeyPoint;
@property (nonatomic, copy) NSString *StartTime;
@property (nonatomic, copy) NSString *EndTime;
/** 本学期开始时间 */
@property (nonatomic, copy) NSString *TermStartTime;
/** 本学期结束日期 */
@property (nonatomic, copy) NSString *TermEndTime;
/** 学期ID */
@property (nonatomic, copy) NSString *TermID;
/** 年级ID */
@property (nonatomic, copy) NSString *GradeID;

/** 用户类型 */
@property (nonatomic, assign) NSInteger UserType;
/** 页码（获取全部数据传值 （pageindex:0 pageSize:0）） */
@property (nonatomic, assign) NSInteger PageIndex;
/** 每页容量 */
@property (nonatomic, assign) NSInteger PageSize;
/** 跳过某种操作 */
@property (nonatomic, assign) NSInteger Skip;
/** 操作标志 */
@property (nonatomic, assign) NSInteger OperateFlag;
/** 关键字搜索 */
@property (nonatomic, copy)   NSString *SearchKeycon;

/** 自定义：存放学科数组 */
@property (nonatomic, copy)   NSArray *SubjectArray;

/** 通用教学 存放学科数组 */
@property (nonatomic, copy)   NSArray *TYSubjectArray;
/** 备用的学科ID */
@property (nonatomic, copy) NSString *C_SubjectID;
/** 备用的系统ID */
@property (nonatomic, copy) NSString *C_SystemID;

/** 通用教学1  0为平台首页集成 */
@property (nonatomic, assign) NSInteger MainTY;


@property (nonatomic, copy) void(^OpenLinkBlock)(NSString *linkStr,UIViewController *fromController);

@end

NS_ASSUME_NONNULL_END

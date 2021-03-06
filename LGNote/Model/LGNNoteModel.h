//
//  NoteModel.h
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGNNoteModel : NSObject 

/** 笔记标题 */
@property (nonatomic, copy) NSString *NoteTitle;
/** 笔记内容 */
@property (nonatomic, copy) NSString *NoteContent;
/** 笔记内容富文本 */
@property (nonatomic, strong) NSMutableAttributedString *NoteContent_Att;
/** 笔记ID */
@property (nonatomic, copy) NSString *NoteID;
/** 笔记最近编辑时间 */
@property (nonatomic, copy) NSString *NoteEditTime;
/** 学科名 */
@property (nonatomic, copy) NSString *SubjectName;
/** 学科ID */
@property (nonatomic, copy) NSString *SubjectID;
/** 系统ID */
@property (nonatomic, copy) NSString *SystemID;
/** 系统名 */
@property (nonatomic, copy) NSString *SystemName;
/** pc链接 */
@property (nonatomic, copy) NSString *NotePCLink;
/** iOS链接 */
@property (nonatomic, copy) NSString *NoteIOSLink;
@property (nonatomic, copy) NSString *NoteAndroidLink;

/** iOS跳转链接 */
@property (nonatomic, copy) NSString *ResourceIOSLink;

/** 笔记来源ID */
@property (nonatomic, copy) NSString *ResourceID;
/** 笔记来源名 */
@property (nonatomic, copy) NSString *ResourceName;
/** 笔记来源内容 */
@property (nonatomic, copy) NSString *ResourceContent;
/** 是否是重难点 */
@property (nonatomic, copy) NSString *IsKeyPoint;

@property (nonatomic, copy) NSString *MaterialID;
/** 资料名 */
@property (nonatomic, copy) NSString *MaterialName;
@property (nonatomic, assign) NSInteger MaterialIndex;
@property (nonatomic, copy) NSString *StartTime;
@property (nonatomic, copy) NSString *EndTime;

/** 0编辑笔记、1新增笔记、3删除 */
@property (nonatomic, assign) NSInteger OperateFlag;
@property (nonatomic, copy) NSString *UserID;
@property (nonatomic, copy) NSString *UserName;
@property (nonatomic, assign) NSInteger UserType;
@property (nonatomic, copy) NSString *SchoolID;
/** 自定义：笔记数据总数 */
@property (nonatomic, assign) NSInteger TotalCount;
/** 图片网址数组，最多只存三个地址 */
@property (nonatomic, copy) NSArray *imgaeUrls;
/** 是否是图文混排 */
@property (nonatomic, assign) BOOL mixTextImage;
//当前图片的总张数
@property (nonatomic,assign) NSInteger  imageAllCont;

@property (nonatomic, strong) NSMutableDictionary *imageInfo;

- (void)updateImageInfo:(NSDictionary *) imageInfo imageAttr:(NSAttributedString *) imageAttr;

// 将富文本转换从字符串
- (void)updateText:(NSAttributedString *)textAttr;

@end

NS_ASSUME_NONNULL_END

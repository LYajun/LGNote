//
//  YJNewNoteDataModel.h
//  YJNewNote_Example
//
//  Created by 刘亚军 on 2020/4/9.
//  Copyright © 2020 lyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJNewNoteDataModel : NSObject
@property (nonatomic,copy) NSString *UserID;
@property (nonatomic,copy) NSString *UserName;
@property (nonatomic,assign) NSInteger UserType;
@property (nonatomic,copy) NSString *SchoolID;
/** 笔记标题 */
@property (nonatomic,copy) NSString *NoteTitle;
/** 笔记内容 */
@property (nonatomic,copy) NSString *NoteContent;
@property (nonatomic, strong) NSMutableAttributedString *NoteContent_Att;
@property (nonatomic,copy) NSString *NoteCreateTime;
/** 笔记来源 */
@property (nonatomic,copy) NSString *ResourceName;
@property (nonatomic,copy) NSString *ResourceID;

@property (nonatomic,copy) NSString *SystemID;
@property (nonatomic,copy) NSString *SystemName;

@property (nonatomic,copy) NSString *SubjectID;
@property (nonatomic,copy) NSString *SubjectName;

@property (nonatomic,copy) NSString *MaterialName;
@property (nonatomic,copy) NSString *MaterialID;
@property (nonatomic,assign) NSInteger OperateFlag;
/** 是否标志为重点 */
@property (nonatomic,copy) NSString *IsKeyPoint;
@property (nonatomic,assign) NSInteger imageAllCont;
@property (nonatomic,assign) NSInteger MaterialIndex;
@property (nonatomic,assign) NSInteger TotalCount;
/** 是否是图文混排 */
@property (nonatomic, assign) BOOL mixTextImage;


- (void)uploadNoteDataWithComplete:(void (^_Nullable) (BOOL isSuccess))complete;


@property (nonatomic, strong) NSMutableDictionary *imageInfo;
- (void)updateImageInfo:(NSDictionary *) imageInfo imageAttr:(NSAttributedString *) imageAttr;

// 将富文本转换从字符串
- (void)updateText:(NSAttributedString *)textAttr;


- (void)uploadNoteImg:(UIImage *)image complete:(void (^)(NSString * _Nullable imgUrl))complete;
@end

NS_ASSUME_NONNULL_END

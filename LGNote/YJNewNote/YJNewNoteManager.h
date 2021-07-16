//
//  YJNewNoteManager.h
//  YJNewNote_Example
//
//  Created by 刘亚军 on 2020/4/9.
//  Copyright © 2020 lyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#define IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]))
#define LG_ScreenWidth      [UIScreen mainScreen].bounds.size.width
#define LG_ScreenHeight     [UIScreen mainScreen].bounds.size.height
typedef NS_ENUM(NSInteger , YJNewNoteType){
    YJNewNoteTypeKlg,
    YJNewNoteTypeText
};
@interface YJNewNoteManager : NSObject
@property (nonatomic, weak) UIViewController *ownController;

@property (nonatomic,copy) NSString *NoteApi;
@property (nonatomic,assign) YJNewNoteType newNoteType;

@property (nonatomic,copy) NSString *UserID;
@property (nonatomic,copy) NSString *UserName;
@property (nonatomic,assign) NSInteger UserType;
@property (nonatomic,copy) NSString *Token;
@property (nonatomic,copy) NSString *SchoolID;
/** 笔记标题 */
@property (nonatomic,copy) NSString *NoteTitle;
@property (nonatomic,copy) NSString *NoteContent;

/** 笔记来源 */
@property (nonatomic,copy) NSString *ReSourceName;
@property (nonatomic,copy) NSString *ResourceID;
@property (nonatomic,copy) NSString *SystemID;
@property (nonatomic,copy) NSString *SystemName;

@property (nonatomic,copy) NSString *MaterialName;
@property (nonatomic,copy) NSString *MaterialID;

@property (nonatomic,copy) NSString *SubjectID;
@property (nonatomic,copy) NSString *SubjectName;


/** 英式音标 */
@property (nonatomic,copy) NSString *UN_phonetic;
/** 英式音标音频路径 */
@property (nonatomic,copy) NSString *UN_voice;
/** 美式音标 */
@property (nonatomic,copy) NSString *US_phonetic;
/** 美式音标音频路径 */
@property (nonatomic,copy) NSString *US_voice;
/** 释义 */
@property (nonatomic,copy) NSAttributedString *ExplainAttr;

+ (YJNewNoteManager *)defaultManager;
- (NSBundle *)noteBundle;

- (void)showNewNoteViewOn:(UIView *)view;
@end

NS_ASSUME_NONNULL_END

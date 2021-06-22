//
//  YJNewNoteTextView.h
//  LGAlertHUD
//
//  Created by 刘亚军 on 2020/4/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *YJNewNoteTextViewWillDidBeginEditingNotification = @"YJNewNoteTextViewWillDidBeginEditingNotification";
static NSString *YJNewNoteTextViewWillDidEndEditingNotification = @"YJNewNoteTextViewWillDidEndEditingNotification";
static NSString *YJNewNoteTextViewWillDidBeginEditingCursorNotification = @"YJNewNoteTextViewWillDidBeginEditingCursorNotification";

@class YJNewNoteTextView;
@protocol YJNewNoteTextViewDelegate <NSObject>
@optional
- (BOOL)yj_textViewShouldReturn:(nullable YJNewNoteTextView *)textView;
- (BOOL)yj_textViewShouldBeginEditing:(nullable YJNewNoteTextView *)textView;
- (BOOL)yj_textViewShouldEndEditing:(nullable YJNewNoteTextView *)textView;

- (void)yj_textViewDidBeginEditing:(nullable YJNewNoteTextView *)textView;
- (void)yj_textViewDidEndEditing:(nullable YJNewNoteTextView *)textView;

- (BOOL)yj_textView:(nullable YJNewNoteTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(nullable NSString *)text;
- (void)yj_textViewDidChange:(nullable YJNewNoteTextView *)textView;

@end
@interface YJNewNoteTextView : UITextView
@property(nonatomic,copy) NSString  *placeholder;
@property (nonatomic,assign) CGPoint placeholdOrigin;
@property (nonatomic,assign) NSInteger maxLength;
@property (nonatomic,weak) id<YJNewNoteTextViewDelegate> yjDelegate;

/** 获取键盘高度 */
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL isOffset;
@property (nonatomic, assign) CGFloat assistHeight;
- (void)setAutoCursorPosition: (BOOL)autoCursorPosition;
- (void)setAutoAdjust:(BOOL)autoAdjust;
@end

NS_ASSUME_NONNULL_END

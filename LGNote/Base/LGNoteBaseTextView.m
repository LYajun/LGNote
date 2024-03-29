//
//  LGBaseTextView.m
//  LGAssistanter
//
//  Created by hend on 2018/5/22.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "LGNoteBaseTextView.h"
#import <objc/runtime.h>
#import "NSString+NotesEmoji.h"
#import "NSBundle+Notes.h"
#import "LGNSingleTool.h"
/** 辅助工具上功能类型 */
typedef NS_ENUM(NSInteger ,LGToolBarFuntionType){
    LGToolBarFuntionTypeClear,
    LGToolBarFuntionTypeCamera,
    LGToolBarFuntionTypePhoto,
    LGToolBarFuntionTypeDrawBoard,
    LGToolBarFuntionTypeDone
};


NSString  *const LGTextViewKeyBoardDidShowNotification    = @"LGTextViewKeyBoardDidShowNotification";
NSString  *const LGTextViewKeyBoardWillHiddenNotification = @"LGTextViewKeyBoardWillHiddenNotification";

static const void *LGTextViewInputTextTypeKey         = &LGTextViewInputTextTypeKey;
static const void *LGTextViewToolBarStyleKey          = &LGTextViewToolBarStyleKey;

@interface LGNoteBaseTextView ()<UITextViewDelegate>

@end

@implementation LGNoteBaseTextView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        [self registerNotification];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
        [self registerNotification];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.inputAccessoryView = self.toolBar;
}

- (void)commonInit{
    _toolBarHeight = 44;
    self.delegate = self;
    
 //   [self createMenu];
}

-(void)createMenu{
    UIMenuItem * mean = [[UIMenuItem alloc]initWithTitle:@"复制" action:@selector(ccopyContent:)];
    UIMenuController * meanVC = [UIMenuController sharedMenuController];
    
    [meanVC setMenuItems:@[mean]];
    [meanVC setTargetRect:self.frame inView:self.superview];
    [meanVC setMenuVisible:YES animated:YES];
    
}

- (void)ccopyContent:(UIMenuItem*) itenm{
    
   // NSLog(@"==%@==", [self.text substringWithRange:self.selectedRange]);
    
    //NSLog(@"%zd==%zd",self.selectedRange.location,self.selectedRange.length);
    
    NSLog(@"%@",[LGNSingleTool sharedInstance].Notcontent);
    
    
       NSLog(@"==%@==", [[LGNSingleTool sharedInstance].Notcontent substringWithRange:self.selectedRange]);
    
    
    
   //存下当前text的attributedText
    [LGNSingleTool sharedInstance].attributedString = self.attributedText;
    //通过selectedRange取attributedText中的选中内容
    
    NSLog(@"%@",self.attributedText);
    
    
    //粘贴的时候  q取选中内容通过当前的光标位置selectedRange.location插入内容中
    
    
}



- (void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidDisAppear:) name:UIKeyboardWillHideNotification object:nil];
}


- (id <UITextViewDelegate>)delegate{
    return [super delegate];
}
//重写返回光标frame的方法避免光标扩大问题
- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect originalRect = [super caretRectForPosition:position];
    
    originalRect.size.height = self.font.lineHeight + 2;
    originalRect.size.width = 3;
    
    return originalRect;
}
#pragma mark - ToolBarItemEvent
- (void)toolBarEvent:(UIBarButtonItem *)sender{
    switch (sender.tag) {
            case LGToolBarFuntionTypeClear:{
//                self.text = @"";
//                if (self.delegate &&
//                    [self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
//                    [self.delegate textViewDidChange:self];
//                }
                
                if (self.lgDelegate && [self.lgDelegate respondsToSelector:@selector(lg_textViewClear:)]) {
                    [self.lgDelegate lg_textViewClear:self];
                }
            }
            break;
            case LGToolBarFuntionTypeCamera:{
                if (self.lgDelegate && [self.lgDelegate respondsToSelector:@selector(lg_textViewCameraEvent:)]) {
                    [self.lgDelegate lg_textViewCameraEvent:self];
                }
            }
            break;
            case LGToolBarFuntionTypePhoto:{
                if (self.lgDelegate && [self.lgDelegate respondsToSelector:@selector(lg_textViewPhotoEvent:)]) {
                    [self.lgDelegate lg_textViewPhotoEvent:self];
                }
            }
            break;
            case LGToolBarFuntionTypeDrawBoard:{
                if (self.lgDelegate && [self.lgDelegate respondsToSelector:@selector(lg_textViewDrawBoardEvent:)]) {
                    [self.lgDelegate lg_textViewDrawBoardEvent:self];
                }
            }
            break;
            case LGToolBarFuntionTypeDone:{
                [self resignFirstResponder];
            }
            break;
        default:
            break;
    }
}


#pragma mark UITextViewDelegate

- (BOOL)canBecomeFirstResponder{

    if (self.lgDelegate && [self.lgDelegate respondsToSelector:@selector(lg_textViewShouldBeginEditing:)]) {
        return [self.lgDelegate lg_textViewShouldBeginEditing:self];
    }
    
    return YES;

}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if (action ==@selector(copy:)){
        
        return YES;
        
    }
    
    else if (action ==@selector(paste:)){
        
        return YES;
        
    }
    
    else if (action ==@selector(cut:)){
        
        return NO;
        
    }
    
    else if(action ==@selector(select:)){
        
        return NO;
        
    }
    
    else if (action ==@selector(delete:)){
        
        return NO;
        
    }
    
    return NO;
    
}
//
//-(void)paste:(id)sender
//
//{
//    
//    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
//
//    NSLog(@"pboard.string : %@",pboard.string);
//     NSLog(@"pboard.items : %@",pboard.items);
//     NSLog(@"pboard.image : %@",pboard.image);
//  
//    
//    NSLog(@"粘贴了");
//    
//}

//-(void)copy:(id)sender
//
//{
//    
//    NSLog(@"复制了");
//  
////    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
////
////    pboard.string = self.text;

//    
//}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    //如果用户点击了return/ 输入为空
    if([text isEqualToString:@"\n"] || text.length == 0){
        return YES;
    }

    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        //如果有高亮且当前字数开始位置小于最大限制时允许输入
        if (offsetRange.location <= self.maxLength) {
            if (self.lgDelegate && [self.lgDelegate respondsToSelector:@selector(lg_textViewDidChange:)]) {
                [self.lgDelegate lg_textViewDidChange:self];
            }
            return [self isContainEmojiInRange:range replacementText:text];
        } else {
            return NO;
        }
    } else {
        return [self isContainEmojiInRange:range replacementText:text];
    }
}

- (BOOL)isContainEmojiInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *emojis = @"➋➌➍➎➏➐➑➒";
    if ([emojis containsString:text]) {
        return YES;
    }
    switch (self.inputType) {
            case LGTextViewKeyBoardTypeDefault:
            return [self limitTypeDefaultInRange:range replacementText:text];
            break;
            case LGTextViewKeyBoardTypeNumber:
            return [self limitTypeNumberInRange:range replacementText:text];
            break;
            case LGTextViewKeyBoardTypeDecimal:
            return [self limitTypeDecimalInRange:range replacementText:text];
            break;
            case LGTextViewKeyBoardTypeCharacter:
            return [self limitTypeCharacterInRange:range replacementText:text];
            break;
            case LGTextViewKeyBoardTypeEmojiLimit:
            return [self limitTypeEmojiInRange:range replacementText:text];
            break;
        default:
            break;
    }
}


- (void)textViewDidChangeSelection:(UITextView *)textView{
    //获取光标位置
    _cursorPosition = textView.selectedRange.location;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (self.lgDelegate && [self.lgDelegate respondsToSelector:@selector(lg_textViewDidBeginEditing:)]) {
        [self.lgDelegate lg_textViewDidBeginEditing:self];
    }
}






- (void)textViewDidEndEditing:(UITextView *)textView{
    if (self.lgDelegate && [self.lgDelegate respondsToSelector:@selector(lg_textViewDidEndEditing:)]) {
        [self.lgDelegate lg_textViewDidEndEditing:self];
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    if (self.lgDelegate && [self.lgDelegate respondsToSelector:@selector(lg_textViewDidChange:)]) {
        [self.lgDelegate lg_textViewDidChange:self];
    }
}




- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{

    
    if (self.lgDelegate && [self.lgDelegate respondsToSelector:@selector(lg_textViewShouldInteractWithTextAttachment:)]) {
       return [self.lgDelegate lg_textViewShouldInteractWithTextAttachment:self];
    }
    return NO;
}

#pragma mark LimitAction
- (BOOL)limitTypeDefaultInRange:(NSRange)range replacementText:(NSString *)text{
    if ([self exceedLimitLengthInRange:range replacementText:text]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)limitTypeNumberInRange:(NSRange)range replacementText:(NSString *)text{
    if ([self exceedLimitLengthInRange:range replacementText:text]) {
        return NO;
    } else {
        if ([self predicateMatchWithText:text matchFormat:@"^\\d$"]) {
            return YES;
        }
        return NO;
    }
}

- (BOOL)limitTypeDecimalInRange:(NSRange)range replacementText:(NSString *)text{
    if ([self exceedLimitLengthInRange:range replacementText:text]) {
        return NO;
    } else {
        if ([self predicateMatchWithText:text matchFormat:@"^[0-9.]$"]) {
            return YES;
        }
        return NO;
    }
}

- (BOOL)limitTypeCharacterInRange:(NSRange)range replacementText:(NSString *)text{
    if ([self exceedLimitLengthInRange:range replacementText:text]) {
        return NO;
    } else {
        if ([self predicateMatchWithText:text matchFormat:@"^[^[\\u4e00-\\u9fa5]]$"]) {
            return YES;
        }
        return NO;
    }
}

- (BOOL)limitTypeEmojiInRange:(NSRange)range replacementText:(NSString *)text{
    if ([self exceedLimitLengthInRange:range replacementText:text]) {
        return NO;
    } else {
        if (![text emo_containsEmoji]) {
            return YES;
        }
        return NO;
    }
}


- (BOOL)exceedLimitLengthInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *str = [NSString stringWithFormat:@"%@%@", self.text, text];
    // 这里不能等于，否则会越界
    if (str.length > self.maxLength){
        NSRange rangeIndex = [str rangeOfComposedCharacterSequenceAtIndex:self.maxLength];
        if (rangeIndex.length == 1){//字数超限
            self.text = [str substringToIndex:self.maxLength];
            if (self.lgDelegate && [self.lgDelegate respondsToSelector:@selector(lg_textViewDidChange:)]) {
                [self.lgDelegate lg_textViewDidChange:self];
            }
        } else {
            NSRange rangeRange = [str rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, self.maxLength)];
            self.text = [str substringWithRange:rangeRange];
        }
        return YES;
    }
    return NO;
}


- (NSString *)filterStringWithText:(NSString *) text matchFormat:(NSString *) matchFormat{
    NSMutableString * modifyString = text.mutableCopy;
    for (NSInteger idx = 0; idx < modifyString.length;) {
        NSString * subString = [modifyString substringWithRange: NSMakeRange(idx, 1)];
        if ([self predicateMatchWithText:subString matchFormat:matchFormat]) {
            idx++;
        } else {
            [modifyString deleteCharactersInRange: NSMakeRange(idx, 1)];
        }
    }
    return modifyString;
}

- (BOOL)predicateMatchWithText:(NSString *) text matchFormat:(NSString *) matchFormat{
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", matchFormat];
    return [predicate evaluateWithObject:text];
}


#pragma mark - 通知：获取键盘高度
- (void)keyboardDidAppear:(NSNotification *)notification{
    
    _keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    if (self.isFirstResponder) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LGTextViewKeyBoardDidShowNotification object:nil];
    }
}

- (void)keyboardDidDisAppear:(NSNotification *)notification{
    _keyboardHeight = 0.f;
    [[NSNotificationCenter defaultCenter] postNotificationName:LGTextViewKeyBoardWillHiddenNotification object:nil];
}

#pragma mark - setter && getter
- (void)setInputType:(LGTextViewKeyBoardType)inputType{
    objc_setAssociatedObject(self, LGTextViewInputTextTypeKey, [NSString stringWithFormat:@"%ld",inputType], OBJC_ASSOCIATION_COPY_NONATOMIC);
    switch (inputType) {
            case LGTextViewKeyBoardTypeNumber:
            self.keyboardType = UIKeyboardTypeNumberPad;
            break;
        default:
            self.keyboardType = UIKeyboardTypeDefault;
            break;
    }
}

- (LGTextViewKeyBoardType)inputType{
    return [objc_getAssociatedObject(self, LGTextViewInputTextTypeKey) integerValue];
}

- (void)setToolBarStyle:(LGTextViewToolBarStyle)toolBarStyle{
    objc_setAssociatedObject(self, LGTextViewToolBarStyleKey, [NSString stringWithFormat:@"%ld",toolBarStyle], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (LGTextViewToolBarStyle)toolBarStyle{
    return [objc_getAssociatedObject(self, LGTextViewToolBarStyleKey) integerValue];
}

#pragma mark - lazy
- (UIToolbar *)toolBar{
    if (!_toolBar) {
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _toolBar = [[UIToolbar alloc]initWithFrame:(CGRect){0,0,width,_toolBarHeight}];
        _toolBar.barTintColor = [UIColor whiteColor];
        UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(toolBarEvent:)];
        clear.tag = LGToolBarFuntionTypeClear;
        
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
//        UIButton *phoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [phoBtn setImage:[NSBundle lg_imagePathName:@"note_pho_unselected"] forState:UIControlStateNormal];
//        [phoBtn addTarget:self action:@selector(toolBarEvent:) forControlEvents:UIControlEventTouchUpInside];
//        phoBtn.tag = LGToolBarFuntionTypePhoto;
//        UIBarButtonItem *photo = [[UIBarButtonItem alloc] initWithCustomView:phoBtn];
        
        UIBarButtonItem *photo = [[UIBarButtonItem alloc]initWithImage:[[NSBundle lg_imagePathName:@"note_pho_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(toolBarEvent:)];
        photo.tag = LGToolBarFuntionTypePhoto;
        
//        UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [cameraBtn setImage:[NSBundle lg_imagePathName:@"note_camera"] forState:UIControlStateNormal];
//        [cameraBtn addTarget:self action:@selector(toolBarEvent:) forControlEvents:UIControlEventTouchUpInside];
//        cameraBtn.tag = LGToolBarFuntionTypeCamera;
       // UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithCustomView:cameraBtn];
        
         UIBarButtonItem *camera = [[UIBarButtonItem alloc]initWithImage:[[NSBundle lg_imagePathName:@"note_camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(toolBarEvent:)];
         camera.tag = LGToolBarFuntionTypeCamera;
        
        
//        UIButton *drawBoardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [drawBoardBtn setImage:[NSBundle lg_imagePathName:@"note_draw"] forState:UIControlStateNormal];
//        [drawBoardBtn addTarget:self action:@selector(toolBarEvent:) forControlEvents:UIControlEventTouchUpInside];
//        drawBoardBtn.tag = LGToolBarFuntionTypeDrawBoard;
       // UIBarButtonItem *drawBoard = [[UIBarButtonItem alloc] initWithCustomView:drawBoardBtn];
        
        UIBarButtonItem *drawBoard = [[UIBarButtonItem alloc]initWithImage:[[NSBundle lg_imagePathName:@"note_draw"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(toolBarEvent:)];
    
        drawBoard.tag = LGToolBarFuntionTypeDrawBoard;
        
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"收起" style:UIBarButtonItemStyleDone target:self action:@selector(toolBarEvent:)];
        done.tag = LGToolBarFuntionTypeDone;
        switch (self.toolBarStyle) {
                case LGTextViewToolBarStyleDefault:{
                    [_toolBar setItems:@[clear,space,done]];
                }
                break;
                case LGTextViewToolBarStyleCameras:{
                    [_toolBar setItems:@[clear,space,camera,space,photo,space,done]];
                }
                break;
                case LGTextViewToolBarStyleDrawBoard:{
                    [_toolBar setItems:@[clear,space,camera,space,photo,space,drawBoard,space,done]];
                }
                break;
                case LGTextViewToolBarStyleNone:{
                    _toolBar.hidden = YES;
                    
                }
            default:
                break;
        }
    }
    return _toolBar;
}




@end

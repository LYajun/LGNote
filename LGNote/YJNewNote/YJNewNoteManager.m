//
//  YJNewNoteManager.m
//  YJNewNote_Example
//
//  Created by 刘亚军 on 2020/4/9.
//  Copyright © 2020 lyj. All rights reserved.
//

#import "YJNewNoteManager.h"
#import <YJExtensions/YJExtensions.h>
#import "YJNewNoteView.h"

@interface YJNewNoteManager ()
@property (nonatomic,strong) NSBundle *noteBundle;
@end

@implementation YJNewNoteManager
+ (YJNewNoteManager *)defaultManager{
    static YJNewNoteManager *macro = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       macro = [[YJNewNoteManager alloc]init];
        macro.noteBundle = [NSBundle yj_bundleWithCustomClass:NSClassFromString(@"YJNewNoteView") bundleName:@"YJNewNote"];
    });
    return macro;
}
- (NSString *)NoteTitle{
    if (_NoteTitle) {
        _NoteTitle = [_NoteTitle stringByReplacingOccurrencesOfString:@"▶︎" withString:@""];
    }
    if (_NoteTitle.length > 51) {
        return [_NoteTitle substringToIndex:51];
    }
    return _NoteTitle;
}
- (void)showNewNoteViewOn:(UIView *)view{
    [YJNewNoteView showNewNoteViewOn:view newNoteType:self.newNoteType];
}
@end

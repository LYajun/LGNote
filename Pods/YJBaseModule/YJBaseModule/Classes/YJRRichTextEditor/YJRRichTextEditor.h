//
//  YJRRichTextEditorViewController.h
//  YJRRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "YJRColorPickerViewController.h"
#import "YJRFontsViewController.h"
#import "YJRBarButtonItem.h"
/**
 *  The types of toolbar items that can be added
 */
static NSString * const YJRRichTextEditorToolbarBold = @"com.zedsaid.toolbaritem.bold";
static NSString * const YJRRichTextEditorToolbarItalic = @"com.zedsaid.toolbaritem.italic";
static NSString * const YJRRichTextEditorToolbarSubscript = @"com.zedsaid.toolbaritem.subscript";
static NSString * const YJRRichTextEditorToolbarSuperscript = @"com.zedsaid.toolbaritem.superscript";
static NSString * const YJRRichTextEditorToolbarStrikeThrough = @"com.zedsaid.toolbaritem.strikeThrough";
static NSString * const YJRRichTextEditorToolbarUnderline = @"com.zedsaid.toolbaritem.underline";
static NSString * const YJRRichTextEditorToolbarRemoveFormat = @"com.zedsaid.toolbaritem.removeFormat";
static NSString * const YJRRichTextEditorToolbarJustifyLeft = @"com.zedsaid.toolbaritem.justifyLeft";
static NSString * const YJRRichTextEditorToolbarJustifyCenter = @"com.zedsaid.toolbaritem.justifyCenter";
static NSString * const YJRRichTextEditorToolbarJustifyRight = @"com.zedsaid.toolbaritem.justifyRight";
static NSString * const YJRRichTextEditorToolbarJustifyFull = @"com.zedsaid.toolbaritem.justifyFull";
static NSString * const YJRRichTextEditorToolbarH1 = @"com.zedsaid.toolbaritem.h1";
static NSString * const YJRRichTextEditorToolbarH2 = @"com.zedsaid.toolbaritem.h2";
static NSString * const YJRRichTextEditorToolbarH3 = @"com.zedsaid.toolbaritem.h3";
static NSString * const YJRRichTextEditorToolbarH4 = @"com.zedsaid.toolbaritem.h4";
static NSString * const YJRRichTextEditorToolbarH5 = @"com.zedsaid.toolbaritem.h5";
static NSString * const YJRRichTextEditorToolbarH6 = @"com.zedsaid.toolbaritem.h6";
static NSString * const YJRRichTextEditorToolbarTextColor = @"com.zedsaid.toolbaritem.textColor";
static NSString * const YJRRichTextEditorToolbarBackgroundColor = @"com.zedsaid.toolbaritem.backgroundColor";
static NSString * const YJRRichTextEditorToolbarUnorderedList = @"com.zedsaid.toolbaritem.unorderedList";
static NSString * const YJRRichTextEditorToolbarOrderedList = @"com.zedsaid.toolbaritem.orderedList";
static NSString * const YJRRichTextEditorToolbarHorizontalRule = @"com.zedsaid.toolbaritem.horizontalRule";
static NSString * const YJRRichTextEditorToolbarIndent = @"com.zedsaid.toolbaritem.indent";
static NSString * const YJRRichTextEditorToolbarOutdent = @"com.zedsaid.toolbaritem.outdent";
static NSString * const YJRRichTextEditorToolbarInsertImage = @"com.zedsaid.toolbaritem.insertImage";
static NSString * const YJRRichTextEditorToolbarInsertImageFromDevice = @"com.zedsaid.toolbaritem.insertImageFromDevice";
static NSString * const YJRRichTextEditorToolbarInsertLink = @"com.zedsaid.toolbaritem.insertLink";
static NSString * const YJRRichTextEditorToolbarRemoveLink = @"com.zedsaid.toolbaritem.removeLink";
static NSString * const YJRRichTextEditorToolbarQuickLink = @"com.zedsaid.toolbaritem.quickLink";
static NSString * const YJRRichTextEditorToolbarUndo = @"com.zedsaid.toolbaritem.undo";
static NSString * const YJRRichTextEditorToolbarRedo = @"com.zedsaid.toolbaritem.redo";
static NSString * const YJRRichTextEditorToolbarViewSource = @"com.zedsaid.toolbaritem.viewSource";
static NSString * const YJRRichTextEditorToolbarParagraph = @"com.zedsaid.toolbaritem.paragraph";
static NSString * const YJRRichTextEditorToolbarAll = @"com.zedsaid.toolbaritem.all";
static NSString * const YJRRichTextEditorToolbarNone = @"com.zedsaid.toolbaritem.none";
static NSString * const YJRRichTextEditorToolbarFonts = @"com.zedsaid.toolbaritem.fonts";

// source string for parsing JSON
static NSString * const YJREditorHTML = @"zss_editor.getHTML();";
static NSString * const YJREditorText = @"zss_editor.getText();";
static NSString * const YJREditorContent = @"document.activeElement.id=='zss_editor_content'";

/**
 *  The viewController used with YJRRichTextEditor
 */
@interface YJRRichTextEditor : UIViewController <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, YJRColorPickerViewControllerDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,YJRFontsViewControllerDelegate>


/**
 *  The base URL to use for the webView
 */
@property (nonatomic, strong) NSURL *baseURL;

/**
 *  If the HTML should be formatted to be pretty
 */
@property (nonatomic) BOOL formatHTML;

/**
 *  If the keyboard should be shown when the editor loads
 */
@property (nonatomic) BOOL shouldShowKeyboard;

/**
 * If the toolbar should always be shown or not
 */
@property (nonatomic) BOOL alwaysShowToolbar;

/**
 * If the sub class recieves text did change events or not
 */
@property (nonatomic) BOOL receiveEditorDidChangeEvents;

/**
 *  The placeholder text to use if there is no editor content
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 *  Toolbar items to include
 */
@property (nonatomic, strong) NSArray *enabledToolbarItems;

/**
 *  Color to tint the toolbar items
 */
@property (nonatomic, strong) UIColor *toolbarItemTintColor;

/**
 *  Color to tint selected items
 */
@property (nonatomic, strong) UIColor *toolbarItemSelectedTintColor;

/**
 *  Sets the HTML for the entire editor
 *
 *  @param html  HTML string to set for the editor
 *
 */
- (void)setHTML:(NSString *)html;

/**
 *  Returns the HTML from the Rich Text Editor
 *
 */
- (void)getHTML:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;

/**
 *  Returns the plain text from the Rich Text Editor
 *
 */
- (void)getText:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;

/**
 *  Inserts HTML at the caret position
 *
 *  @param html  HTML string to insert
 *
 */
- (void)insertHTML:(NSString *)html;

/**
 *  Manually focuses on the text editor
 */
- (void)focusTextEditor;

/**
 *  Manually dismisses on the text editor
 */
- (void)blurTextEditor;

/**
 *  Shows the insert image dialog with optinal inputs
 *
 *  @param url The URL for the image
 *  @param alt The alt for the image
 */
- (void)showInsertImageDialogWithLink:(NSString *)url alt:(NSString *)alt;

/**
 *  Inserts an image
 *
 *  @param url The URL for the image
 *  @param alt The alt attribute for the image
 */
- (void)insertImage:(NSString *)url alt:(NSString *)alt;

/**
 *  Shows the insert link dialog with optional inputs
 *
 *  @param url   The URL for the link
 *  @param title The tile for the link
 */
- (void)showInsertLinkDialogWithLink:(NSString *)url title:(NSString *)title;

/**
 *  Inserts a link
 *
 *  @param url The URL for the link
 *  @param title The title for the link
 */
- (void)insertLink:(NSString *)url title:(NSString *)title;

/**
 *  Gets called when the insert URL picker button is tapped in an alertView
 *
 *  @warning The default implementation of this method is blank and does nothing
 */
- (void)showInsertURLAlternatePicker;

/**
 *  Gets called when the insert Image picker button is tapped in an alertView
 *
 *  @warning The default implementation of this method is blank and does nothing
 */
- (void)showInsertImageAlternatePicker;

/**
 *  Dismisses the current AlertView
 */
- (void)dismissAlertView;

/**
 *  Add a custom UIBarButtonItem by using a UIButton
 */
- (void)addCustomToolbarItemWithButton:(UIButton*)button;

/**
 *  Add a custom YJRBarButtonItem
 */
- (void)addCustomToolbarItem:(YJRBarButtonItem *)item;

/**
 *  Scroll event callback with position
 */
- (void)editorDidScrollWithPosition:(NSInteger)position;

/**
 *  Text change callback with text and html
 */
- (void)editorDidChangeWithText:(NSString *)text andHTML:(NSString *)html;

/**
 *  Hashtag callback with word
 */
- (void)hashtagRecognizedWithWord:(NSString *)word;

/**
 *  Mention callback with word
 */
- (void)mentionRecognizedWithWord:(NSString *)word;

/**
 *  Set custom css
 */
- (void)setCSS:(NSString *)css;

@end

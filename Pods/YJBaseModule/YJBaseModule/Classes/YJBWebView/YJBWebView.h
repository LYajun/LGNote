//
//  YJBWebView.h
//  YJBaseModule
//
//  Created by 刘亚军 on 2019/9/11.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const YJWebViewEnglishToChineseNotifiaction;
UIKIT_EXTERN NSString *const YJWebViewChineseToEnglishNotifiaction;
UIKIT_EXTERN NSString *const YJWebViewDictionaryNotifiaction;


/** 以下需要配套使用
 addScriptMessageHandler
 removeScriptMessageHandlerForName
 */
// WKWebView 内存不释放的问题解决
@interface YJBWeakWebViewScriptMessageDelegate : NSObject<WKScriptMessageHandler>

//WKScriptMessageHandler 这个协议类专门用来处理JavaScript调用原生OC的方法
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end


@protocol YJBWeakWebMenuDelegate <NSObject>

@optional
- (void)webView:(WKWebView *)webView didSelectNoteContent:(NSString *)noteContent;
@end

@interface YJBWebView : WKWebView
@property (nonatomic,assign) BOOL translateDisable;
@property (nonatomic,assign) BOOL noteEnable;
@property (nonatomic, assign) id<YJBWeakWebMenuDelegate> menuDelegate;
- (void)showNavigationBarAtDidFinishNavigation;

- (void)yj_loadHTMLUrlString:(NSString *)urlString baseURL:(nullable NSURL *)baseURL;
- (void)yj_loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;
- (void)yj_loadRequestWithUrlString:(NSString *)string;

+ (NSArray *)yj_voiceAllFileExtension;
+ (NSArray *)yj_imageAllFileExtension;

+ (BOOL)yj_isVoiceFileWithExtName:(NSString *)extName;
+ (BOOL)yj_isImgFileWithExtName:(NSString *)extName;


+ (NSString *)yj_imgClickJSSrcPrefix;
/** 文字自适应 */
+ (NSString *)yj_autoFitTextSizeJSString;
/** 图片只适应 */
+ (NSString *)yj_autoFitImgSizeJSString;
/** 表格自适应+禁止交互 */
+ (NSString *)yj_autoFitTableSizeJSString;
- (void)yj_adjustTestSizeWithSizeRate:(nullable NSString *)rate;

- (void)yj_injectImgClickJS;

- (void)yj_getImagesWithCompletionHandler:(void (^) (NSArray *_Nullable imgArr))completionHandler;
@end

NS_ASSUME_NONNULL_END

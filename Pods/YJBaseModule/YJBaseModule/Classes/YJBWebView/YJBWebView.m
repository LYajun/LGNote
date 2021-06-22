//
//  YJBWebView.m
//  YJBaseModule
//
//  Created by 刘亚军 on 2019/9/11.
//

#import "YJBWebView.h"
#import <YJExtensions/YJExtensions.h>
#import "YJBHpple.h"
#import "YJBWebNavigationView.h"
#import <Masonry/Masonry.h>
#import "YJBManager.h"


NSString *const YJWebViewEnglishToChineseNotifiaction = @"YJWebViewEnglishToChineseNotifiaction";
NSString *const YJWebViewChineseToEnglishNotifiaction = @"YJWebViewChineseToEnglishNotifiaction";
NSString *const YJWebViewDictionaryNotifiaction = @"YJWebViewDictionaryNotifiaction";

@implementation YJBWeakWebViewScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler
//遵循WKScriptMessageHandler协议，必须实现如下方法，然后把方法向外传递
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}
@end

@interface YJBWebView ()
@property (nonatomic,assign) BOOL isAddImgOnClick;
@property (nonatomic,strong) YJBWebNavigationView *navigationView;
@end
@implementation YJBWebView
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration{
    if (self = [super initWithFrame:frame configuration:configuration]) {
        [self addSubview:self.navigationView];
        [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.centerX.top.equalTo(self);
            make.height.mas_equalTo(40);
        }];
        self.navigationView.hidden = YES;
         [self createMenu];
    }
    return self;
}
- (void)createMenu{
//    [self becomeFirstResponder];
    UIMenuController *popMenu = [UIMenuController sharedMenuController];
    
    UIMenuItem *englishToChinese = [[UIMenuItem alloc] initWithTitle:@"英译中" action:@selector(englishToChinese:)];
    
    UIMenuItem *chineseToEnglish = [[UIMenuItem alloc] initWithTitle:@"中译英" action:@selector(chineseToEnglish:)];
    
     UIMenuItem *note = [[UIMenuItem alloc] initWithTitle:@"笔记" action:@selector(newNote:)];
    
//    UIMenuItem *dictionary = [[UIMenuItem alloc] initWithTitle:@"词典" action:@selector(dictionary:)];
    
    [popMenu setMenuItems:@[englishToChinese,chineseToEnglish,note]];
    [popMenu setArrowDirection:UIMenuControllerArrowDown];
    [popMenu setTargetRect:self.frame inView:self.superview];
    [popMenu setMenuVisible:YES animated:YES];
    
}

- (void)englishToChinese:(UIMenuController *)menu{
    [self evaluateJavaScript:@"window.getSelection().toString()" completionHandler:^(id _Nullable result,NSError * _Nullable error){
        NSString *str = @"";
        if (result && [result isKindOfClass:NSString.class] && [(NSString *)result length] > 0) {
            str = result;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:YJWebViewEnglishToChineseNotifiaction object:nil userInfo:@{@"result":str}];
      }];
}
- (void)chineseToEnglish:(UIMenuController *)menu{
    [self evaluateJavaScript:@"window.getSelection().toString()" completionHandler:^(id _Nullable result,NSError * _Nullable error){
          NSString *str = @"";
                if (result && [result isKindOfClass:NSString.class] && [(NSString *)result length] > 0) {
                    str = result;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:YJWebViewChineseToEnglishNotifiaction object:nil userInfo:@{@"result":str}];
    }];
}
- (void)newNote:(UIMenuController *)menu{
    __weak typeof(self) weakSelf = self;
    [self evaluateJavaScript:@"window.getSelection().toString()" completionHandler:^(id _Nullable result,NSError * _Nullable error){
             NSString *str = @"";
               if (result && [result isKindOfClass:NSString.class] && [(NSString *)result length] > 0) {
                   str = result;
               }
            if (weakSelf.menuDelegate && [weakSelf.menuDelegate respondsToSelector:@selector(webView:didSelectNoteContent:)]) {
                [weakSelf.menuDelegate webView:weakSelf didSelectNoteContent:str];
            }
       }];
}
- (void)dictionary:(UIMenuController *)menu{
    [self evaluateJavaScript:@"window.getSelection().toString()" completionHandler:^(id _Nullable result,NSError * _Nullable error){
          NSString *str = @"";
                if (result && [result isKindOfClass:NSString.class] && [(NSString *)result length] > 0) {
                    str = result;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:YJWebViewDictionaryNotifiaction object:nil userInfo:@{@"result":str}];
    }];
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{

    if (action == @selector(copy:) ||
        action == @selector(_lookup:)){
        return YES;
    }
    
   if (action == @selector(englishToChinese:) ||
       action == @selector(chineseToEnglish:)) {
       return !self.translateDisable;
   }
    if (action == @selector(newNote:)) {
        return self.noteEnable;
    }
    return NO;
}
- (void)yj_loadHTMLUrlString:(NSString *)urlString baseURL:(NSURL *)baseURL{
    self.isAddImgOnClick = NO;
    NSString *ext = [urlString.lowercaseString componentsSeparatedByString:@"."].lastObject;
    if ([ext containsString:@"ppt"] || [ext containsString:@"pdf"]) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
       request.timeoutInterval = 30;
       [self loadRequest:request];
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        
        NSStringEncoding * usedEncoding = nil;
        //带编码头的如 utf-8等 这里会识别
        NSString *body = [NSString stringWithContentsOfURL:url usedEncoding:usedEncoding error:nil];
        if (!body){
            //如果之前不能解码，现在使用GBK解码
            NSLog(@"GBK");
            body = [NSString stringWithContentsOfURL:url encoding:0x80000632 error:nil];
        }
        if (!body) {
            //再使用GB18030解码
            NSLog(@"GBK18030");
            body = [NSString stringWithContentsOfURL:url encoding:0x80000631 error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (body) {
                [weakSelf yj_loadHTMLString:body baseURL:baseURL];
            }else {
                NSLog(@"没有合适的编码");
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                request.timeoutInterval = 30;
                [weakSelf loadRequest:request];
            }
        });
    });
}
- (void)yj_loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL{
    self.isAddImgOnClick = YES;
    [self loadHTMLString:[self modifyImgSrc:string] baseURL:baseURL];
}
- (void)yj_loadRequestWithUrlString:(NSString *)string{
    self.isAddImgOnClick = NO;
    NSURL *url = [NSURL URLWithString:[string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 15;
    [self loadRequest:request];
}
- (NSString *)modifyImgSrc:(NSString *)htmlStr{
    __block NSString *html = htmlStr.copy;
    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    // 解析html数据
    YJBHpple *xpathParser = [[YJBHpple alloc] initWithHTMLData:htmlData];
    // 根据标签来进行过滤
    NSArray *imgArray = [xpathParser searchWithXPathQuery:@"//img"];
    if (imgArray && imgArray.count > 0) {
        NSMutableArray *srcResplaceArr = [NSMutableArray array];
        [imgArray enumerateObjectsUsingBlock:^(YJBHppleElement *hppleElement, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *attributes = hppleElement.attributes;
            NSString *imgSrc = [attributes objectForKey:@"src"];
            NSString *classStr = [attributes objectForKey:@"class"];
            BOOL isAddOnclick = YES;
            if (classStr && classStr.length > 0 && ([classStr.lowercaseString containsString:@"yaoshi"] || [classStr.lowercaseString containsString:@"audioimg"] || [classStr.lowercaseString containsString:@"videoimg"] || [classStr.lowercaseString containsString:@"orallanguageimg"])) {
                isAddOnclick = NO;
            }
            if (imgSrc && imgSrc.length > 0 && isAddOnclick && ![srcResplaceArr containsObject:imgSrc]) {
                [srcResplaceArr addObject:imgSrc];
                if ([attributes.allKeys containsObject:@"onclick"]) {
                    NSString *onclick = [NSString stringWithFormat:@"onclick=\"%@\"",[attributes objectForKey:@"onclick"]];
                    NSString *audiourl = imgSrc;
                    if ([attributes.allKeys containsObject:@"audiourl"]) {
                        audiourl = [attributes objectForKey:@"audiourl"];
                    }
                    NSString *onclickReplace = [NSString stringWithFormat:@"onclick=\"yjClickAction('%@')\"",[audiourl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"]];
                    html = [html stringByReplacingOccurrencesOfString:onclick withString:onclickReplace];
                }else{
                    NSString *onclick = [NSString stringWithFormat:@"src=\"%@\"",imgSrc];
                    if (![html containsString:onclick]) {
                        onclick = [NSString stringWithFormat:@"src='%@'",imgSrc];
                        if (![html containsString:onclick]) {
                            onclick = [NSString stringWithFormat:@"src = '%@'",imgSrc];
                        }
                    }
                    NSString *onclickReplace = [NSString stringWithFormat:@"%@ onclick=\"yjClickAction('%@')\"",onclick,[imgSrc stringByReplacingOccurrencesOfString:@"\\" withString:@"/"]];
                    html = [html stringByReplacingOccurrencesOfString:onclick withString:onclickReplace];
                }
            }
        }];
    }
    return html;
}

+ (NSArray *)yj_voiceAllFileExtension{
    return @[@"wav",@"mp3",@"pcm",@"amr",@"aac",@"caf"];
}
+ (NSArray *)yj_imageAllFileExtension{
    return @[@"png",@"jpg",@"gif",@"jpeg",@"wmf",@"emf"];
}

+ (BOOL)yj_isVoiceFileWithExtName:(NSString *)extName{
    BOOL isContain = NO;
    for (NSString *str in self.yj_voiceAllFileExtension) {
        if ([extName.lowercaseString containsString:str]) {
            isContain = YES;
            break;
        }
    }
    return isContain;
}
+ (BOOL)yj_isImgFileWithExtName:(NSString *)extName{
    BOOL isContain = NO;
    for (NSString *str in self.yj_imageAllFileExtension) {
        if ([extName.lowercaseString containsString:str]) {
            isContain = YES;
            break;
        }
    }
    return isContain;
}


- (void)yj_adjustTestSizeWithSizeRate:(NSString *)rate{
    NSString *str = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%@'",rate];
    [self evaluateJavaScript:str completionHandler:^(id _Nullable  obj, NSError * _Nullable error) {
        if (error) {
            NSLog(@"字体设置失败:%@",error.localizedDescription);
        }
        
    }];
}
+ (NSString *)yj_imgClickJSSrcPrefix{
    return @"yjclickaction";
}
+ (NSString *)yj_autoFitTextSizeJSString{
    return @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width,initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);";
}
+ (NSString *)yj_autoFitImgSizeJSString{
//    return @"var imgs=document.getElementsByTagName('img');var maxwidth=document.body.clientWidth;var length=imgs.length;for(var i=0;i<length;i++){var img=imgs[i];if(img.width > maxwidth){img.style.width = '90%';img.style.height = 'auto';}}";
    return @"var imgs=document.getElementsByTagName('img');var maxwidth=document.body.clientWidth;var length=imgs.length;for(var i=0;i<length;i++){var img=imgs[i];if(img.width > maxwidth){img.style.width = '90%';img.style.height = 'auto';} if(img.style){img.style.display = 'inline-block';img.style.overflow = 'hidden';if (img.width > maxwidth*0.6){img.style.marginBottom = '10px';}}}";
}

+ (NSString *)yj_autoFitTableSizeJSString{
    return @"function compatTable(){var tableElements=document.getElementsByTagName(\"table\");for(var i=0;i<tableElements.length;i++){var tableElement=tableElements[i];tableElement.cellspacing=\"\";tableElement.cellpadding=\"\";tableElement.width = document.body.clientWidth;tableElement.border=\"\";tableElement.setAttribute(\"style\",\"border-collapse:collapse; display:table;\")}var tdElements=document.getElementsByTagName(\"td\");for(var i=0;i<tdElements.length;i++){var tdElement=tdElements[i];tdElement.valign=\"\";tdElement.width=\"\";tdElement.setAttribute(\"style\",\"border:1px solid black;\");tdElement.setAttribute(\"contenteditable\",\"false\")}};compatTable();";
}
- (void)yj_injectImgClickJS{
    // 禁止图片长按交互
    [self evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';"completionHandler:nil];
    
    // window.location.href='yjclickaction:'+this.src
    // alert('yjClickAction:'+ this.src)
    if (self.isAddImgOnClick) {
        [self evaluateJavaScript:@"function yjClickAction(url){alert('yjclickaction:'+ url)}" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error) {
                NSLog(@"yjClickAction 注入失败:%@",error.localizedDescription);
            }
        }];
        
    }else{
        //添加图片可点击JS
        [self evaluateJavaScript:@"function registerImageClickAction(){\
         var imgs=document.getElementsByTagName('img');\
         var length=imgs.length;\
         for(var i=0;i<length;i++){\
         img=imgs[i];\
         img.onclick=function(){alert('yjclickaction:'+ this.src)}\
         }\
         }" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
             if (error) {
                 NSLog(@"添加图片可点击JS 注入失败:%@",error.localizedDescription);
             }
         }];
        
        [self evaluateJavaScript:@"registerImageClickAction();"  completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error) {
                NSLog(@"registerImageClickAction 注入失败:%@",error.localizedDescription);
            }
        }];
    }
}

- (void)yj_getImagesWithCompletionHandler:(void (^)(NSArray * _Nullable))completionHandler{
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '***';\
    };\
    return imgScr;\
    };";
    
    [self evaluateJavaScript:jsGetImages completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"jsGetImages 注入失败:%@",error.localizedDescription);
        }
    }];//注入JS方法
    
    [self evaluateJavaScript:@"getImages()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSArray * urlArray = nil;
        if (!error) {
            urlArray = result ? [result componentsSeparatedByString:@"***"]:nil;
            NSLog(@"urlArray = %@",urlArray);
        }
        if (completionHandler) {
            completionHandler(urlArray);
        }
    }];
}

static float yjbContentInsetTop = -1;
- (void)showNavigationBarAtDidFinishNavigation{
    __weak typeof(self) weakSelf = self;
    [self evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (!error) {
            weakSelf.navigationView.titleStr = result;
        }
    }];
    BOOL showNavigationBar = self.canGoBack;
    self.navigationView.hidden = !showNavigationBar;
    if (yjbContentInsetTop < 0) {
        yjbContentInsetTop = self.scrollView.contentInset.top;
    }
    UIEdgeInsets currentInset = self.scrollView.contentInset;
    self.scrollView.contentInset = UIEdgeInsetsMake(showNavigationBar ? (yjbContentInsetTop > 40 ? yjbContentInsetTop : 40) : yjbContentInsetTop, currentInset.left, currentInset.bottom, currentInset.right);
}


- (YJBWebNavigationView *)navigationView{
    if (!_navigationView) {
        _navigationView = [[YJBWebNavigationView alloc] initWithFrame:CGRectZero];
        __weak typeof(self) weakSelf = self;
        _navigationView.backBlock = ^{
            [weakSelf goBack];
        };
    }
    return _navigationView;
}
@end

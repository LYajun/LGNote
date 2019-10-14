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
    }
    return self;
}

- (void)yj_loadHTMLUrlString:(NSString *)urlString baseURL:(NSURL *)baseURL{
    self.isAddImgOnClick = NO;
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
                request.timeoutInterval = 15;
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
        
        [imgArray enumerateObjectsUsingBlock:^(YJBHppleElement *hppleElement, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *attributes = hppleElement.attributes;
            NSString *imgSrc = [attributes objectForKey:@"src"];
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
                NSString *onclickReplace = [NSString stringWithFormat:@"%@ onclick=\"yjClickAction('%@')\"",onclick,[imgSrc stringByReplacingOccurrencesOfString:@"\\" withString:@"/"]];
                html = [html stringByReplacingOccurrencesOfString:onclick withString:onclickReplace];
            }
        }];
    }
    return html;
}

+ (NSArray *)yj_voiceAllFileExtension{
    return @[@"wav",@"mp3",@"pcm",@"amr",@"aac",@"caf"];
}
+ (NSArray *)yj_imageAllFileExtension{
    return @[@"png",@"jpg",@"gif",@"jpeg"];
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
    return @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
}
+ (NSString *)yj_autoFitImgSizeJSString{
    return @"var imgs=document.getElementsByTagName('img');var maxwidth=document.body.clientWidth;var length=imgs.length;for(var i=0;i<length;i++){var img=imgs[i];if(img.width > maxwidth){img.style.width = '90%';img.style.height = 'auto';}}";
}
+ (NSString *)yj_autoFitTableSizeJSString{
    return @"function compatTable(){var tableElements=document.getElementsByTagName(\"table\");for(var i=0;i<tableElements.length;i++){var tableElement=tableElements[i];tableElement.cellspacing=\"\";tableElement.cellpadding=\"\";tableElement.width = document.body.clientWidth;tableElement.border=\"\";tableElement.setAttribute(\"style\",\"border-collapse:collapse; display:table;\")}var tdElements=document.getElementsByTagName(\"td\");for(var i=0;i<tdElements.length;i++){var tdElement=tdElements[i];tdElement.valign=\"\";tdElement.width=\"\";tdElement.setAttribute(\"style\",\"border:1px solid black;\");tdElement.setAttribute(\"contenteditable\",\"false\")}};compatTable();";
}
- (void)yj_injectImgClickJS{
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
- (void)showNavigationBarAtDidFinishNavigation{{
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
}}


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

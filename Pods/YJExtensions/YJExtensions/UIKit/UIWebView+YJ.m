//
//  UIWebView+YJ.m
//  YJExtensionsDemo
//
//  Created by 刘亚军 on 2019/7/22.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "UIWebView+YJ.h"

@implementation UIWebView (YJ)
+ (NSArray *)voiceAllFileExtension{
    return @[@"wav",@"mp3",@"pcm",@"amr",@"aac",@"caf"];
}
+ (NSArray *)imageAllFileExtension{
    return @[@"png",@"jpg",@"gif"];
}

+ (BOOL)yj_isVoiceFileWithExtName:(NSString *)extName{
    BOOL isContain = NO;
    for (NSString *str in self.voiceAllFileExtension) {
        if ([extName.lowercaseString containsString:str]) {
            isContain = YES;
            break;
        }
    }
    return isContain;
}
+ (BOOL)yj_isImgFileWithExtName:(NSString *)extName{
    BOOL isContain = NO;
    for (NSString *str in self.imageAllFileExtension) {
        if ([extName.lowercaseString containsString:str]) {
            isContain = YES;
            break;
        }
    }
    return isContain;
}

- (void)yj_setTextSizeWithRate:(NSString *)rate{
    NSString *str = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%@'",rate];
    [self stringByEvaluatingJavaScriptFromString:str];
}
- (void)yj_addImgClickEvent{
    //这里是JS，主要目的: - 获取H5图片的url
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    };\
    return imgScr;\
    };";
    
    [self stringByEvaluatingJavaScriptFromString:jsGetImages];//注入JS方法

    //添加图片可点击JS
    [self stringByEvaluatingJavaScriptFromString:@"function registerImageClickAction(){\
     var imgs=document.getElementsByTagName('img');\
     var length=imgs.length;\
     for(var i=0;i<length;i++){\
     img=imgs[i];\
     img.onclick=function(){\
     window.location.href='image-preview:'+this.src}\
     }\
     }"];
    
    [self stringByEvaluatingJavaScriptFromString:@"registerImageClickAction();"];
}
- (NSString *)yj_getImages{
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    };\
    return imgScr;\
    };";
    
    [self stringByEvaluatingJavaScriptFromString:jsGetImages];

    return [self stringByEvaluatingJavaScriptFromString:@"getImages()"];
}
@end

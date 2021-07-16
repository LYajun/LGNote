//
//  YJNewNoteDataModel.m
//  YJNewNote_Example
//
//  Created by 刘亚军 on 2020/4/9.
//  Copyright © 2020 lyj. All rights reserved.
//

#import "YJNewNoteDataModel.h"
#import "YJNewNoteManager.h"
#import <MJExtension/MJExtension.h>
#import <YJExtensions/YJExtensions.h>
#import <YJBaseModule/YJBHpple.h>
#import <AFNetworking/AFNetworking.h>
#import <LGAlertHUD/LGAlertHUD.h>
#import "NSString+Notes.h"

static CGFloat const YJNewNoteImageOffset = 10.f;
@implementation YJNewNoteDataModel
+ (NSArray *)mj_ignoredPropertyNames{
    return @[@"hash",@"superclass",@"description",@"debugDescription",@"NoteContent_Att",@"imgaeUrls",@"mixTextImage",@"imageAllCont",@"imageInfo"];
}
- (instancetype)init{
    if (self = [super init]) {
        _UserID = [YJNewNoteManager defaultManager].UserID;
        _UserName = [YJNewNoteManager defaultManager].UserName;
        _UserType = [YJNewNoteManager defaultManager].UserType;
        _SchoolID = [YJNewNoteManager defaultManager].SchoolID;
        _NoteTitle = [YJNewNoteManager defaultManager].NoteTitle;
        _ResourceName = [YJNewNoteManager defaultManager].ReSourceName;
        _ResourceID = [YJNewNoteManager defaultManager].ResourceID;
        _SystemID = [YJNewNoteManager defaultManager].SystemID;
        _SystemName = [YJNewNoteManager defaultManager].SystemName;
        _SubjectID = [YJNewNoteManager defaultManager].SubjectID;
        _SubjectName = [YJNewNoteManager defaultManager].SubjectName;
        _MaterialName = [YJNewNoteManager defaultManager].MaterialName;
        _MaterialID = [YJNewNoteManager defaultManager].MaterialID;
        
        if ([YJNewNoteManager defaultManager].NoteContent && [YJNewNoteManager defaultManager].NoteContent.length > 0) {
            _NoteContent = [YJNewNoteManager defaultManager].NoteContent;
            _NoteContent_Att = [YJNewNoteManager defaultManager].NoteContent.lg_adjustImageHTMLFrame.lg_changeforMutableAtttrubiteString;
            [self saveImageInfoInAttr:_NoteContent_Att];
            [YJNewNoteManager defaultManager].NoteContent = @"";
        }
        
        _OperateFlag = 1;
        _IsKeyPoint = @"0";
        _MaterialIndex = -1;
    }
    return self;
}
NSString *YJNewNoteIsStrEmpty(NSString *string){
    if (string && string.length > 0) {
        return string;
    }
    return @"";
}
- (void)uploadNoteDataWithComplete:(void (^)(BOOL))complete{
    [self uploadNoteSourceWithComplete:complete];
}
- (void)uploadNoteSourceWithComplete:(void (^)(BOOL))complete{
    NSString *url = [[YJNewNoteManager defaultManager].NoteApi stringByAppendingString:@"/api/V2/Notes/UploadNoteSourceInfo"];
    NSDictionary *params = @{
                                @"SystemType":@"3",
                                @"ResourceID":YJNewNoteIsStrEmpty(self.ResourceID),
                                @"MaterialID":YJNewNoteIsStrEmpty(self.MaterialID),
                                @"ResourceName": YJNewNoteIsStrEmpty(self.ResourceName),
                                @"MaterialName":YJNewNoteIsStrEmpty(self.MaterialName),
                                @"ResourcePCLink":@"",
                                @"ResourceIOSLink":@"",
                                @"ResourceAndroidLink":@"",
                                @"MaterialURL":@"",
                                @"MaterialContent":@"",
                                @"MaterialTotal":@(-1)
    };
    
    NSMutableURLRequest *request = [self noteRequestWithUrlStr:url params:params];
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(NO);
                }
            });
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (dic && [[dic objectForKey:@"ErrorCode"] hasSuffix:@"00"]) {
                    [weakSelf uploadNoteInfoWithComplete:complete];
                }else{
                    if (complete) {
                        complete(NO);
                    }
                }
            });
        }
    }];
    [dataTask resume];
}
- (void)uploadNoteInfoWithComplete:(void (^)(BOOL))complete{
    NSString *url = [[YJNewNoteManager defaultManager].NoteApi stringByAppendingString:@"/api/V2/Notes/OperateNote"];
    NSDictionary *params = [self mj_JSONObject];
    
    NSMutableURLRequest *request = [self noteRequestWithUrlStr:url params:params];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(NO);
                }
            });
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (dic && [[dic objectForKey:@"ErrorCode"] hasSuffix:@"00"]) {
                     if (complete) {
                         complete(YES);
                     }
                }else{
                    if (complete) {
                        complete(NO);
                    }
                }
            });
        }
    }];
    [dataTask resume];
    
}
- (void)uploadNoteImg:(UIImage *)image complete:(void (^)(NSString * _Nullable))complete{
    NSString *url = [[YJNewNoteManager defaultManager].NoteApi stringByAppendingString:@"api/V2/Notes/UploadImg"];
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
   manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",@"application/x-www-form-urlencoded",nil];
    [LGAlert showBarDeterminateWithProgress:0];
    [manager POST:url parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
       NSData *uploadData = data;
       static NSDateFormatter *formatter = nil;
       static dispatch_once_t onceToken;
       dispatch_once(&onceToken, ^{
           formatter = [[NSDateFormatter alloc] init];
       });
       [formatter setDateFormat:@"yyyyMMddHHmmss"];
       NSString *dateString = [formatter stringFromDate:[NSDate date]];
       NSString *fileName = [NSString  stringWithFormat:@"照片_%@_%d.jpg", dateString , 0];
       [formData appendPartWithFileData:uploadData name:@"LGAssistanter_Uploadfile" fileName:fileName mimeType:@"image/png"];
   } progress:^(NSProgress * _Nonnull uploadProgress) {
       dispatch_async(dispatch_get_main_queue(), ^{
           [LGAlert showBarDeterminateWithProgress:uploadProgress.fractionCompleted];
       });
   } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       dispatch_async(dispatch_get_main_queue(), ^{
           NSArray *resultArr = [responseObject objectForKey:@"Result"];
           if (responseObject && [[responseObject objectForKey:@"ErrorCode"] hasSuffix:@"00"] && resultArr && resultArr.count > 0) {
               [LGAlert hide];
               NSArray *imgArr = resultArr;
               complete(imgArr.firstObject);
           }else{
               [LGAlert showImgSuccessWithStatus:@"上传失败"];
               complete(nil);
           }
       });
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       dispatch_async(dispatch_get_main_queue(), ^{
           complete(nil);
       });
   }];
}
- (NSMutableURLRequest *)noteRequestWithUrlStr:(NSString *)urlStr params:(NSDictionary *)params{
    NSURL *requestUrl = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    request.HTTPMethod = @"POST";
    
    NSString *totalDataStr = [NSString yj_encryptWithKey:self.UserID encryptDic:params];;
    NSString *md5String = [NSString stringWithFormat:@"%@%@%@",self.UserID,[YJNewNoteManager defaultManager].Token,totalDataStr];
    NSString *sign = [NSString yj_md5EncryptStr:md5String];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.allHTTPHeaderFields = @{
                                    @"platform":self.UserID,
                                    @"sign":sign,
                                    @"timestamp":[YJNewNoteManager defaultManager].Token
                                    };
    request.timeoutInterval = 30;
    request.HTTPBody = [totalDataStr dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}
- (NSMutableDictionary *)imageInfo{
    if (!_imageInfo) {
        _imageInfo = [NSMutableDictionary dictionary];
    }
    return _imageInfo;
}

- (void)saveImageInfoInAttr:(NSAttributedString *) attr{
    NSString *html = [self deleteBodyInAttr:attr];
    NSArray *textImgArr = [self imageArrayInHTML:self.NoteContent];
    NSArray *bodyImgArr = [self imageArrayInHTML:html];
    if (bodyImgArr && bodyImgArr.count > 0) {
        for (int i = 0; i < bodyImgArr.count; i++) {
            YJBHppleElement *textHppleElement = textImgArr[i];
            YJBHppleElement *bodyHppleElement = bodyImgArr[i];
            [self.imageInfo setObject:textHppleElement.attributes forKey:[bodyHppleElement.attributes objectForKey:@"src"]];
        }
    }
}
- (void)updateImageInfo:(NSDictionary *) imageInfo imageAttr:(NSAttributedString *) imageAttr{
    NSString *html = [self deleteBodyInAttr:imageAttr];
    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    YJBHpple *xpathParser = [[YJBHpple alloc] initWithHTMLData:htmlData];
    NSArray *imgArray = [xpathParser searchWithXPathQuery:@"//img"];
    if (imgArray && imgArray.count > 0) {
        YJBHppleElement *hppleElement = imgArray.firstObject;
        NSDictionary *attributes = hppleElement.attributes;
        NSString *src = [attributes objectForKey:@"src"];
        [self.imageInfo setObject:imageInfo forKey:src];
    }
}

// 图片
- (NSArray *)imageArrayInHTML:(NSString *)html{
    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    YJBHpple *tfh = [[YJBHpple alloc] initWithHTMLData:htmlData];
    NSArray *imageArray = [tfh searchWithXPathQuery:@"//img"];
    return imageArray;
}

- (NSString *)deleteBodyInAttr:(NSAttributedString *) attr{
    NSString *html = nil;
    if (attr && attr.length > 0) {
        
        NSDictionary *exportParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:[NSNumber numberWithInt:NSUTF8StringEncoding]};
        
        NSData *htmlData = [attr dataFromRange:NSMakeRange(0,attr.length) documentAttributes:exportParams error:nil];
        
        YJBHpple *xpathParser = [[YJBHpple alloc] initWithHTMLData:htmlData];
        NSArray *bodyArray = [xpathParser searchWithXPathQuery:@"//body"];
        if (bodyArray && bodyArray.count > 0) {
            YJBHppleElement *hppleElement = bodyArray.firstObject;
            html = hppleElement.raw;

            html = [html stringByReplacingOccurrencesOfString:@"<body>\n" withString:@""];
            html = [html stringByReplacingOccurrencesOfString:@"\n</body>" withString:@""];
           
           
            
            
        }
    }
    return html;
}

- (void)updateText:(NSAttributedString *)textAttr{
    NSString *html = [self deleteBodyInAttr:textAttr];
    NSArray *textImgArr = [self imageArrayInHTML:html];
    
     _imageAllCont = textImgArr.count;
    if (textImgArr && textImgArr.count > 0) {
        for (int i = 0; i < textImgArr.count; i++) {
            YJBHppleElement *hppleElement = textImgArr[i];
            NSDictionary *attrDic = hppleElement.attributes;
            NSString *str1 = [NSString stringWithFormat:@"<img src=\"%@\" alt=\"%@\"/>",attrDic[@"src"],attrDic[@"alt"]];
            NSDictionary *attrDic2 = self.imageInfo[attrDic[@"src"]];
            NSString *width;
            NSString *height;
            CGFloat screenReferW = [UIScreen mainScreen].bounds.size.width - YJNewNoteImageOffset;
            if ([[attrDic2 allKeys] containsObject:@"width"]) {
                width = attrDic2[@"width"];
                height = attrDic2[@"height"];
            } else {
                width = [NSString stringWithFormat:@"%.f",screenReferW];
                height = width;
            }
            NSString *str2 = [NSString stringWithFormat:@"<img class=\"myInsertImg\" src=\"%@\" width=\"%@\" height=\"%@\"/>",attrDic2[@"src"],width,height];
            html = [html stringByReplacingOccurrencesOfString:str1 withString:str2];
        }
    }
    
    _NoteContent = html;
}
@end

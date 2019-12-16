//
//  NSString+Notes.m
//  NoteDemo
//
//  Created by hend on 2019/3/20.
//  Copyright © 2019 hend. All rights reserved.
//

#import "NSString+Notes.h"
//#import <TFHpple/TFHpple.h>
#import "LGNoteConfigure.h"
#import "UIImage+ImgSize.h"
#import <YJBaseModule/YJBHpple.h>
@implementation NSString (Notes)

- (NSMutableAttributedString *)lg_initMutableAtttrubiteString{
    return [[NSMutableAttributedString alloc] initWithString:self];
}

- (NSMutableAttributedString *)lg_changeforMutableAtttrubiteString{
    NSData *htmlData = [self dataUsingEncoding:NSUnicodeStringEncoding];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithData:htmlData options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.lineSpacing = 15;// 字体的行间距
    
    NSDictionary *attributes = @{
                                 
                                 NSFontAttributeName:[UIFont systemFontOfSize:15],
                             NSParagraphStyleAttributeName:paragraphStyle
                                 
                                 };
    
    [att addAttributes:attributes range:NSMakeRange(0, att.length)];
    return att;
}

- (NSString *)lg_adjustImageHTMLFrame{
    NSString *html = self.copy;
    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    
   // TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
     YJBHpple *xpathParser = [[YJBHpple alloc] initWithHTMLData:htmlData];
    NSArray *imgArray = [xpathParser searchWithXPathQuery:@"//img"];
    if (imgArray && imgArray.count > 0) {
//        for (TFHppleElement *element in imgArray) {
//            html = [html adjustImgSrcAttributeWithImgElement:element];
//        }
        for (YJBHppleElement *element in imgArray) {
            html = [html adjustImgSrcAttributeWithImgElement:element];
        }
    }
    return html;
}

- (NSString *)adjustImgSrcAttributeWithImgElement:(YJBHppleElement *) element{
    
    // self.isNull = NO;
    NSString *html = self.copy;
    NSDictionary *attributes = element.attributes;
    
    NSString *imgSrc = attributes[@"src"];
    
    
    NSString *imgSrcExtendName = [imgSrc componentsSeparatedByString:@"."].lastObject;
    if (imgSrcExtendName && [imgSrcExtendName.lowercaseString containsString:@"gif"]) {
        return html;
    }
    
    // 图片宽、高
    NSString *imageWidth = attributes[@"width"];
    NSString *imageHeight = attributes[@"height"];
    
    
    
    if([imageWidth isEqualToString:@"auto"]|| IsStrEmpty(imageWidth)){
        
        //取到图片自身宽高赋值.
        CGSize size = [UIImage getImageSizeWithURL:[NSURL URLWithString:imgSrc]];
        NSLog(@"%.f--%.f", size.height,size.width);
        
        imageWidth = [NSString stringWithFormat:@"%.f",size.width];
        imageHeight=[NSString stringWithFormat:@"%.f",size.height];
    }
    
    
    
    if ([imageWidth containsString:@"px"]) {
        imageWidth = [imageWidth stringByReplacingOccurrencesOfString:@"px" withString:@""];
    }
    
    
    if ([imageHeight containsString:@"px"]) {
        imageHeight = [imageHeight stringByReplacingOccurrencesOfString:@"px" withString:@""];
    }
    
    CGFloat imgW = [imageWidth floatValue];
    CGFloat imgH = [imageHeight floatValue];
    
    if(imgW == 0){
        
        //取到图片自身宽高赋值.
        CGSize size = [UIImage getImageSizeWithURL:[NSURL URLWithString:imgSrc]];
        NSLog(@"%.f--%.f", size.height,size.width);
        
        NSString* With = [NSString stringWithFormat:@"%.f",size.width];
        NSString* Hegtt=[NSString stringWithFormat:@"%.f",size.height];
        
        imgW = [With floatValue];
        imgH = [Hegtt floatValue];
    }
    
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenReferW = screenW-kNoteImageOffset-20;
    
    
    if (imgW == 0 || imgW > screenReferW) {
        
        NSString *imgWStr;
        NSString *imgHtStr;
        if(imgW != 0){
            
            CGFloat targetWidth = screenReferW;
            CGFloat targetHeight = imgH / (imgW / targetWidth);
            
                imgWStr = [NSString stringWithFormat:@"%.f",targetWidth];
            imgHtStr = [NSString stringWithFormat:@"%.f",targetHeight];
            
            
        }else{
            
            CGFloat scale =screenReferW /imgW;
                   
                imgWStr = [NSString stringWithFormat:@"%.f",screenReferW];
            imgHtStr = [NSString stringWithFormat:@"%.f",imgH*scale];
            
        }
        
       
       
        
        if ([[attributes allKeys] containsObject:@"width"]) {
            
            
            NSString *imgSrcReferStr = [NSString stringWithFormat:@"width=%@ height=%@",attributes[@"width"],attributes[@"height"]];
            if (![html containsString:imgSrcReferStr]) {
                imgSrcReferStr = [NSString stringWithFormat:@"width=\"%@\" height=\"%@\"",attributes[@"width"],attributes[@"height"]];
            }
            html = [html stringByReplacingOccurrencesOfString:imgSrcReferStr withString:[NSString stringWithFormat:@"width=%@ height=%@",imgWStr,imgHtStr]];
            
            
        } else {
            
            
            NSArray *attibuteArray = element.attibuteArray;

            NSString *labelStr = @"";
            for (NSDictionary *attrDic in attibuteArray) {
                
                
                NSString *lab = labelStr.copy;
                if ([attrDic[@"attributeName"] isEqualToString:@"alt"]) {
                    
                    lab = [lab stringByAppendingFormat:@"  %@=\"%@\"",attrDic[@"attributeName"],attrDic[@"nodeContent"]];
                }else{
                    
                    lab = [lab stringByAppendingFormat:@" %@=\"%@\"",attrDic[@"attributeName"],attrDic[@"nodeContent"]];
                }
                
                labelStr = lab;
                
            }
            
            NSString *imgSrcFrameStr = [NSString stringWithFormat:@" width=%@ height=%@",imgWStr,imgHtStr];
            
            NSString *imgSrcFullStr = [labelStr stringByAppendingString:imgSrcFrameStr];
            
           
            if(![html containsString:@"width="]){
                //unselectable="on"
                html = [html stringByReplacingOccurrencesOfString:@"unselectable=" withString:imgSrcFullStr];
            }else{
                html = [html stringByReplacingOccurrencesOfString:labelStr withString:imgSrcFullStr];
            }
            
        }
        
        
    }else if(IsStrEmpty(attributes[@"width"])&& imgW < screenReferW){
        
        NSString *imgWStr;
        NSString *imgHtStr;
        
        imgWStr = [NSString stringWithFormat:@"%.f",imgW];
        imgHtStr = [NSString stringWithFormat:@"%.f",imgH];
        
        if (![[attributes allKeys] containsObject:@"width"]) {
            
            NSArray *attibuteArray = element.attibuteArray;
            
            NSString *labelStr = @"";
            for (NSDictionary *attrDic in attibuteArray) {
                
                
                NSString *lab = labelStr.copy;
                if ([attrDic[@"attributeName"] isEqualToString:@"alt"]) {
                    
                    lab = [lab stringByAppendingFormat:@"  %@=\"%@\"",attrDic[@"attributeName"],attrDic[@"nodeContent"]];
                }else{
                    
                    lab = [lab stringByAppendingFormat:@" %@=\"%@\"",attrDic[@"attributeName"],attrDic[@"nodeContent"]];
                }
                
                labelStr = lab;
                
            }
            
            NSString *imgSrcFrameStr = [NSString stringWithFormat:@" width=%@ height=%@",imgWStr,imgHtStr];
            
            NSString *imgSrcFullStr = [labelStr stringByAppendingString:imgSrcFrameStr];
            
            html = [html stringByReplacingOccurrencesOfString:labelStr withString:imgSrcFullStr];
            
        }
        
    }
    
    
    
    
    
    
    return html;
}

@end

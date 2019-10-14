//
//  Created by 刘亚军 on 2019/7/20.
//


#import <Foundation/Foundation.h>

#import "YJBHppleElement.h"

@interface YJBHpple : NSObject

- (id) initWithData:(NSData *)theData encoding:(NSString *)encoding isXML:(BOOL)isDataXML;
- (id) initWithData:(NSData *)theData isXML:(BOOL)isDataXML;
- (id) initWithXMLData:(NSData *)theData encoding:(NSString *)encoding;
- (id) initWithXMLData:(NSData *)theData;
- (id) initWithHTMLData:(NSData *)theData encoding:(NSString *)encoding;
- (id) initWithHTMLData:(NSData *)theData;

+ (YJBHpple *) hppleWithData:(NSData *)theData encoding:(NSString *)encoding isXML:(BOOL)isDataXML;
+ (YJBHpple *) hppleWithData:(NSData *)theData isXML:(BOOL)isDataXML;
+ (YJBHpple *) hppleWithXMLData:(NSData *)theData encoding:(NSString *)encoding;
+ (YJBHpple *) hppleWithXMLData:(NSData *)theData;
+ (YJBHpple *) hppleWithHTMLData:(NSData *)theData encoding:(NSString *)encoding;
+ (YJBHpple *) hppleWithHTMLData:(NSData *)theData;

- (NSArray *) searchWithXPathQuery:(NSString *)xPathOrCSS;
- (YJBHppleElement *) peekAtSearchWithXPathQuery:(NSString *)xPathOrCSS;

@property (nonatomic, readonly) NSData * data;
@property (nonatomic, readonly) NSString * encoding;

@end

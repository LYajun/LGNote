//
//  XMLDictionary.h
//
//  Version 1.4
//
//  Created by Nick Lockwood on 15/11/2010.
//  Copyright 2010 Charcoal Design. All rights reserved.
//
//  Get the latest version of XMLDictionary from here:
//
//  https://github.com/nicklockwood/XMLDictionary
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <Foundation/Foundation.h>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"


typedef NS_ENUM(NSInteger, NoteXMLDictionaryAttributesMode)
{
    NoteXMLDictionaryAttributesModePrefixed = 0, //default
    NoteXMLDictionaryAttributesModeDictionary,
    NoteXMLDictionaryAttributesModeUnprefixed,
    NoteXMLDictionaryAttributesModeDiscard
};


typedef NS_ENUM(NSInteger, NoteXMLDictionaryNodeNameMode)
{
    NoteXMLDictionaryNodeNameModeRootOnly = 0, //default
    NoteXMLDictionaryNodeNameModeAlways,
    NoteXMLDictionaryNodeNameModeNever
};


static NSString *const NoteXMLDictionaryAttributesKey   = @"__attributes";
static NSString *const NoteXMLDictionaryCommentsKey     = @"__comments";
static NSString *const NoteXMLDictionaryTextKey         = @"__text";
static NSString *const NoteXMLDictionaryNodeNameKey     = @"__name";
static NSString *const NoteXMLDictionaryAttributePrefix = @"_";


@interface NoteXMLDictionaryParser : NSObject <NSCopying>

+ (NoteXMLDictionaryParser *)sharedInstance;

@property (nonatomic, assign) BOOL NotecollapseTextNodes; // defaults to YES
@property (nonatomic, assign) BOOL NotestripEmptyNodes;   // defaults to YES
@property (nonatomic, assign) BOOL NotetrimWhiteSpace;    // defaults to YES
@property (nonatomic, assign) BOOL NotealwaysUseArrays;   // defaults to NO
@property (nonatomic, assign) BOOL NotepreserveComments;  // defaults to NO
@property (nonatomic, assign) BOOL NotewrapRootNode;      // defaults to NO

@property (nonatomic, assign) NoteXMLDictionaryAttributesMode attributesMode;
@property (nonatomic, assign) NoteXMLDictionaryNodeNameMode nodeNameMode;

- (NSDictionary *)NotedictionaryWithParser:(NSXMLParser *)parser;
- (NSDictionary *)NotedictionaryWithData:(NSData *)data;
- (NSDictionary *)NotedictionaryWithString:(NSString *)string;
- (NSDictionary *)NotedictionaryWithFile:(NSString *)path;

@end


@interface NSDictionary (NoteXMLDictionary)

+ (NSDictionary *)NotedictionaryWithXMLParser:(NSXMLParser *)parser;
+ (NSDictionary *)NotedictionaryWithXMLData:(NSData *)data;
+ (NSDictionary *)NotedictionaryWithXMLString:(NSString *)string;
+ (NSDictionary *)NotedictionaryWithXMLFile:(NSString *)path;

- (NSDictionary *)Noteattributes;
- (NSDictionary *)NotechildNodes;
- (NSArray *)Notecomments;
- (NSString *)NotenodeName;
- (NSString *)NoteinnerText;
- (NSString *)NoteinnerXML;
- (NSString *)NoteXMLString;

- (NSArray *)NotearrayValueForKeyPath:(NSString *)keyPath;
- (NSString *)NotestringValueForKeyPath:(NSString *)keyPath;
- (NSDictionary *)NotedictionaryValueForKeyPath:(NSString *)keyPath;

@end


@interface NSString (NoteXMLDictionary)

- (NSString *)NoteXMLEncodedString;

@end


#pragma GCC diagnostic pop

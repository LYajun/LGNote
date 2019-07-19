//
//  XMLDictionary.m
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

#import "NoteXMLDictionary.h"


#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma GCC diagnostic ignored "-Wdirect-ivar-access"
#pragma GCC diagnostic ignored "-Wformat-non-iso"
#pragma GCC diagnostic ignored "-Wgnu"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


@interface NoteXMLDictionaryParser () <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableDictionary *root;
@property (nonatomic, strong) NSMutableArray *stack;
@property (nonatomic, strong) NSMutableString *text;

@end


@implementation NoteXMLDictionaryParser

+ (NoteXMLDictionaryParser *)sharedInstance
{
    static dispatch_once_t once;
    static NoteXMLDictionaryParser *sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [[NoteXMLDictionaryParser alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if ((self = [super init]))
    {
        _NotecollapseTextNodes = YES;
        _NotestripEmptyNodes = YES;
        _NotetrimWhiteSpace = YES;
        _NotealwaysUseArrays = NO;
        _NotepreserveComments = NO;
        _NotewrapRootNode = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    NoteXMLDictionaryParser *copy = [[[self class] allocWithZone:zone] init];
    copy.NotecollapseTextNodes = _NotecollapseTextNodes;
    copy.NotestripEmptyNodes = _NotestripEmptyNodes;
    copy.NotetrimWhiteSpace = _NotetrimWhiteSpace;
    copy.NotealwaysUseArrays = _NotealwaysUseArrays;
    copy.NotepreserveComments = _NotepreserveComments;
    copy.attributesMode = _attributesMode;
    copy.nodeNameMode = _nodeNameMode;
    copy.NotewrapRootNode = _NotewrapRootNode;
    return copy;
}

- (NSDictionary *)NotedictionaryWithParser:(NSXMLParser *)parser
{
    [parser setDelegate:self];
    [parser parse];
    id result = _root;
    _root = nil;
    _stack = nil;
    _text = nil;
    return result;
}

- (NSDictionary *)NotedictionaryWithData:(NSData *)data
{
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    return [self NotedictionaryWithParser:parser];
}

- (NSDictionary *)NotedictionaryWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self NotedictionaryWithData:data];
}

- (NSDictionary *)NotedictionaryWithFile:(NSString *)path
{	
	NSData *data = [NSData dataWithContentsOfFile:path];
	return [self NotedictionaryWithData:data];
}

+ (NSString *)NoteXMLStringForNode:(id)node withNodeName:(NSString *)nodeName
{	
    if ([node isKindOfClass:[NSArray class]])
    {
        NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[node count]];
        for (id individualNode in node)
        {
            [nodes addObject:[self NoteXMLStringForNode:individualNode withNodeName:nodeName]];
        }
        return [nodes componentsJoinedByString:@"\n"];
    }
    else if ([node isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *attributes = [(NSDictionary *)node Noteattributes];
        NSMutableString *attributeString = [NSMutableString string];
        for (NSString *key in [attributes allKeys])
        {
            [attributeString appendFormat:@" %@=\"%@\"", [[key description] NoteXMLEncodedString], [[attributes[key] description] NoteXMLEncodedString]];
        }
        
        NSString *innerXML = [node NoteinnerXML];
        if ([innerXML length])
        {
            return [NSString stringWithFormat:@"<%1$@%2$@>%3$@</%1$@>", nodeName, attributeString, innerXML];
        }
        else
        {
            return [NSString stringWithFormat:@"<%@%@/>", nodeName, attributeString];
        }
    }
    else
    {
        return [NSString stringWithFormat:@"<%1$@>%2$@</%1$@>", nodeName, [[node description] NoteXMLEncodedString]];
    }
}

- (void)endText
{
	if (_NotetrimWhiteSpace)
	{
		_text = [[_text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
	}
	if ([_text length])
	{
        NSMutableDictionary *top = [_stack lastObject];
		id existing = top[NoteXMLDictionaryTextKey];
        if ([existing isKindOfClass:[NSArray class]])
        {
            [existing addObject:_text];
        }
        else if (existing)
        {
            top[NoteXMLDictionaryTextKey] = [@[existing, _text] mutableCopy];
        }
		else
		{
			top[NoteXMLDictionaryTextKey] = _text;
		}
	}
	_text = nil;
}

- (void)addText:(NSString *)text
{	
	if (!_text)
	{
		_text = [NSMutableString stringWithString:text];
	}
	else
	{
		[_text appendString:text];
	}
}

- (void)parser:(__unused NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(__unused NSString *)namespaceURI qualifiedName:(__unused NSString *)qName attributes:(NSDictionary *)attributeDict
{	
	[self endText];
	
	NSMutableDictionary *node = [NSMutableDictionary dictionary];
	switch (_nodeNameMode)
	{
        case NoteXMLDictionaryNodeNameModeRootOnly:
        {
            if (!_root)
            {
                node[NoteXMLDictionaryNodeNameKey] = elementName;
            }
            break;
        }
        case NoteXMLDictionaryNodeNameModeAlways:
        {
            node[NoteXMLDictionaryNodeNameKey] = elementName;
            break;
        }
        case NoteXMLDictionaryNodeNameModeNever:
        {
            break;
        }
	}
    
	if ([attributeDict count])
	{
        switch (_attributesMode)
        {
            case NoteXMLDictionaryAttributesModePrefixed:
            {
                for (NSString *key in [attributeDict allKeys])
                {
                    node[[NoteXMLDictionaryAttributePrefix stringByAppendingString:key]] = attributeDict[key];
                }
                break;
            }
            case NoteXMLDictionaryAttributesModeDictionary:
            {
                node[NoteXMLDictionaryAttributesKey] = attributeDict;
                break;
            }
            case NoteXMLDictionaryAttributesModeUnprefixed:
            {
                [node addEntriesFromDictionary:attributeDict];
                break;
            }
            case NoteXMLDictionaryAttributesModeDiscard:
            {
                break;
            }
        }
	}
	
	if (!_root)
	{
        _root = node;
        _stack = [NSMutableArray arrayWithObject:node];
        if (_NotewrapRootNode)
        {
            _root = [NSMutableDictionary dictionaryWithObject:_root forKey:elementName];
            [_stack insertObject:_root atIndex:0];
        }
	}
	else
	{
        NSMutableDictionary *top = [_stack lastObject];
		id existing = top[elementName];
        if ([existing isKindOfClass:[NSArray class]])
        {
            [existing addObject:node];
        }
        else if (existing)
        {
            top[elementName] = [@[existing, node] mutableCopy];
        }
        else if (_NotealwaysUseArrays)
        {
            top[elementName] = [NSMutableArray arrayWithObject:node];
        }
		else
		{
			top[elementName] = node;
		}
		[_stack addObject:node];
	}
}

- (NSString *)nameForNode:(NSDictionary *)node inDictionary:(NSDictionary *)dict
{
	if (node.NotenodeName)
	{
		return node.NotenodeName;
	}
	else
	{
		for (NSString *name in dict)
		{
			id object = dict[name];
			if (object == node)
			{
				return name;
			}
			else if ([object isKindOfClass:[NSArray class]] && [object containsObject:node])
			{
				return name;
			}
		}
	}
	return nil;
}

- (void)parser:(__unused NSXMLParser *)parser didEndElement:(__unused NSString *)elementName namespaceURI:(__unused NSString *)namespaceURI qualifiedName:(__unused NSString *)qName
{	
	[self endText];
    
    NSMutableDictionary *top = [_stack lastObject];
    [_stack removeLastObject];
    
	if (!top.Noteattributes && !top.NotechildNodes && !top.Notecomments)
    {
        NSMutableDictionary *newTop = [_stack lastObject];
        NSString *nodeName = [self nameForNode:top inDictionary:newTop];
        if (nodeName)
        {
            id parentNode = newTop[nodeName];
            if (top.NoteinnerText && _NotecollapseTextNodes)
            {
                if ([parentNode isKindOfClass:[NSArray class]])
                {
                    parentNode[[parentNode count] - 1] = top.NoteinnerText;
                }
                else
                {
                    newTop[nodeName] = top.NoteinnerText;
                }
            }
            else if (!top.NoteinnerText && _NotestripEmptyNodes)
            {
                if ([parentNode isKindOfClass:[NSArray class]])
                {
                    [parentNode removeLastObject];
                }
                else
                {
                    [newTop removeObjectForKey:nodeName];
                }
            }
            else if (!top.NoteinnerText && !_NotecollapseTextNodes && !_NotestripEmptyNodes)
            {
                top[NoteXMLDictionaryTextKey] = @"";
            }
        }
	}
}

- (void)parser:(__unused NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[self addText:string];
}

- (void)parser:(__unused NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	[self addText:[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding]];
}

- (void)parser:(__unused NSXMLParser *)parser foundComment:(NSString *)comment
{
	if (_NotepreserveComments)
	{
        NSMutableDictionary *top = [_stack lastObject];
		NSMutableArray *comments = top[NoteXMLDictionaryCommentsKey];
		if (!comments)
		{
			comments = [@[comment] mutableCopy];
			top[NoteXMLDictionaryCommentsKey] = comments;
		}
		else
		{
			[comments addObject:comment];
		}
	}
}

@end


@implementation NSDictionary(NoteXMLDictionary)

+ (NSDictionary *)NotedictionaryWithXMLParser:(NSXMLParser *)parser
{
	return [[[NoteXMLDictionaryParser sharedInstance] copy] NotedictionaryWithParser:parser];
}

+ (NSDictionary *)NotedictionaryWithXMLData:(NSData *)data
{
	return [[[NoteXMLDictionaryParser sharedInstance] copy] NotedictionaryWithData:data];
}

+ (NSDictionary *)NotedictionaryWithXMLString:(NSString *)string
{
	return [[[NoteXMLDictionaryParser sharedInstance] copy] NotedictionaryWithString:string];
}

+ (NSDictionary *)NotedictionaryWithXMLFile:(NSString *)path
{
	return [[[NoteXMLDictionaryParser sharedInstance] copy] NotedictionaryWithFile:path];
}

- (NSDictionary *)Noteattributes
{
	NSDictionary *attributes = self[NoteXMLDictionaryAttributesKey];
	if (attributes)
	{
		return [attributes count]? attributes: nil;
	}
	else
	{
		NSMutableDictionary *filteredDict = [NSMutableDictionary dictionaryWithDictionary:self];
        [filteredDict removeObjectsForKeys:@[NoteXMLDictionaryCommentsKey, NoteXMLDictionaryTextKey, NoteXMLDictionaryNodeNameKey]];
        for (NSString *key in [filteredDict allKeys])
        {
            [filteredDict removeObjectForKey:key];
            if ([key hasPrefix:NoteXMLDictionaryAttributePrefix])
            {
                filteredDict[[key substringFromIndex:[NoteXMLDictionaryAttributePrefix length]]] = self[key];
            }
        }
        return [filteredDict count]? filteredDict: nil;
	}
	return nil;
}

- (NSDictionary *)NotechildNodes
{	
	NSMutableDictionary *filteredDict = [self mutableCopy];
	[filteredDict removeObjectsForKeys:@[NoteXMLDictionaryAttributesKey, NoteXMLDictionaryCommentsKey, NoteXMLDictionaryTextKey, NoteXMLDictionaryNodeNameKey]];
	for (NSString *key in [filteredDict allKeys])
    {
        if ([key hasPrefix:NoteXMLDictionaryAttributePrefix])
        {
            [filteredDict removeObjectForKey:key];
        }
    }
    return [filteredDict count]? filteredDict: nil;
}

- (NSArray *)Notecomments
{
	return self[NoteXMLDictionaryCommentsKey];
}

- (NSString *)NotenodeName
{
	return self[NoteXMLDictionaryNodeNameKey];
}

- (id)NoteinnerText
{	
	id text = self[NoteXMLDictionaryTextKey];
	if ([text isKindOfClass:[NSArray class]])
	{
		return [text componentsJoinedByString:@"\n"];
	}
	else
	{
		return text;
	}
}

- (NSString *)NoteinnerXML
{	
	NSMutableArray *nodes = [NSMutableArray array];
	
	for (NSString *comment in [self Notecomments])
	{
        [nodes addObject:[NSString stringWithFormat:@"<!--%@-->", [comment NoteXMLEncodedString]]];
	}
    
    NSDictionary *childNodes = [self NotechildNodes];
	for (NSString *key in childNodes)
	{
		[nodes addObject:[NoteXMLDictionaryParser NoteXMLStringForNode:childNodes[key] withNodeName:key]];
	}
	
    NSString *text = [self NoteinnerText];
    if (text)
    {
        [nodes addObject:[text NoteXMLEncodedString]];
    }
	
	return [nodes componentsJoinedByString:@"\n"];
}

- (NSString *)NoteXMLString
{
    if ([self count] == 1 && ![self NotenodeName])
    {
        //ignore outermost dictionary
        return [self NoteinnerXML];
    }
    else
    {
        return [NoteXMLDictionaryParser NoteXMLStringForNode:self withNodeName:[self NotenodeName] ?: @"root"];
    }
}

- (NSArray *)NotearrayValueForKeyPath:(NSString *)keyPath
{
    id value = [self valueForKeyPath:keyPath];
    if (value && ![value isKindOfClass:[NSArray class]])
    {
        return @[value];
    }
    return value;
}

- (NSString *)NotestringValueForKeyPath:(NSString *)keyPath
{
    id value = [self valueForKeyPath:keyPath];
    if ([value isKindOfClass:[NSArray class]])
    {
        value = [value count]? value[0]: nil;
    }
    if ([value isKindOfClass:[NSDictionary class]])
    {
        return [(NSDictionary *)value NoteinnerText];
    }
    return value;
}

- (NSDictionary *)NotedictionaryValueForKeyPath:(NSString *)keyPath
{
    id value = [self valueForKeyPath:keyPath];
    if ([value isKindOfClass:[NSArray class]])
    {
        value = [value count]? value[0]: nil;
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return @{NoteXMLDictionaryTextKey: value};
    }
    return value;
}

@end


@implementation NSString (NoteXMLDictionary)

- (NSString *)NoteXMLEncodedString
{	
	return [[[[[self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]
               stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]
              stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"]
             stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"]
            stringByReplacingOccurrencesOfString:@"\'" withString:@"&apos;"];
}

@end

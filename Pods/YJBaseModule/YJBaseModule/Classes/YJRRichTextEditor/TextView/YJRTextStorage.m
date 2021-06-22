//
//  YJRTextStorage.m
//
//  Version 0.2.0
//
//  Created by Illya Busigin on 01/05/2014.
//  Copyright (c) 2014 Cyrillian, Inc.
//
//  Distributed under MIT license.
//  Get the latest version from here:
//


#import "YJRTextStorage.h"
#import "YJRToken.h"

@interface YJRTextStorage ()

@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, strong) NSMutableDictionary *regularExpressionCache;

@end

@implementation YJRTextStorage

#pragma mark - Initialization & Setup

- (id)init
{
    if (self = [super init])
    {
        _defaultFont = [UIFont systemFontOfSize:12.0f];
        _attributedString = [NSMutableAttributedString new];
        
        _tokens = @[];
        _regularExpressionCache = @{}.mutableCopy;
    }
    
    return self;
}


#pragma mark - Overrides

- (void)setTokens:(NSMutableArray *)tokens
{
    _tokens = tokens;
    
    // Clear the regular expression cache
    [self.regularExpressionCache removeAllObjects];
    
    // Redraw all text
    [self update];
}

- (NSString *)string
{
    return [_attributedString string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_attributedString attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString*)str
{
    [self beginEditing];
    
    [_attributedString replaceCharactersInRange:range withString:str];
    
    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    [self endEditing];
}

- (void)setAttributes:(NSDictionary*)attrs range:(NSRange)range
{
    [self beginEditing];
    
    [_attributedString setAttributes:attrs range:range];
    
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

-(void)processEditing
{
    [self performReplacementsForRange:[self editedRange]];
    [super processEditing];
}

- (void)performReplacementsForRange:(NSRange)changedRange
{
    NSRange extendedRange = NSUnionRange(changedRange, [[_attributedString string] lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    
    [self applyStylesToRange:extendedRange];
}


-(void)update
{    
    [self addAttributes:@{NSFontAttributeName : self.defaultFont} range:NSMakeRange(0, self.length)];
    
    [self applyStylesToRange:NSMakeRange(0, self.length)];
}

- (void)applyStylesToRange:(NSRange)searchRange
{
    if (self.editedRange.location == NSNotFound)
    {
        return;
    }
    
    NSRange paragaphRange = [self.string paragraphRangeForRange: self.editedRange];
    
    // Reset the text attributes
    [self setAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} range:paragaphRange];
    
    [self setAttributes:@{NSFontAttributeName : self.defaultFont} range:paragaphRange];
    
    for (YJRToken *attribute in self.tokens)
    {
        NSRegularExpression *regex = [self expressionForDefinition:attribute.name];
        [regex enumerateMatchesInString:self.string options:0 range:paragaphRange
                             usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                 
                                 [attribute.attributes enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, id attributeValue, BOOL *stop) {
                                     [self addAttribute:attributeName value:attributeValue range:result.range];
                                 }];
                             }];
    }
}

- (NSRegularExpression *)expressionForDefinition:(NSString *)definition
{
    __block YJRToken *attribute = nil;
    
    [self.tokens enumerateObjectsUsingBlock:^(YJRToken *enumeratedAttribute, NSUInteger idx, BOOL *stop) {
        if ([enumeratedAttribute.name isEqualToString:definition])
        {
            attribute = enumeratedAttribute;
            *stop = YES;
        }
    }];
    
    NSRegularExpression *expression = self.regularExpressionCache[attribute.expression];
    
    if (!expression)
    {
        expression = [NSRegularExpression regularExpressionWithPattern:attribute.expression
                                                               options:NSRegularExpressionCaseInsensitive error:nil];
        
        [self.regularExpressionCache setObject:expression forKey:definition];
    }
    
    return expression;
}

@end

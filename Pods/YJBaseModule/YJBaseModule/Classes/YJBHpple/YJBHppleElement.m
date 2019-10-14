//
//  Created by 刘亚军 on 2019/7/20.
//


#import "YJBHppleElement.h"
#import "XPathQuery.h"

static NSString * const YJBHppleNodeContentKey           = @"nodeContent";
static NSString * const YJBHppleNodeNameKey              = @"nodeName";
static NSString * const YJBHppleNodeChildrenKey          = @"nodeChildArray";
static NSString * const YJBHppleNodeAttributeArrayKey    = @"nodeAttributeArray";
static NSString * const YJBHppleNodeAttributeNameKey     = @"attributeName";

static NSString * const YJBHppleTextNodeName            = @"text";

@interface YJBHppleElement ()
{    
    NSDictionary * node;
    BOOL isXML;
    NSString *encoding;
    __unsafe_unretained YJBHppleElement *parent;
}

@property (nonatomic, unsafe_unretained, readwrite) YJBHppleElement *parent;

@end

@implementation YJBHppleElement
@synthesize parent;


- (id) initWithNode:(NSDictionary *) theNode isXML:(BOOL)isDataXML withEncoding:(NSString *)theEncoding
{
  if (!(self = [super init]))
    return nil;

    isXML = isDataXML;
    node = theNode;
    encoding = theEncoding;

  return self;
}

+ (YJBHppleElement *) hppleElementWithNode:(NSDictionary *) theNode isXML:(BOOL)isDataXML withEncoding:(NSString *)theEncoding
{
  return [[[self class] alloc] initWithNode:theNode isXML:isDataXML withEncoding:theEncoding];
}

#pragma mark -

- (NSString *)raw
{
    return [node objectForKey:@"raw"];
}

- (NSString *) content
{
  return [node objectForKey:YJBHppleNodeContentKey];
}


- (NSString *) tagName
{
  return [node objectForKey:YJBHppleNodeNameKey];
}

- (NSArray *) children
{
  NSMutableArray *children = [NSMutableArray array];
  for (NSDictionary *child in [node objectForKey:YJBHppleNodeChildrenKey]) {
      YJBHppleElement *element = [YJBHppleElement hppleElementWithNode:child isXML:isXML withEncoding:encoding];
      element.parent = self;
      [children addObject:element];
  }
  return children;
}

- (YJBHppleElement *) firstChild
{
  NSArray * children = self.children;
  if (children.count)
    return [children objectAtIndex:0];
  return nil;
}

- (NSArray *)attibuteArray{
    return [node objectForKey:YJBHppleNodeAttributeArrayKey];
}

- (NSDictionary *) attributes
{
  NSMutableDictionary * translatedAttributes = [NSMutableDictionary dictionary];
  for (NSDictionary * attributeDict in [node objectForKey:YJBHppleNodeAttributeArrayKey]) {
      if ([attributeDict objectForKey:YJBHppleNodeContentKey] && [attributeDict objectForKey:YJBHppleNodeAttributeNameKey]) {
          [translatedAttributes setObject:[attributeDict objectForKey:YJBHppleNodeContentKey]
                                   forKey:[attributeDict objectForKey:YJBHppleNodeAttributeNameKey]];
      }
  }
  return translatedAttributes;
}

- (NSString *) objectForKey:(NSString *) theKey
{
  return [[self attributes] objectForKey:theKey];
}

- (id) description
{
  return [node description];
}

- (BOOL)hasChildren
{
    if ([node objectForKey:YJBHppleNodeChildrenKey])
        return YES;
    else
        return NO;
}

- (BOOL)isTextNode
{
    // we must distinguish between real text nodes and standard nodes with tha name "text" (<text>)
    // real text nodes must have content
    if ([self.tagName isEqualToString:YJBHppleTextNodeName] && (self.content))
        return YES;
    else
        return NO;
}

- (NSArray*) childrenWithTagName:(NSString*)tagName
{
    NSMutableArray* matches = [NSMutableArray array];
    
    for (YJBHppleElement* child in self.children)
    {
        if ([child.tagName isEqualToString:tagName])
            [matches addObject:child];
    }
    
    return matches;
}

- (YJBHppleElement *) firstChildWithTagName:(NSString*)tagName
{
    for (YJBHppleElement* child in self.children)
    {
        if ([child.tagName isEqualToString:tagName])
            return child;
    }
    
    return nil;
}

- (NSArray*) childrenWithClassName:(NSString*)className
{
    NSMutableArray* matches = [NSMutableArray array];
    
    for (YJBHppleElement* child in self.children)
    {
        if ([[child objectForKey:@"class"] isEqualToString:className])
            [matches addObject:child];
    }
    
    return matches;
}

- (YJBHppleElement *) firstChildWithClassName:(NSString*)className
{
    for (YJBHppleElement* child in self.children)
    {
        if ([[child objectForKey:@"class"] isEqualToString:className])
            return child;
    }
    
    return nil;
}

- (YJBHppleElement *) firstTextChild
{
    for (YJBHppleElement* child in self.children)
    {
        if ([child isTextNode])
            return child;
    }
    
    return [self firstChildWithTagName:YJBHppleTextNodeName];
}

- (NSString *) text
{
    return self.firstTextChild.content;
}

// Returns all elements at xPath.
- (NSArray *) searchWithXPathQuery:(NSString *)xPathOrCSS
{
    
    NSData *data = [self.raw dataUsingEncoding:NSUTF8StringEncoding];

    NSArray * detailNodes = nil;
    if (isXML) {
        detailNodes = PerformXMLXPathQueryWithEncoding(data, xPathOrCSS, encoding);
    } else {
        detailNodes = PerformHTMLXPathQueryWithEncoding(data, xPathOrCSS, encoding);
    }
    
    NSMutableArray * hppleElements = [NSMutableArray array];
    for (id newNode in detailNodes) {
        [hppleElements addObject:[YJBHppleElement hppleElementWithNode:newNode isXML:isXML withEncoding:encoding]];
    }
    return hppleElements;
}

// Custom keyed subscripting
- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

@end

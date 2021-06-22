//
//  YJBTableViewCell.m
//  Pods-YJBaseModule_Example
//
//  Created by 刘亚军 on 2019/8/1.
//

#import "YJBTableViewCell.h"
#import <YJExtensions/YJExtensions.h>
@interface YJBTableViewCell ()
@property (nonatomic,strong) UIView *botLine;
@end
@implementation YJBTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self defaultSetup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self defaultSetup];
    }
    return self;
}
- (void)defaultSetup{
    _isShowSeparator = NO;
    _separatorOffset = 0;
    _separatorWidth = 0.8;
    _sepColor = [UIColor yj_colorWithHex:0xdcdcdc];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (@available(iOS 14.0, *)) {
        [self.contentView addSubview:self.botLine];
    }
}
- (UIView *)botLine{
    if (!_botLine) {
        _botLine = [UIView new];
    }
    return _botLine;
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    if (self.highlightColor) {
        if (highlighted) {
            self.backgroundColor = self.highlightColor;
        }else{
            self.backgroundColor = [UIColor clearColor];
        }
    }
    [super setHighlighted:highlighted animated:animated];
}
- (void)drawRect:(CGRect)rect{
    CGFloat width = self.separatorWidth;
    if (!self.isShowSeparator) {
        width = 0;
    }
    self.botLine.frame = CGRectMake(self.separatorOffsetPoint.x, rect.size.height - width, rect.size.width-self.separatorOffsetPoint.x-self.separatorOffsetPoint.y, width);
    self.botLine.backgroundColor = self.sepColor;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(self.separatorOffsetPoint.x, rect.size.height - width, rect.size.width-self.separatorOffsetPoint.x-self.separatorOffsetPoint.y, width)];
    [self.sepColor setFill];
    [bezierPath fillWithBlendMode:kCGBlendModeNormal alpha:1];
    [bezierPath closePath];
}
- (void)setIsShowSeparator:(BOOL)isShowSeparator{
    _isShowSeparator = isShowSeparator;
    [self setNeedsDisplay];
}
- (void)setSeparatorOffsetPoint:(CGPoint)separatorOffsetPoint{
    _separatorOffsetPoint = separatorOffsetPoint;
    [self setNeedsDisplay];
}
- (void)setSeparatorOffset:(CGFloat)separatorOffset{
    _separatorOffset = separatorOffset;
    self.separatorOffsetPoint = CGPointMake(separatorOffset, separatorOffset);
}
- (void)setSeparatorWidth:(CGFloat)separatorWidth{
    _separatorWidth = separatorWidth;
    [self setNeedsDisplay];
}
- (void)setSepColor:(UIColor *)sepColor{
    _sepColor = sepColor;
    [self setNeedsDisplay];
}
@end

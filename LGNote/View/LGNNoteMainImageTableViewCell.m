//
//  NoteMainImageTableViewCell.m
//  NoteDemo
//
//  Created by hend on 2019/3/20.
//  Copyright © 2019 hend. All rights reserved.
//

#import "LGNNoteMainImageTableViewCell.h"
#import "LGNoteConfigure.h"
#import <Masonry/Masonry.h>
#import "LGNNoteTools.h"
#import "LGNNoteModel.h"
#import "NSBundle+Notes.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LGNNoteMainImageTableViewCell ()

@property (nonatomic, strong) UILabel *noteTitleLabel;
@property (nonatomic, strong) UILabel *noteContentLabel;
@property (nonatomic, strong) UILabel *editTimeLabel;
@property (nonatomic, strong) UILabel *sourceLabel;
@property (nonatomic, strong) UIImageView *noteImageView;


@end

@implementation LGNNoteMainImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self lg_addSubViews];

    }
    return self;
}


- (void)lg_addSubViews{
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.noteTitleLabel];
    [self.contentView addSubview:self.noteContentLabel];
    [self.contentView addSubview:self.editTimeLabel];
    [self.contentView addSubview:self.sourceLabel];
    [self.contentView addSubview:self.noteImageView];
    
    [self lg_setupSubViewsContraints];
}

- (void)lg_setupSubViewsContraints{
    [self.noteTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.contentView).offset(10);
        make.centerX.equalTo(self.contentView);
        make.height.mas_equalTo(21);
    }];
    [self.noteContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.noteTitleLabel);
        make.top.height.equalTo(self.noteImageView);
        make.right.equalTo(self.noteImageView.mas_left).offset(-10);
        
    }];
    [self.sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.editTimeLabel);
        make.left.equalTo(self.editTimeLabel.mas_right).offset(5);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.mas_equalTo(15);
    }];
    [self.editTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-10);
        make.left.equalTo(self.noteTitleLabel);
        make.size.mas_equalTo(CGSizeMake(100, 15));
    }];
    CGFloat imageWidth = (kMain_Screen_Width - 30)/3;
    [self.noteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(imageWidth, 80));
        make.right.equalTo(self.contentView).offset(-10);
    }];
}

- (void)configureCellForDataSource:(LGNNoteModel *)dataSource indexPath:(NSIndexPath *)indexPath{
    NSString *subjectName = [NSString stringWithFormat:@"%@ | ",[LGNNoteTools getSubjectImageNameWithSubjectID:dataSource.SubjectID]];
    NSMutableAttributedString *att = [LGNNoteTools attributedStringByStrings:@[subjectName,dataSource.ResourceName] colors:@[kColorInitWithRGB(0, 153, 255, 1),kColorInitWithRGB(0, 153, 255, 1)] fonts:@[@(12),@(12)]];
    self.sourceLabel.attributedText = att;
    self.editTimeLabel.text = [NSString stringWithFormat:@"%@",dataSource.NoteEditTime];
    
    NSMutableString *contentString = dataSource.NoteContent_Att.mutableString;
    [contentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.noteContentLabel.text = contentString;
    
    NSString *imageUrl = [dataSource.imgaeUrls objectAtIndex:0];

    [self.noteImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[NSBundle lg_imageName:@"lg_empty"] options:SDWebImageRefreshCached];
    
    
    if ([dataSource.IsKeyPoint isEqualToString:@"1"]) {
        if(_isSearchVC){//搜索标注关键字颜色
            NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:[dataSource.NoteTitle stringByAppendingString:@" "]];
            self.noteTitleLabel.attributedText = att1;
            
            self.noteTitleLabel.attributedText = [self setAllText:self.noteTitleLabel.text andSpcifiStr:_searchContent withColor:nil specifiStrFont:nil isremark:YES];
        }else{
            NSTextAttachment *attment = [[NSTextAttachment alloc] init];
            attment.image = [NSBundle lg_imagePathName:@"note_remark_selected"];
            attment.bounds = CGRectMake(5, -1, 15, 15);
            
            NSAttributedString *attmentAtt = [NSAttributedString attributedStringWithAttachment:attment];
            NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:[dataSource.NoteTitle stringByAppendingString:@" "]];
            
            [att1 appendAttributedString:attmentAtt];
            
            
            self.noteTitleLabel.attributedText = att1;
        }
    } else {
        NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:dataSource.NoteTitle];
        self.noteTitleLabel.attributedText = att1;
        if(_isSearchVC){
            
      self.noteTitleLabel.attributedText = [self setAllText:self.noteTitleLabel.text andSpcifiStr:_searchContent withColor:nil specifiStrFont:nil isremark:NO];
        }
    }
    
}


- (NSMutableAttributedString *)setAllText:(NSString *)allStr andSpcifiStr:(NSString *)keyWords withColor:(UIColor *)color specifiStrFont:(UIFont *)font isremark:(BOOL)remak{
    NSMutableAttributedString *mutableAttributedStr = [[NSMutableAttributedString alloc] initWithString:allStr];
    if (color == nil) {
        color = [UIColor orangeColor];
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:17];
    }
    
    
    for (NSInteger j=0; j<=keyWords.length-1; j++) {
        
        NSRange searchRange = NSMakeRange(0, [allStr length]);
        NSRange range;
        NSString *singleStr = [keyWords substringWithRange:NSMakeRange(j, 1)];
        
        while
            ((range = [allStr rangeOfString:singleStr options:NSLiteralSearch range:searchRange]).location != NSNotFound) {
                //改变多次搜索时searchRange的位置
                searchRange = NSMakeRange(NSMaxRange(range), [allStr length] - NSMaxRange(range));
                //设置富文本
                [mutableAttributedStr addAttribute:NSForegroundColorAttributeName value:color range:range];
                [mutableAttributedStr addAttribute:NSFontAttributeName value:font range:range];
            }
        
       
        
    }
    
    if(remak){
        
        NSTextAttachment *attment = [[NSTextAttachment alloc] init];
        attment.image = [NSBundle lg_imagePathName:@"note_remark_selected"];
        attment.bounds = CGRectMake(5, -1, 15, 15);
        
        NSAttributedString *attmentAtt = [NSAttributedString attributedStringWithAttachment:attment];
        
        [mutableAttributedStr appendAttributedString:attmentAtt];
    }
    
    return mutableAttributedStr;
}




#pragma mark - lazy
- (UILabel *)editTimeLabel{
    if (!_editTimeLabel) {
        _editTimeLabel = [[UILabel alloc] init];
        _editTimeLabel.text = @"8:30~09:19";
        _editTimeLabel.textColor = [UIColor lightGrayColor];
        _editTimeLabel.font = [UIFont systemFontOfSize:10.f];;
    }
    return _editTimeLabel;
}

- (UILabel *)noteContentLabel{
    if (!_noteContentLabel) {
        _noteContentLabel = [[UILabel alloc] init];
        _noteContentLabel.text = @"荷塘月色内容";
        _noteContentLabel.font = kSYSTEMFONT(14.f);
        _noteContentLabel.numberOfLines = 0;
         _noteContentLabel.textColor = LGRGB(101, 101, 101);
    }
    return _noteContentLabel;
}

- (UILabel *)noteTitleLabel{
    if (!_noteTitleLabel) {
        _noteTitleLabel = [[UILabel alloc] init];
        _noteTitleLabel.font = [UIFont systemFontOfSize:17.f];
        _noteTitleLabel.text = @"毛泽东思想，马克思主义，中国特色社会主义核心价值观";
        _noteTitleLabel.numberOfLines = 1;
        _noteTitleLabel.textColor = LGRGB(37, 37, 37);
         _noteTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _noteTitleLabel;
}

- (UILabel *)sourceLabel{
    if (!_sourceLabel) {
        _sourceLabel = [[UILabel alloc] init];
    }
    return _sourceLabel;
}

- (UIImageView *)noteImageView{
    if (!_noteImageView) {
        _noteImageView = [[UIImageView alloc] init];
        _noteImageView.layer.cornerRadius = 5;
        _noteImageView.clipsToBounds = YES;
        _noteImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_noteImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[NSBundle lg_imageName:@"lg_empty"]];
    }
    return _noteImageView;
}



@end

//
//  LGNNoteMainImageTYCell.m
//  NoteDemo
//
//  Created by abc on 2020/5/21.
//  Copyright © 2020 hend. All rights reserved.
//

#import "LGNNoteMainImageTYCell.h"
#import "LGNoteConfigure.h"
#import <Masonry/Masonry.h>
#import "LGNNoteTools.h"
#import "LGNNoteModel.h"
#import "NSBundle+Notes.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LGNNoteMainImageTYCell ()

@property (nonatomic, strong) UILabel *noteTitleLabel;
@property (nonatomic,strong) UIImageView * markImageV;
@property (nonatomic, strong) UILabel *noteContentLabel;
@property (nonatomic, strong) UILabel *editTimeLabel;
@property (nonatomic, strong) UILabel *sourceLabel;
@property (nonatomic, strong) UIImageView *noteImageView;


@end

@implementation LGNNoteMainImageTYCell

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
    [self.contentView addSubview:self.markImageV];
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
        make.height.mas_equalTo(21);
    }];
    [self.markImageV mas_makeConstraints:^(MASConstraintMaker *make) {
         
        make.top.equalTo(self.contentView).offset(13);
     make.left.equalTo(self.noteTitleLabel.mas_right).offset(5);
         make.height.mas_equalTo(15);
         make.width.mas_equalTo(15);
         
     }];
    
    [self.noteContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.noteTitleLabel);
          make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.noteTitleLabel.mas_bottom).offset(10);
          make.height.mas_equalTo(40);
      }];
    
 CGFloat imageWidth = (kMain_Screen_Width - 30)/3;
   [self.noteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
  
      make.bottom.equalTo(self.contentView).offset(-40);

       make.left.equalTo(self.noteTitleLabel);
//       make.centerY.equalTo(self.contentView);
       make.size.mas_equalTo(CGSizeMake(imageWidth, 80));
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
  
}

- (void)configureCellForDataSource:(LGNNoteModel *)dataSource indexPath:(NSIndexPath *)indexPath{
   
    
    
    NSString * ResourceName =dataSource.ResourceName;
    NSString * MaterialName =dataSource.MaterialName;

                             
           NSMutableAttributedString *att = [LGNNoteTools attributedStringByStrings:@[ResourceName,MaterialName] colors:@[kColorInitWithRGB(0, 153, 255, 1),kColorInitWithRGB(0, 153, 255, 1)] fonts:@[@(12),@(12)]];
           self.sourceLabel.attributedText = att;
           
    
    self.editTimeLabel.text = [NSString stringWithFormat:@"%@",dataSource.NoteEditTime];
    
    NSMutableString *contentString = dataSource.NoteContent_Att.mutableString;
    [contentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.noteContentLabel.text = contentString;
    
    NSString *imageUrl = [dataSource.imgaeUrls objectAtIndex:0];

    [self.noteImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[NSBundle lg_imageName:@"notoPlaceholderImage"] options:SDWebImageRefreshCached];
    
    
    if ([dataSource.IsKeyPoint isEqualToString:@"1"]) {
        if(_isSearchVC){//搜索标注关键字颜色
            NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:[dataSource.NoteTitle stringByAppendingString:@" "]];
            self.noteTitleLabel.attributedText = att1;
            
            self.noteTitleLabel.attributedText = [self setAllText:self.noteTitleLabel.text andSpcifiStr:_searchContent withColor:nil specifiStrFont:nil isremark:YES];
        }else{
            
            NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:dataSource.NoteTitle];
            self.noteTitleLabel.attributedText = att1;
            
            self.markImageV.hidden = NO;
           
        }
    } else {
        self.markImageV.hidden = YES;
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
       // NSString *singleStr = [keyWords substringWithRange:NSMakeRange(j, 1)];
        NSString *singleStr =keyWords;

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
        
        self.markImageV.hidden =NO;

    }else{
       self.markImageV.hidden =YES;
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
        _noteTitleLabel.numberOfLines = 0;
        _noteTitleLabel.preferredMaxLayoutWidth = kMain_Screen_Width-40;
        _noteTitleLabel.textColor = LGRGB(37, 37, 37);
        
        
    }
    return _noteTitleLabel;
}

- (UIImageView *)markImageV{
    
    if(!_markImageV){
        _markImageV = [[UIImageView alloc] init];
        _markImageV.image = [NSBundle lg_imagePathName:@"note_remark_selected"];
    }
    
    return _markImageV;
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
        [_noteImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[NSBundle lg_imageName:@"notoPlaceholderImage"]];
    }
    return _noteImageView;
}


@end

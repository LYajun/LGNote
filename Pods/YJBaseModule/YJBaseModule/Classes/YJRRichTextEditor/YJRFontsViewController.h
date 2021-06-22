//
//  YJRFontsViewController.h
//  YJRRichTextEditor
//
//  Created by Will Swan on 03/09/2016.
//  Copyright © 2016 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int16_t, YJRFontFamily) {
    
    YJRFontFamilyDefault = 0,
    YJRFontFamilyTrebuchet = 1,
    YJRFontFamilyVerdana = 2,
    YJRFontFamilyGeorgia = 3,
    YJRFontFamilyPalatino = 4,
    YJRFontFamilyTimesNew = 5,
    YJRFontFamilyCourierNew = 6,
    
    
};

@protocol YJRFontsViewControllerDelegate
- (void)setSelectedFontFamily:(YJRFontFamily)fontFamily;
@end

@interface YJRFontsViewController : UIViewController {
    
    id<YJRFontsViewControllerDelegate> __weak delegate;
    
    YJRFontFamily _font;
    
}

+ (YJRFontsViewController *)cancelableFontPickerViewControllerWithFontFamily:(YJRFontFamily)fontFamily;

- (id)initWithFontFamily:(YJRFontFamily)fontFamily;

@property (weak) id<YJRFontsViewControllerDelegate> delegate;

@end

/*-
 * Copyright (c) 2011 Ryota Hayashi
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $FreeBSD$
 */

#import "YJRColorPickerViewController.h"
#import "YJRColorPickerView.h"

@implementation YJRColorPickerViewController

@synthesize delegate;


+ (YJRColorPickerViewController *)colorPickerViewControllerWithColor:(UIColor *)color
{
    return [[YJRColorPickerViewController alloc] initWithColor:color fullColor:NO saveStyle:HCPCSaveStyleSaveAlways];
}

+ (YJRColorPickerViewController *)cancelableColorPickerViewControllerWithColor:(UIColor *)color
{
    return [[YJRColorPickerViewController alloc] initWithColor:color fullColor:NO saveStyle:HCPCSaveStyleSaveAndCancel];
}

+ (YJRColorPickerViewController *)fullColorPickerViewControllerWithColor:(UIColor *)color
{
    return [[YJRColorPickerViewController alloc] initWithColor:color fullColor:YES saveStyle:HCPCSaveStyleSaveAlways];
}

+ (YJRColorPickerViewController *)cancelableFullColorPickerViewControllerWithColor:(UIColor *)color
{
    return [[YJRColorPickerViewController alloc] initWithColor:color fullColor:YES saveStyle:HCPCSaveStyleSaveAndCancel];
}



- (id)initWithDefaultColor:(UIColor *)defaultColor
{
    return [self initWithColor:defaultColor fullColor:NO saveStyle:HCPCSaveStyleSaveAlways];
}

- (id)initWithColor:(UIColor*)defaultColor fullColor:(BOOL)fullColor saveStyle:(HCPCSaveStyle)saveStyle

{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _color = defaultColor;
        _fullColor = fullColor;
        _saveStyle = saveStyle;
    }
    return self;
}

- (void)loadView
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame.size.height -= 44.f;
    
    self.view = [[UIView alloc] initWithFrame:frame];
    
    YJRRGBColor rgbColor;
    RGBColorFromUIColor(_color, &rgbColor);
    
    YJRColorPickerStyle style;
    
// j5136p1 12/08/2014 : Set size to mainScreen size and if a navigationviewcontroller exists we change it to navigation controller view size
    CGSize viewSize = [[UIScreen mainScreen] applicationFrame].size;
    
// j5136p1 12/08/2014 : if a navigationviewcontroller exists we change it to navigation controller view size to fit ex. modal views
    if (self.navigationController)
        viewSize = CGSizeMake(self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
    
    if (_fullColor) {
        style = [YJRColorPickerView fitScreenFullColorStyleWithSize:viewSize];
    }else{
        style = [YJRColorPickerView fitScreenStyleWithSize:viewSize];
    }
    
    colorPickerView = [[YJRColorPickerView alloc] initWithStyle:style defaultColor:rgbColor];
    
    [self.view addSubview:colorPickerView];
    
    if (_saveStyle == HCPCSaveStyleSaveAndCancel) {
        UIBarButtonItem *buttonItem;
        
        buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = buttonItem;
        
        buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_saveStyle == HCPCSaveStyleSaveAlways) {
        [self save:self];
    }
}

- (void)saveColor:(id)sender{
    [self save];
}

- (void)save
{
    if (self.delegate) {
        YJRRGBColor rgbColor = [colorPickerView RGBColor];
        [self.delegate setSelectedColor:[UIColor colorWithRed:rgbColor.r green:rgbColor.g blue:rgbColor.b alpha:1.0f] tag:self.tag];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save:(id)sender
{
    [self save];
}

- (void)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

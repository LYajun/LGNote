//
//  BaseViewController.m
//  NoteDemo
//
//  Created by hend on 2018/10/10.
//  Copyright © 2018年 hend. All rights reserved.
//

#import "LGNoteBaseViewController.h"


@interface LGNoteBaseViewController ()

@end

@implementation LGNoteBaseViewController

- (void)dealloc{
    NSLog(@"释放了： %@",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)dismissTopViewController:(BOOL)isDismissTopViewController{
    UIViewController *presentVC = self.presentingViewController;
    UIViewController *topViewController;
    if (isDismissTopViewController) {
        while (presentVC) {
            topViewController = presentVC;
            presentVC = presentVC.presentingViewController;
        }

        
          if([topViewController isKindOfClass:NSClassFromString(@"AIESideNavigationController")]||[topViewController isKindOfClass:NSClassFromString(@"RESideMenu")]){
            
            
            UIViewController * presentingViewController = self.presentingViewController;
            
              if([presentingViewController isKindOfClass:NSClassFromString(@"RESideMenu")]) {
                  [self dismissViewControllerAnimated:YES completion:nil];
                  return;
              }
              
            do {
                
                if ([presentingViewController isKindOfClass:NSClassFromString(@"LGTMNavigationViewController")]||[presentingViewController isKindOfClass:NSClassFromString(@"LGStuTabBarController")]||[presentingViewController isKindOfClass:NSClassFromString(@"AIESideNavigationController")]||[presentingViewController isKindOfClass:NSClassFromString(@"MFBaseNavigationController")]||[presentingViewController isKindOfClass:NSClassFromString(@"LGBaseNavigationController")]||[presentingViewController isKindOfClass:NSClassFromString(@"ETBaseNavigationController")]||
                    [presentingViewController isKindOfClass:NSClassFromString(@"TPFMenuViewController")]) {
                    
                    
                    break;
                }
                
                
                presentingViewController = presentingViewController.presentingViewController;
                
                
                
            } while (presentingViewController.presentingViewController);
            
            
            [presentingViewController dismissViewControllerAnimated:YES completion:nil];
            
            
            
            
        }else{
            
            
            [topViewController dismissViewControllerAnimated:YES completion:nil];
            
            
        }
        
        
        
       
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end

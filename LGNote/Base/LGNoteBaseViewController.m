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

        
        if([topViewController isKindOfClass:NSClassFromString(@"AIESideNavigationController")]){
            
            
            UIViewController * presentingViewController = self.presentingViewController;
            
            do {
                
                if ([presentingViewController isKindOfClass:NSClassFromString(@"LGTMNavigationViewController")]||[presentingViewController isKindOfClass:NSClassFromString(@"LGStuTabBarController")]||[presentingViewController isKindOfClass:NSClassFromString(@"AIESideNavigationController")]) {
                    
                    
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

@end

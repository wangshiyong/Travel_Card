//
//  MBProgress+HUD.m
//  Travel_Card
//
//  Created by 王世勇 on 2017/2/24.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "MBProgress+HUD.h"
#import "MBProgressHUD.h"
#import "UIImage+Tint.h"

@implementation UIViewController (HUD)

-(void)showHUD{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = WSY(@"Loading... ");
}

-(void)showStrHUD:(NSString *)str{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = str;
}

- (void)showHUDWindow {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    hud.labelText = WSY(@"Initializing...");
}

- (void)showHUDWindow: (NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    hud.labelText = str;
}

- (void)hideHUDWindow {
    [MBProgressHUD hideHUDForView:[[[UIApplication sharedApplication] delegate] window] animated:YES];
}

-(void)showHUDWithStr: (NSString *)str {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = str;
}

-(void)cleanHUD{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    hud.labelText = WSY(@"Cleaning...");
    [hud hide:YES afterDelay:2.f];
}

-(void)hideHUD{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)hideNaHUD {
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

-(void)showErrorHUD:(NSString *)str{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:@"N_error"] imageWithTintColor:[UIColor whiteColor]];
    hud.customView = [[UIImageView alloc] initWithImage:image];

    // Looks a bit nicer if we make it square.

    // Optional label text.
    hud.detailsLabelText = str;
    [hud hide:YES afterDelay:2.f];
}

-(void)showErrorHUDView:(NSString *)str{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:@"N_error"] imageWithTintColor:[UIColor whiteColor]];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    
    // Looks a bit nicer if we make it square.

    // Optional label text.
    hud.detailsLabelText = str;
    hud.detailsLabelFont = [UIFont systemFontOfSize:18];
    [hud hide:YES afterDelay:2.f];
}

//-(void)showErrorHUDWindow:(NSString *)str{
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
//
//    // Set the custom view mode to show any view.
//    hud.mode = MBProgressHUDModeCustomView;
//    // Set an image view with a checkmark.
//    UIImage *image = [[UIImage imageNamed:@"error"] imageWithTintColor:[UIColor whiteColor]];
//    hud.customView = [[UIImageView alloc] initWithImage:image];
//
//    // Looks a bit nicer if we make it square.
//
//    // Optional label text.
//    hud.labelText = str;
//    [hud hide:YES afterDelay:1.f];
//}

-(void)showSuccessHUD:(NSString *)str{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:@"N_success"] imageWithTintColor:[UIColor whiteColor]];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.labelText = str;
    [hud hide:YES afterDelay:1.f];
}

-(void)showSuccessHUDWindow:(NSString *)str{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:@"N_success"] imageWithTintColor:[UIColor whiteColor]];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.labelText = str;
    [hud hide:YES afterDelay:1.f];
}

-(void)showInfoFromTitle:(NSString *)str{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:@"N_info"] imageWithTintColor:[UIColor whiteColor]];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    
    // Looks a bit nicer if we make it square.
    
    // Optional label text.
    hud.labelText = str;
    [hud hide:YES afterDelay:2.f];
}

-(void)showInfoFromTitleWindow:(NSString *)str{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
    
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:@"N_info"] imageWithTintColor:[UIColor whiteColor]];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    
    // Looks a bit nicer if we make it square.
    
    // Optional label text.
    hud.detailsLabelText = str;
    hud.detailsLabelFont = [UIFont systemFontOfSize:18];
    [hud hide:YES afterDelay:2.f];
}



@end

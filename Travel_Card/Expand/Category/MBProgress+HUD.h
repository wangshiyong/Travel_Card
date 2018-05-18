//
//  MBProgress+HUD.h
//  Travel_Card
//
//  Created by 王世勇 on 2017/2/24.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (HUD)

-(void)showHUD;

-(void)showStrHUD:(NSString *)str;

- (void)showHUDWindow;

- (void)showHUDWindow: (NSString *)str;

- (void)hideHUDWindow;

-(void)showHUDWithStr: (NSString *)str;

-(void)cleanHUD;

-(void)hideHUD;

- (void)hideNaHUD;

-(void)showSuccessHUD:(NSString *)str;

-(void)showSuccessHUDWindow:(NSString *)str;

-(void)showErrorHUD:(NSString *)str;

-(void)showErrorHUDWindow:(NSString *)str;


-(void)showInfoFromTitleWindow:(NSString *)str;

-(void)showInfoFromTitle:(NSString *)str;

-(void)showErrorHUDView:(NSString *)str;

@end

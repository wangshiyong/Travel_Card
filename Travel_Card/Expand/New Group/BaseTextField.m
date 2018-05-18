//
//  BaseTextField.m
//  Travel_Card
//
//  Created by wangshiyong on 2018/1/15.
//  Copyright © 2018年 王世勇. All rights reserved.
//

#import "BaseTextField.h"

@implementation BaseTextField

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

@end

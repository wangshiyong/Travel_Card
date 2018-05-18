//
//  WSYSuperRootViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/20.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYSuperRootViewController.h"

@interface WSYSuperRootViewController ()

@end

@implementation WSYSuperRootViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYTabBarController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
}

@end

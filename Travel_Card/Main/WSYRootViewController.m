//
//  WSYRootViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/18.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYRootViewController.h"

@interface WSYRootViewController ()

@end

@implementation WSYRootViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYTabBarController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
}

@end

//
//  WSYTimeSelectViewController.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/14.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSYTimeSelectViewController : UIViewController

@property (nonatomic, strong) RACSubject *delegateSignal;

@property (nonatomic, assign) NSUInteger num;
@property (nonatomic, copy) NSString *startTimeStr;
@property (nonatomic, copy) NSString *endTimeStr;
@property (nonatomic, assign) BOOL standardTime;
//@property (nonatomic, copy) void (^NextViewControllerBlock)(NSString *tfText);

@end

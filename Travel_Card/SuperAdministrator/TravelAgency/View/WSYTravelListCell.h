//
//  WSYTravelListCell.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/16.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class WSYTravelListModel;

@interface WSYTravelListCell : MGSwipeTableCell

IB_DESIGNABLE

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *pwdName;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;
@property (weak, nonatomic) IBOutlet UIButton *dataBtn;
@property (weak, nonatomic) IBOutlet UILabel *totalLab;
@property (weak, nonatomic) IBOutlet UILabel *onlineLab;
@property (weak, nonatomic) IBOutlet UILabel *offlineLab;
@property (weak, nonatomic) IBOutlet UILabel *pwd;

@property(nonatomic) IBInspectable UIColor *rippleColor;
@property(nonatomic, strong) WSYTravelListModel *model;

@end

//
//  WSYTeamCell.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/17.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class WSYTeamListModel;

@interface WSYTeamCell : MGSwipeTableCell

IB_DESIGNABLE

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *pwd;
@property (weak, nonatomic) IBOutlet UILabel *totalLab;
@property (weak, nonatomic) IBOutlet UILabel *onlineLab;
@property (weak, nonatomic) IBOutlet UILabel *offLineLab;
@property (weak, nonatomic) IBOutlet UIButton *call;

@property(nonatomic) IBInspectable UIColor *rippleColor;

@property (strong, nonatomic) WSYTeamListModel *model;

@end

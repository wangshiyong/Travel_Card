//
//  WSYRailListCell.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/11/15.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class WSYRailListModel;

@interface WSYRailListCell : MDTableViewCell

@property(nonatomic, strong) UILabel *titleLab;
@property(nonatomic, strong) UILabel *subTitleLab;
//@property(nonatomic, strong) UISwitch *onOff;
@property(nonatomic, strong) UIView *containView;

@property (strong, nonatomic) WSYRailListModel *model;

@end

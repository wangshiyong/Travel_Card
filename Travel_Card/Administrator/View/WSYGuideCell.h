//
//  WSYGuideCell.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/19.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class WSYGuideListModel;

@interface WSYGuideCell : MGSwipeTableCell

IB_DESIGNABLE

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) UILabel *pwd;
@property (nonatomic, strong) UILabel *team;
@property (nonatomic, strong) UIButton *call;

@property(nonatomic) IBInspectable UIColor *rippleColor;

@property (strong, nonatomic) WSYGuideListModel *model;

@end

//
//  WSYManagerCell.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/10.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class WSYMemberListModel;

@interface WSYManagerCell : MGSwipeTableCell

IB_DESIGNABLE

@property (weak, nonatomic) IBOutlet UIButton *tsn;
@property (weak, nonatomic) IBOutlet UIButton *track;
@property (weak, nonatomic) IBOutlet UIButton *location;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@property(nonatomic) IBInspectable UIColor *rippleColor;

@property (nonatomic,strong) WSYMemberListModel *model;

@end

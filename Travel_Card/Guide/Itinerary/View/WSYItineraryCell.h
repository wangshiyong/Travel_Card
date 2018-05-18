//
//  WSYItineraryCell.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/9.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class WSYItineraryModel;
@interface WSYItineraryCell : MGSwipeTableCell

IB_DESIGNABLE

@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@property(nonatomic) IBInspectable UIColor *rippleColor;
@property (strong, nonatomic) WSYItineraryModel *model;

@end

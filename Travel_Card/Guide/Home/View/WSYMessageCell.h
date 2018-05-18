//
//  WSYMessageCell.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/12.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSYAlarmListModel;

@interface WSYMessageCell : MDTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tsnLab;
@property (weak, nonatomic) IBOutlet UILabel *sosLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;

@property (nonatomic, strong) WSYAlarmListModel *model;

@end

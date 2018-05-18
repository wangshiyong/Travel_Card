//
//  WSYUseListCell.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/12/4.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <MaterialControls/MaterialControls.h>
#import "YYText.h"

@class WSYUseListModel;

@interface WSYUseListCell : MDTableViewCell

//@property(nonatomic, strong) UILabel *leftLab;
//@property(nonatomic, strong) YYLabel *rightLab;
@property (weak, nonatomic) IBOutlet UILabel *leftLab;
@property (weak, nonatomic) IBOutlet YYLabel *rightLab;

@property (strong, nonatomic) NSMutableString *currentLanguage;

@property(nonatomic, strong) WSYUseListModel *model;

@end

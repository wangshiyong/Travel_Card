//
//  WSYMessageCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/12.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYMessageCell.h"
#import "WSYAlarmListModel.h"

@implementation WSYMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.rippleColor = kThemeRedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(WSYAlarmListModel *)model{
    _model = model;
    self.sosLab.text = _model.Content;
    if ([_model.Type  isEqual:@0]) {
        self.sosLab.textColor = [UIColor redColor];
        self.tsnLab.text = model.CodeMachine;
    }else if ([_model.Type  isEqual:@7]) {
        self.sosLab.textColor = [UIColor redColor];
        self.tsnLab.text = @"";
    }else if ([_model.Type  isEqual:@6]){
        self.sosLab.textColor = Color(107, 107, 107, 1);
        self.tsnLab.text = _model.CodeMachine;
        self.sosLab.text = WSY(@"Your device power is less than 20%. Please charge it in time.");
    } else {
        NSString *str = [_model.Content substringToIndex:_model.Content.length - 6];
        NSString *str1 = [_model.Content substringFromIndex:_model.Content.length - 6];
        if ([str1 hasPrefix:@"已出"]) {
            self.sosLab.text = [NSString stringWithFormat:@"%@%@",str,WSY(@"Has been out of the electronic fence")];
        } else {
            self.sosLab.text = [NSString stringWithFormat:@"%@%@",str,WSY(@"Has entered the electronic fence")];
        }
        self.sosLab.textColor = Color(107, 107, 107, 1);
        self.tsnLab.text = _model.CodeMachine;
    }
    self.timeLab.text = [WSYNSDateHelper getLocalDateFormateUTCDate:_model.CreateTime];
}

@end

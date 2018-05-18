//
//  WSYSuperInfoCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/16.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYSuperInfoCell.h"

@implementation WSYSuperInfoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.titleLab = [[UILabel alloc]init];
        self.titleLab.font = [UIFont systemFontOfSize:15.0];

        self.textField = [[UITextField alloc]init];
        self.textField.font = [UIFont systemFontOfSize:15.0];
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.contentView).offset(15);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.titleLab.mas_right);
        make.width.mas_equalTo(kScreenWidth - 150);
        make.height.mas_equalTo(30);
        make.centerY.equalTo(self.contentView);
    }];
}

@end

//
//  WSYNormalCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/28.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYNormalCell.h"

@implementation WSYNormalCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.title              = [[UILabel alloc]init];
        self.subtitle           = [[UILabel alloc]init];
        self.subtitle.textColor = [UIColor lightGrayColor];
        self.subtitle.font      = [UIFont systemFontOfSize:15];
        self.normalSwitch       = [[UISwitch alloc]init];
        
        [self addSubview:self.title];
        [self addSubview:self.subtitle];
        [self addSubview:self.normalSwitch];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    @weakify(self);
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self).offset(10);
        make.top.equalTo(self).offset(15);
        make.width.mas_equalTo(100);
    }];
    
    [self.subtitle mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self).offset(10);
        make.top.equalTo(self.title.mas_bottom).offset(10);
        make.right.equalTo(self).offset(-80);
    }];
    
    [self.normalSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-15);
    }];
}

@end

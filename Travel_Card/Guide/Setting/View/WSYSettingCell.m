//
//  WSYSettingCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/12.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYSettingCell.h"

@implementation WSYSettingCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.rightLab = [[UILabel alloc]init];
        self.rightLab.font = [UIFont systemFontOfSize:15.0];
        self.rightLab.textColor = [UIColor lightGrayColor];
        self.rightLab.textAlignment = NSTextAlignmentRight;
        
        [self.contentView addSubview:self.rightLab];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    @weakify(self);
    [self.rightLab mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.right.equalTo(self.contentView);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
        make.centerY.equalTo(self.contentView);
    }];
}

@end

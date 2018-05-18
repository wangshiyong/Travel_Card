//
//  WSYRailListCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/11/15.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYRailListCell.h"
#import "WSYRailListModel.h"

@implementation WSYRailListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.rippleColor           = kThemeRedColor;
        self.backgroundColor       = [UIColor groupTableViewBackgroundColor];
        
        self.titleLab              = [[UILabel alloc]init];
        self.subTitleLab           = [[UILabel alloc]init];
        self.subTitleLab.textColor = [UIColor lightGrayColor];
        self.subTitleLab.font      = [UIFont systemFontOfSize:15];
//        self.onOff                 = [[UISwitch alloc]init];
//        self.onOff.onTintColor     = kThemeRedColor;
        self.containView           = [[UIView alloc]init];
        self.containView.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.containView];
        [self.containView addSubview:self.titleLab];
        [self.containView addSubview:self.subTitleLab];
//        [self.containView addSubview:self.onOff];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    @weakify(self);
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 0, 0, 0));
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.containView).offset(20);
        make.top.equalTo(self.containView).offset(15);
        make.width.mas_equalTo(kScreenWidth - 40);
    }];
    
    [self.subTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.containView).offset(20);
        make.top.equalTo(self.titleLab.mas_bottom).offset(10);
        make.right.equalTo(self.containView).offset(-80);
    }];
    
//    [self.onOff mas_makeConstraints:^(MASConstraintMaker *make) {
//        @strongify(self);
//        make.centerY.equalTo(self.containView);
//        make.right.equalTo(self.containView).offset(-15);
//    }];
}

-(void)setModel:(WSYRailListModel *)model{
    _model = model;
    _titleLab.text = [NSString stringWithFormat:@"%@: %@",WSY(@"Name "),model.Name];
    if ([model.Type intValue] == 1) {
        _subTitleLab.text = WSY(@"Type: In");
    } else if ([model.Type intValue] == 2) {
        _subTitleLab.text = WSY(@"Type: Out");
    } else {
        _subTitleLab.text = WSY(@"Type: In/out");
    }
    
//    if ([model.enabled intValue] == 1) {
//        _onOff.on = YES;
//    } else {
//        _onOff.on = NO;
//    }
}

@end

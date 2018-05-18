//
//  WSYAboutHeadView.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/29.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYAboutHeadView.h"

@implementation WSYAboutHeadView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.iconImage = [[UIImageView alloc]init];
        self.versionLab = [[UILabel alloc]init];
        self.versionLab.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.iconImage];
        [self addSubview:self.versionLab];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    @weakify(self);
    [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(50);
        make.size.mas_equalTo(CGSizeMake(90, 90));
    }];
    
    [self.versionLab mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.centerX.equalTo(self);
        make.width.equalTo(self);
        make.top.equalTo(self.iconImage.mas_bottom).offset(20);
    }];
    
}

@end

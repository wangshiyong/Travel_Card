//
//  WSYAboutFootView.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/29.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYAboutFootView.h"

@implementation WSYAboutFootView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.companyLab = [[UILabel alloc]init];
        self.companyLab.textAlignment = NSTextAlignmentCenter;
        self.companyLab.font = [UIFont systemFontOfSize:12.0f];
        self.companyLab.textColor = [UIColor lightGrayColor];
        self.companyLab.text = WSY(@"©2017 Smart Guide Information Technology Co., Lt.");
        
        self.webBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.webBtn setTitle:WSY(@"Official Website") forState:UIControlStateNormal];
        [self.webBtn setTitleColor:Color(0, 178, 238, 1) forState:UIControlStateNormal];
        [self.webBtn addTarget:self action:@selector(webClicked) forControlEvents:UIControlEventTouchUpInside];
        self.webBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        
        
        [self addSubview:self.companyLab];
        [self addSubview:self.webBtn];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    @weakify(self);
    [self.companyLab mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.centerX.equalTo(self);
        make.width.equalTo(self);
        make.top.equalTo(self.mas_bottom).offset(-30);
    }];
    
    [self.webBtn mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(200);
        make.top.equalTo(self.mas_bottom).offset(-60);
    }];
    
}

- (void)webClicked {
    if ([self.delegate respondsToSelector:@selector(webClicked:)]) {
        [self.delegate webClicked:self];
    }
}
@end

//
//  WSYTrackHeadView.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/11.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYTrackHeadView.h"

@implementation WSYTrackHeadView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.timeLab = [[UILabel alloc]init];
        self.tsnLab = [[UILabel alloc]init];
        self.tsnLab.textAlignment = NSTextAlignmentRight;
        self.tsnLab.font = [UIFont systemFontOfSize:16.0];
     
        
        [self addSubview:self.timeLab];
        [self addSubview:self.tsnLab];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    
    [self.tsnLab mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(200, 30));
        
    }];
    
}

@end

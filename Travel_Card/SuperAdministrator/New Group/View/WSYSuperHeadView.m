//
//  WSYSuperHeadView.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/13.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYSuperHeadView.h"
#import "CircleProgressBar.h"

@interface WSYSuperHeadView()

@property (nonatomic, strong) UIView *headView;
//@property (nonatomic, strong) UILabel *startLab;
//@property (nonatomic, strong) UILabel *endLab;
@property (nonatomic, strong) CircleProgressBar *circle;

@end

@implementation WSYSuperHeadView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.startLab = [UILabel new];
        self.startLab.text = WSY(@"Start");
        self.startLab.font = [UIFont systemFontOfSize:12.0];
        self.startLab.textColor = [UIColor lightGrayColor];
        
        self.endLab = [UILabel new];
        self.endLab.text = WSY(@"End");
        self.endLab.font = [UIFont systemFontOfSize:12.0];
        self.endLab.textColor = [UIColor lightGrayColor];
        
        self.useNumLab = [YYLabel new];
        
        self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.startBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.startBtn setTitleColor:kThemeOrangeColor forState:UIControlStateNormal];
        [self.startBtn addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.endBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.endBtn setTitleColor:kThemeOrangeColor forState:UIControlStateNormal];
        [self.endBtn addTarget:self action:@selector(endAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.circle = [[CircleProgressBar alloc]init];
        [self.circle setProgress:1.0f animated:YES duration:2.0f];
        self.circle.backgroundColor = [UIColor whiteColor];
        self.circle.progressBarProgressColor = kThemeRedColor;
        self.circle.progressBarTrackColor = Color(230, 230, 230, 1);
        self.circle.progressBarWidth = 8.0;
        self.circle.startAngle = -90;
        self.circle.hintViewSpacing = 8.0;
        self.circle.hintTextFont = [UIFont systemFontOfSize:14.0];
        //    self.circle1.hintTextColor = [UIColor jk_colorWithHexString:@"0096db"];
        self.circle.hintViewBackgroundColor = kThemeRedColor;
        self.circle.hintHidden = YES;
        
        [self addSubview:self.circle];
        [self addSubview:self.startLab];
        [self addSubview:self.endLab];
        [self addSubview:self.startBtn];
        [self addSubview:self.endBtn];
        [self addSubview:self.useNumLab];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.startLab mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 15));
    }];
    
    [self.endLab mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.mas_centerX).offset(20);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 15));
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self.startLab.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth/2, 35));
    }];
    
    [self.endBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.mas_centerX).offset(20);
        make.top.equalTo(self.endLab.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth/2, 35));
    }];
    
    [self.circle mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(60);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [self.useNumLab mas_makeConstraints:^(MASConstraintMaker *make){
//        make.centerX.equalTo(self);
        make.top.equalTo(self.circle.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 40));
    }];
}

-(void)startAction{
    if ([self.delegate respondsToSelector:@selector(startBtnBeTouched:)]) {
        [self.delegate startBtnBeTouched:self];
    }
}

-(void)endAction{
    if ([self.delegate respondsToSelector:@selector(endBtnBeTouched:)]) {
        [self.delegate endBtnBeTouched:self];
    }
}

@end


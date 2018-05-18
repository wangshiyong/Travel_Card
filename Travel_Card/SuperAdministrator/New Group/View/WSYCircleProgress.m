//
//  WSYCircleProgress.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/12.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYCircleProgress.h"
#import "UIColor+JKHEX.h"

@interface WSYCircleProgress ()

//@property (nonatomic, strong) CircleProgressBar *circle1;
//@property (nonatomic, strong) CircleProgressBar *circle2;
//@property (nonatomic, strong) CircleProgressBar *circle3;
//@property (nonatomic, strong) UIView *view1;
//@property (nonatomic, strong) UIView *view2;
//@property (nonatomic, strong) UIView *view3;


@end

@implementation WSYCircleProgress

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCircles];
    }
    return self;
}

-(void)initCircles{
    self.circle1 = [[CircleProgressBar alloc]init];
    [self.circle1 setProgress:0.0f animated:YES duration:2.0f];
    self.circle1.backgroundColor = [UIColor whiteColor];
    self.circle1.progressBarProgressColor = kThemeRedColor;
    self.circle1.progressBarTrackColor = Color(230, 230, 230, 1);
    self.circle1.progressBarWidth = 8.0;
    self.circle1.startAngle = -90;
    self.circle1.hintViewSpacing = 8.0;
    self.circle1.hintTextFont = [UIFont systemFontOfSize:14.0];
//    self.circle1.hintTextColor = [UIColor jk_colorWithHexString:@"0096db"];
    self.circle1.hintViewBackgroundColor = kThemeRedColor;
    self.circle1.hintHidden = NO;
    [self addSubview:self.circle1];
    
//    self.view1 = [[UIView alloc]init];
//    self.view1.backgroundColor = [UIColor jk_colorWithHexString:@"0096db"];
//    self.view1.layer.cornerRadius = 5;
//    [self addSubview:self.view1];
//
//    self.view2 = [[UIView alloc]init];
//    self.view2.backgroundColor = kThemeRedColor;
//    self.view2.layer.cornerRadius = 5;
//    [self addSubview:self.view2];
//
//    self.view3 = [[UIView alloc]init];
//    self.view3.backgroundColor = Color(230, 230, 230, 1);
//    self.view3.layer.cornerRadius = 5;
//    [self addSubview:self.view3];

    self.lab1 = [[UILabel alloc]init];
    self.lab1.textColor = kThemeTextColor;
    self.lab1.text = @"总设备:0台";
    self.lab1.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:self.lab1];
//
//    self.lab2 = [[UILabel alloc]init];
//    self.lab2.textColor = kThemeTextColor;
//    self.lab2.text = @"在线设备:0台";
//    self.lab2.font = [UIFont systemFontOfSize:12.0];
//    [self addSubview:self.lab2];
//
//    self.lab3 = [[UILabel alloc]init];
//    self.lab3.textColor = kThemeTextColor;
//    self.lab3.text = @"离线设备:0台";
//    self.lab3.font = [UIFont systemFontOfSize:12.0];
//    [self addSubview:self.lab3];
//
//    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//    shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色为ClearColor
//    //设置线条的宽度和颜色
//    shapeLayer.lineWidth = 1.0f;
//    shapeLayer.strokeColor = Color(230, 230, 230, 1).CGColor;
//    //创建一个圆形贝塞尔曲线
//    UIBezierPath* aPath = [UIBezierPath bezierPath];
//    aPath.lineWidth = 5.0;
//    aPath.lineCapStyle = kCGLineCapRound; //线条拐角
//    aPath.lineJoinStyle = kCGLineCapRound; //终点处理
//    [aPath moveToPoint:CGPointMake(0, 120)];//设置初始点
//    //终点  controlPoint:切点（并不是拐弯处的高度，不懂的同学可以去看三角函数）
//    [aPath addQuadCurveToPoint:CGPointMake(kScreenWidth, 120) controlPoint:CGPointMake(kScreenWidth/2, 170)];
//
//    //将贝塞尔曲线设置为CAShapeLayer的path
//    shapeLayer.path = aPath.CGPath;
//    //将shapeLayer添加到视图的layer上
//    [self.layer addSublayer:shapeLayer];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.circle1 mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self).offset(-50);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
//    [self.view1 mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.equalTo(self.circle1.mas_right).offset(30);
//        make.bottom.equalTo(self.circle1.mas_centerY).offset(-15);
//        make.size.mas_equalTo(CGSizeMake(10, 10));
//    }];
    
//    [self.lab1 mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.equalTo(self.view1.mas_right).offset(5);
//        make.bottom.equalTo(self.circle1.mas_centerY).offset(-5);
//        make.size.mas_equalTo(CGSizeMake(150, 30));
//    }];
//
//    [self.view2 mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.equalTo(self.circle1.mas_right).offset(30);
//        make.centerY.equalTo(self.circle1);
//        make.size.mas_equalTo(CGSizeMake(10, 10));
//    }];
//    
//    [self.lab2 mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.equalTo(self.view1.mas_right).offset(5);
//        make.centerY.equalTo(self.circle1);
//        make.size.mas_equalTo(CGSizeMake(150, 30));
//    }];
//    
//    [self.view3 mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.equalTo(self.circle1.mas_right).offset(30);
//        make.top.equalTo(self.circle1.mas_centerY).offset(15);
//        make.size.mas_equalTo(CGSizeMake(10, 10));
//    }];
//    
//    [self.lab3 mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.equalTo(self.view1.mas_right).offset(5);
//        make.top.equalTo(self.circle1.mas_centerY).offset(5);
//        make.size.mas_equalTo(CGSizeMake(150, 30));
//    }];
}

@end

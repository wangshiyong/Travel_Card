//
//  WSYCalloutAnnotationView.m
//  Travel_Card
//
//  Created by 王世勇 on 2017/2/23.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYCalloutAnnotationView.h"
#import "WSYReleaseViewController.h"
#import "WSYCustomCalloutView.h"
#import "WSYAnnotation.h"
#import "WSYStringTool.h"

#define kSpacing 5
#define kDetailFontSize 12
//#define kViewOffset 80

@interface WSYCalloutAnnotationView(){
    UIView *_backgroundView;
    UILabel *_geoInfoLab;
    UILabel *_titleLabel;
    UILabel *_onlineTimeLab;
    UILabel *_gpsTimeLab;
    UIButton *_button;
    UIButton *_message;
    UIImageView *_image;
    UILabel *_batteryLab;
    UILabel *_stateLab;
    UILabel *_phone;
    NSString *tsn;
}

@end

@implementation WSYCalloutAnnotationView

@dynamic annotation;

-(instancetype)init{
    if(self=[super init]){
        [self layoutUI];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}

-(void)layoutUI{
    _backgroundView=[[WSYCustomCalloutView alloc]init];
    _backgroundView.layer.cornerRadius = 8.0;
    
    _geoInfoLab=[[UILabel alloc]init];
    _geoInfoLab.textColor = [UIColor blackColor];
    _geoInfoLab.lineBreakMode=NSLineBreakByWordWrapping;
    _geoInfoLab.numberOfLines = 0;
    _geoInfoLab.font=[UIFont systemFontOfSize:13];
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    
    _onlineTimeLab = [[UILabel alloc]init];
    _onlineTimeLab.textColor = [UIColor blackColor];
    _onlineTimeLab.font = [UIFont systemFontOfSize:13];
    
    _gpsTimeLab = [[UILabel alloc]init];
    _gpsTimeLab.textColor = [UIColor blackColor];
    _gpsTimeLab.font = [UIFont systemFontOfSize:13];
    
    _button = [[UIButton alloc]init];
    [_button setImage:[UIImage imageNamed:@"H_call"] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(call) forControlEvents:UIControlEventTouchUpInside];
    
    _message = [[UIButton alloc]init];
    [_message setImage:[UIImage imageNamed:@"H_message"] forState:UIControlStateNormal];
    [_message addTarget:self action:@selector(message) forControlEvents:UIControlEventTouchUpInside];
    
    _image = [[UIImageView alloc]init];
    _image.image = [UIImage imageNamed:@"H_electric"];
    
    _batteryLab = [[UILabel alloc]init];
    _batteryLab.textColor = [UIColor blackColor];
    _batteryLab.font = [UIFont systemFontOfSize:13];
    
    _stateLab = [[UILabel alloc]init];
    _stateLab.textColor = [UIColor blackColor];
    _stateLab.font = [UIFont systemFontOfSize:13];
    
    _barraryView = [[UIView alloc]init];
    
    
    _phone = [[UILabel alloc]init];
    tsn = [[NSString alloc]init];
    
    
    [self addSubview:_backgroundView];
    [_backgroundView addSubview:_geoInfoLab];
    [_backgroundView addSubview:_titleLabel];
    [_backgroundView addSubview:_batteryLab];
    [_backgroundView addSubview:_onlineTimeLab];
    [_backgroundView addSubview:_gpsTimeLab];
    [_backgroundView addSubview:_image];
    [_backgroundView addSubview:_stateLab];
    [_backgroundView addSubview:_barraryView];
    [_backgroundView addSubview:_phone];
    [_backgroundView addSubview:_button];
    [_backgroundView addSubview:_message];
}

+(instancetype)calloutViewWithMapView:(MAMapView *)mapView{
    static NSString *calloutKey=@"calloutKey";
    WSYCalloutAnnotationView *calloutView=(WSYCalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:calloutKey];
    if (!calloutView) {
        calloutView=[[WSYCalloutAnnotationView alloc]init];
    }
    return calloutView;
}

#pragma mark 当给大头针视图设置大头针模型时可以在此根据模型设置视图内容
-(void)setAnnotation:(WSYAnnotation *)annotation{
    [super setAnnotation:annotation];
    _memberID = [NSString stringWithFormat:@"%@",annotation.terminalID];
    _geoInfoLab.text = annotation.geoInfo;
    tsn = annotation.title;
    
    NSString *stateInfo = annotation.subtitle;
    if ([stateInfo isEqualToString:@"离线"]) {
        _titleLabel.text = [NSString stringWithFormat:@"%@    %@",annotation.title,WSY(@"Offline")];
    }else{
        _titleLabel.text = [NSString stringWithFormat:@"%@    %@",annotation.title,WSY(@"Online")];
    }
    _onlineTimeLab.text = [NSString stringWithFormat:@"%@: %@",WSY(@"Online time"),annotation.onlineTime];
    _gpsTimeLab.text = [NSString stringWithFormat:@"%@: %@",WSY(@"Position time"),annotation.gpsTime];
    if ([annotation.gpsState isEqualToString:@"GPS"]) {
        _stateLab.text =  WSY(@"BDS Positioning");
    } else if ([annotation.gpsState isEqualToString:@"LBS"]) {
        _stateLab.text =  WSY(@"LBS Positioning");
    } else {
        _stateLab.text =  WSY(@"RFID Positioning");
    }
    _phone.text = annotation.phone;

    if ([annotation.battery isEqualToString:@"充电"]) {
        _image.image = [UIImage imageNamed:@"H_electricize"];
        _batteryLab.text = [NSString stringWithFormat:@"%@",annotation.battery];
    }else{
        _batteryLab.text = [NSString stringWithFormat:@"%@%%",annotation.battery];
    }
    
    float detailWidth= kScreenWidth * 0.85;
    CGSize title = [annotation.title boundingRectWithSize:CGSizeMake(detailWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil].size;
//    CGSize detailSize= [annotation.geoInfo boundingRectWithSize:CGSizeMake(detailWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil].size;
    CGSize detailSize = [_geoInfoLab sizeThatFits:CGSizeMake(detailWidth, MAXFLOAT)];
    CGSize startTime= [annotation.onlineTime boundingRectWithSize:CGSizeMake(detailWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil].size;
    CGSize endTime= [annotation.gpsTime boundingRectWithSize:CGSizeMake(detailWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil].size;
    CGSize state = [annotation.gpsState boundingRectWithSize:CGSizeMake(detailWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil].size;
    CGSize barrary = [annotation.battery boundingRectWithSize:CGSizeMake(detailWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil].size;
    
    _titleLabel.frame = CGRectMake(8, 5, detailWidth * 0.8, title.height);
    _geoInfoLab.frame=CGRectMake(8, title.height + startTime.height + endTime.height + 26, detailWidth -16 , detailSize.height);
    _onlineTimeLab.frame = CGRectMake(8, title.height +23, detailWidth - 8, startTime.height);
    _gpsTimeLab.frame = CGRectMake(8, title.height + startTime.height + 24, detailWidth - 16, endTime.height);
    _button.frame = CGRectMake(detailWidth - 80, 5, 30, 30);
    _message.frame = CGRectMake(detailWidth - 40 , 5, 30, 30);
    _image.frame = CGRectMake(8, title.height + 9 , 20, 10);
    _batteryLab.frame = CGRectMake(30, title.height + 5, barrary.width +15 , barrary.height);
    _stateLab.frame = CGRectMake(55 + barrary.width , title.height + 5 , detailWidth - 55 + barrary.width, state.height);
    
    NSInteger num = [annotation.battery integerValue];
    _barraryView.frame = CGRectMake(9, title.height + 10, 16 * num/100, 8);
    if (num <= 20) {
        _barraryView.backgroundColor = [UIColor redColor];
    }else{
        _barraryView.backgroundColor = [UIColor greenColor];
    }
    float backgroundWidth = detailWidth;
    float backgroundHeight=_geoInfoLab.frame.size.height+_titleLabel.frame.size.height + _onlineTimeLab.frame.size.height +_gpsTimeLab.frame.size.height + _stateLab.frame.size.height + 26;
    _backgroundView.frame=CGRectMake(0, 0, detailWidth, backgroundHeight);
    self.bounds=CGRectMake(0, 0, backgroundWidth, backgroundHeight + 195 + _geoInfoLab.frame.size.height);
}

-(void)call{
//    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//    //        alert.shouldDismissOnTapOutside = YES;
////    [alert setHorizontalButtons:YES];
//    [alert addButton:@"单个游客行程发布" actionBlock:^(void) {
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"MemberRelease" object:[NSArray arrayWithObjects:_memberID,tsn, nil]];
//    }];
//    [alert addButton:@"拨打电话" actionBlock:^(void) {
//        [self callPhoneAction:_phone.text];
//    }];
//    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
//        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
//        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
//        return buttonConfig;
//    };
//    [alert showCustom:[UIImage imageNamed:@"H_call1"] color:kThemeRedColor title:@"通知联系方式" subTitle:nil closeButtonTitle:@"取消" duration:0.0f];
    [self callPhoneAction:_phone.text];
}

- (void)callPhoneAction:(NSString*)phoneStr
{
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneStr]];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:telURL options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:telURL];
    }
}

-(void)message{
    [[NSNotificationCenter defaultCenter]postNotificationName:kMemberRelease object:[NSArray arrayWithObjects:_memberID,tsn, nil]];
}


@end

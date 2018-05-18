//
//  WSYAnnotation.h
//  Travel_Card
//
//  Created by 王世勇 on 2017/2/23.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSYAnnotation : NSObject<MAAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

//标题和子标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

#pragma mark 大头针详情描述
@property (nonatomic,copy) NSString *battery;
@property (nonatomic,copy) NSString *geoInfo;
@property (nonatomic,copy) NSString *onlineTime;
@property (nonatomic,copy) NSString *gpsTime;
@property (nonatomic,copy) NSString *state;
@property (nonatomic,copy) NSString *gpsState;
@property (nonatomic,copy) NSString *phone;
@property (nonatomic,assign) NSNumber *terminalID;

@property (nonatomic,strong) UIImage *batteryImage;
@property (nonatomic,strong) UIImage *image;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end

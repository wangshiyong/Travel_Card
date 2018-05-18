//
//  WSYCalloutAnnotationView.h
//  Travel_Card
//
//  Created by 王世勇 on 2017/2/23.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "WSYCalloutAnnotation.h"

@interface WSYCalloutAnnotationView : MAAnnotationView

@property (nonatomic ,strong) WSYCalloutAnnotation *annotation;
@property (nonatomic, strong) UIView *barraryView;
@property (nonatomic, copy) NSString *memberID;

#pragma mark 从缓存取出标注视图
+(instancetype)calloutViewWithMapView:(MAMapView *)mapView;

@end

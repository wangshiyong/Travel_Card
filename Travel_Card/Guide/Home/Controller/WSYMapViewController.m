//
//  WSYMapViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/25.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYMapViewController.h"
#import "WSYMessageViewController.h"
#import "WSYCalloutAnnotationView.h"
#import "WSYRailListViewController.h"
#import "WSYLocationListModel.h"
#import "UIColor+JKHEX.h"
#import "WSYAnnotation.h"
#import "WSYNSDateHelper.h"
#import "WSYStringTool.h"
#import "POP.h"

static NSString *const kNumber = @"Number";

@interface WSYMapViewController () <MAMapViewDelegate,MDTabBarDelegate>{
    UIImageView *navBarHairlineImageView;
    NSTimer *timer;
    NSTimer *countTimer;
    int timeCount;
}

@property (nonatomic, strong) MDTabBar *segment;

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) WSYAnnotation  *customAnnotation;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) MATileOverlay *tileOverlay;

@property (nonatomic, strong) UIButton *location;
@property (nonatomic, strong) UIButton *refresh;
@property (nonatomic, strong) UIButton *rail;
@property (nonatomic, strong) UIButton *customRefresh;

@property (strong, nonatomic) NSMutableArray *animations;
@property (strong, nonatomic) NSMutableArray *onlineAnimations;
@property (strong, nonatomic) NSMutableArray *offlineAnimations;

@property (nonatomic, assign) BOOL isSwitching;

@end

@implementation WSYMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.segment];
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.location];
    [self.location mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.mas_offset(15);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(IS_IPHONE_X ? -109 : -75);
        make.width.height.mas_offset(45);
    }];
    
    [self.view addSubview:self.refresh];
    [self.refresh mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.mas_offset(15);
        make.bottom.mas_equalTo(self.location.mas_top).offset(-10);
        make.width.height.mas_offset(45);
    }];
    
    [self.view addSubview:self.rail];
    [self.rail mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.mas_offset(15);
        make.bottom.mas_equalTo(self.refresh.mas_top).offset(-10);
        make.width.height.mas_offset(45);
    }];
    
    [self.view addSubview:self.customRefresh];
    [self.customRefresh mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.view).offset(-15);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(IS_IPHONE_X ? -109 : -75);
        make.width.height.mas_offset(46);
    }];
    
    [self.mapView setZoomLevel:18];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;

    //去掉导航栏下划线
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    
    if ([[WSYUserDataTool getUserData:kFirstLaunchNotice] isEqualToString:@"1"]) {
        WSYMessageViewController *messageVc = [[WSYMessageViewController alloc]init];
        [self.navigationController pushViewController:messageVc animated:YES];
    }

    if ([[WSYUserDataTool getUserData:kForeign]isEqualToString:@"Foreign"]) {
        /* 删除之前的楼层. */
        [self.mapView removeOverlay:self.tileOverlay];
        /* 添加新的楼层. */
        self.tileOverlay = [self constructTileOverlayWithType:1];
        [self.mapView addOverlay:self.tileOverlay];
        
        [self.mapView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:[UIImageView class]]) {
                
                UIImageView * logoM = obj;
                
                logoM.layer.contents = (__bridge id)[UIImage imageNamed:@"H_Google"].CGImage;
            }
        }];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    navBarHairlineImageView.hidden = YES;
    [self showHUD];
    [self.mapView removeAnnotations:self.animations];
    [self.mapView removeAnnotations:self.offlineAnimations];
    [self.mapView removeAnnotations:self.onlineAnimations];
    [self.offlineAnimations removeAllObjects];
    [self.onlineAnimations removeAllObjects];
    [self.animations removeAllObjects];
    //获取全团定位数据
    [self getTeamLocation];
    [self timeRefresh];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    navBarHairlineImageView.hidden = NO;
    [self timeStop];
    [self hideHUD];
    
//    [self.mapView clearDisk];
//    self.mapView.delegate = nil;
//    self.mapView = nil;
//    [self.mapView removeFromSuperview];
}

//- (void)dealloc {
//    [self.mapView clearDisk];
//    [self.mapView removeFromSuperview];
//    self.mapView.delegate = nil;
//    self.mapView = nil;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ============点击事件============

- (IBAction)messageAction:(id)sender
{
    WSYMessageViewController *messageVc = [[WSYMessageViewController alloc]init];
    messageVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:messageVc animated:YES];
}

- (void)refreshClicked
{
    self.refresh.enabled = NO;
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat: M_PI *50];
    animation.duration = 10;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    [self.refresh.layer addAnimation:animation forKey:@"rotate"];
    
    [self.mapView removeAnnotations:self.animations];
    [self.mapView removeAnnotations:self.offlineAnimations];
    [self.mapView removeAnnotations:self.onlineAnimations];
    [self.offlineAnimations removeAllObjects];
    [self.onlineAnimations removeAllObjects];
    [self.animations removeAllObjects];
    //获取全团定位数据
    [self getTeamLocation];
}

- (void)locationClicked
{
    [self checkLocationServicesAuthorizationStatus];
}

- (void)railClicked
{
    WSYRailListViewController *railListVc = [[WSYRailListViewController alloc]init];
    railListVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:railListVc animated:YES];
}

-(void)timerFresh
{
    self.refresh.enabled = NO;
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat: M_PI *50];
    animation.duration = 10;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    [self.refresh.layer addAnimation:animation forKey:@"rotate"];
    
    //    [self hideHUD];
    [self.mapView removeAnnotations:self.animations];
    [self.animations removeAllObjects];
    [self getTeamLocation];
}

- (void)timeSelected
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//    [alert setHorizontalButtons:YES];
    @weakify(self);
    [alert addButton:@"30S" actionBlock:^(void) {
        @strongify(self);
        [self timeStop];
        [WSYUserDataTool setUserData:@"30" forKey:kRefreshNumber];
        [self timeRefresh];
        [self timerFresh];
    }];
    [alert addButton:@"40S" actionBlock:^(void) {
        @strongify(self);
        [self timeStop];
        [WSYUserDataTool setUserData:@"40" forKey:kRefreshNumber];
        [self timeRefresh];
        [self timerFresh];
    }];
    [alert addButton:@"50S" actionBlock:^(void) {
        @strongify(self);
        [self timeStop];
        [WSYUserDataTool setUserData:@"50" forKey:kRefreshNumber];
        [self timeRefresh];
        [self timerFresh];
    }];
    [alert addButton:@"60S" actionBlock:^(void) {
        @strongify(self);
        [self timeStop];
        [WSYUserDataTool setUserData:@"60" forKey:kRefreshNumber];
        [self timeRefresh];
        [self timerFresh];
    }];
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:self image:[UIImage imageNamed:@"H_time"] color:kThemeRedColor title:WSY(@"Refresh time") subTitle:WSY(@"Choose auto refresh time") closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}

#pragma mark - 检查授权状态
- (void)checkLocationServicesAuthorizationStatus
{
    
    [self reportLocationServicesAuthorizationStatus:[CLLocationManager authorizationStatus]];
}


- (void)reportLocationServicesAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusDenied)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:WSY(@"Location Service off") message:WSY(@"Please turn on the location service in settings") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:WSY(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:WSY(@"Setting") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];

    } else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        [self.mapView setZoomLevel:18];
        self.location.enabled = NO;
        
        NSDictionary *param = @{@"TravelGencyID":[WSYUserDataTool getUserData:kTravelGencyID],@"TouristTeamID":[WSYUserDataTool getUserData:kGuideID]};
        @weakify(self);
        [[WSYNetworkTool sharedManager]post:WSY_GET_TEAM_HAND params:param success:^(id responseBody) {
            @strongify(self);
            self.location.enabled = YES;
        } failure:^(NSError *error) {
            @strongify(self);
            self.location.enabled = YES;
        }];
    }
}

#pragma mark ============事件响应============
- (void)timeRefresh
{
    countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countChange) userInfo:nil repeats:YES];
    if ([self isNilOrEmpty:[WSYUserDataTool getUserData:kRefreshNumber]]) {
        timeCount = 60;
    }else {
        timeCount = [[WSYUserDataTool getUserData:kRefreshNumber] intValue];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:timeCount target:self selector:@selector(timerFresh) userInfo:nil repeats:YES];
}

- (void)timeStop
{
    [timer invalidate];
    [countTimer invalidate];
    countTimer = nil;
    timer = nil;
}

- (void)countChange
{
//    NSLog(@"%d====",timeCount);
    timeCount -= 1;
    if (timeCount == 0) {
        if ([self isNilOrEmpty:[WSYUserDataTool getUserData:kRefreshNumber]]) {
            timeCount = 60;
            [WSYUserDataTool setUserData:@"60" forKey:kRefreshNumber];
        }else {
            timeCount = [[WSYUserDataTool getUserData:kRefreshNumber] intValue];
        }
    }
    [_customRefresh setTitle:[NSString stringWithFormat:@"%d",timeCount] forState:UIControlStateNormal];
}

/** 获取全团定位数据 */
-(void)getTeamLocation
{
    NSDictionary *parameters = @{@"TravelGencyID":[WSYUserDataTool getUserData:kTravelGencyID],@"TouristTeamID":[WSYUserDataTool getUserData:kGuideID]};
    _animations = [NSMutableArray array];
    _onlineAnimations = [NSMutableArray array];
    _offlineAnimations = [NSMutableArray array];

    @weakify(self);
    [[WSYNetworkTool sharedManager]post:WSY_GET_TEAM_LOCATION params:parameters success:^(id responseBody) {
        @strongify(self);
        if ([responseBody[@"Code"] intValue] == 0) {
            NSArray *array = [WSYLocationListModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
            if (array.count == 0) {
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert showError:nil subTitle:WSY(@"No equipment in tour group, add in tourists management") closeButtonTitle:WSY(@"OK") duration:0.0f];
                //            [self.segment setItems:@[@"总设备[0]",@"在线设备[0]",@"离线设备[0]"]];
                NSString *str1 = [NSString stringWithFormat:@"%@[0]",WSY(@"Online ")];
                NSString *str2 = [NSString stringWithFormat:@"%@[0]",WSY(@"Offline ")];
                NSString *str3 = [NSString stringWithFormat:@"%@[0]",WSY(@"Total ")];
                [self.segment setItems:@[str1,str2,str3]];
                NSString *str = [WSYUserDataTool getUserData:kNumber];
                self.segment.selectedIndex = [str integerValue];
            }else{
                for(int i = 0; i < array.count; i++){
                    WSYLocationListModel * model = array[i];
                    double lo = [model.Lng doubleValue];
                    double la = [model.Lat doubleValue];
                    
                    if (lo == 0 && la == 0) {
                        self.coordinate = CLLocationCoordinate2DMake(30.60826, 104.06312);
                    }else{
                        if ([[WSYUserDataTool getUserData:kForeign]isEqualToString:@"Foreign"]) {
                            self.coordinate = CLLocationCoordinate2DMake(la, lo);
                        } else {
                            self. coordinate = AMapCoordinateConvert(CLLocationCoordinate2DMake(la, lo), AMapCoordinateTypeGPS);
                        }
                    }
                    
                    self.customAnnotation = [[WSYAnnotation alloc]initWithCoordinate:self.coordinate];
                    
                    if ([model.State intValue] == 0) {
                        self.customAnnotation.image=[UIImage imageNamed:@"H_offline"];
                        self.customAnnotation.subtitle = @"离线";
                        [self.offlineAnimations addObject:self.customAnnotation];
                    }else{
                        self.customAnnotation.image=[UIImage imageNamed:@"H_online"];
                        self.customAnnotation.subtitle = @"在线";
                        [self.onlineAnimations addObject:self.customAnnotation];
                    }
                    
                    self.customAnnotation.title = model.MemberName;
                    self.customAnnotation.phone = model.Tel;
                    self.customAnnotation.gpsState = model.GpsState;
                    
                    if ([model.Geo hasPrefix:@"出厂"]) {
                        self.customAnnotation.geoInfo = WSY(@"No location statistics, factory address default.");
                    } else {
                        self.customAnnotation.geoInfo = model.Geo;
                    }
                    
                    if ([model.Battery isEqualToNumber:@-1]) {
                        self.customAnnotation.battery = @"充电";
                    }else{
                        self.customAnnotation.battery = [NSString stringWithFormat:@"%@",model.Battery];
                    }
                    
                    if ([model.OnlineTime hasPrefix:@"0001"]) {
                        self.customAnnotation.onlineTime = WSY(@"No online time");
                    } else {
                        self.customAnnotation.onlineTime = [WSYNSDateHelper getLocalDateFormateUTCDate:model.OnlineTime];
                    }
                    
                    if ([model.GpsTime hasPrefix:@"0001"]) {
                        self.customAnnotation.gpsTime = WSY(@"No location time");
                    } else {
                        self.customAnnotation.gpsTime = [WSYNSDateHelper getLocalDateFormateUTCDate:model.GpsTime];
                    }
                    
                    self.customAnnotation.terminalID = model.MemberID;
                    
                    [self.animations addObject:self.customAnnotation];
                }
                [self.mapView addAnnotations:self.animations];
                
                
                NSString *str = [NSString stringWithFormat:@"%@[%lu]",WSY(@"Total "),(unsigned long)self.animations.count];
                NSString *str1 = [NSString stringWithFormat:@"%@[%lu]",WSY(@"Online "),(unsigned long)self.onlineAnimations.count];
                NSString *str2 = [NSString stringWithFormat:@"%@[%lu]",WSY(@"Offline "),(unsigned long)self.offlineAnimations.count];
                
                [self.segment setItems:@[str1, str2, str]];
                NSString *str3 = [WSYUserDataTool getUserData:kNumber];
                self.segment.selectedIndex = [str3 integerValue];
                
                if (self.segment.selectedIndex == 0) {
                    [self.mapView removeAnnotations:self.animations];
                    [self.mapView removeAnnotations:self.offlineAnimations];
                    [self.mapView addAnnotations:self.onlineAnimations];
                } else if (self.segment.selectedIndex == 1){
                    [self.mapView removeAnnotations:self.animations];
                    [self.mapView removeAnnotations:self.onlineAnimations];
                    [self.mapView addAnnotations:self.offlineAnimations];
                } else {
                    [self.mapView removeAnnotations:self.onlineAnimations];
                    [self.mapView removeAnnotations:self.offlineAnimations];
                    [self.mapView addAnnotations:self.animations];
                }
                
            }
        } else {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showError:nil subTitle:WSY(@"No equipment in tour group, add in tourists management") closeButtonTitle:WSY(@"OK") duration:0.0f];
            //            [self.segment setItems:@[@"总设备[0]",@"在线设备[0]",@"离线设备[0]"]];
            NSString *str1 = [NSString stringWithFormat:@"%@[0]",WSY(@"Online ")];
            NSString *str2 = [NSString stringWithFormat:@"%@[0]",WSY(@"Offline ")];
            NSString *str3 = [NSString stringWithFormat:@"%@[0]",WSY(@"Total ")];
            [self.segment setItems:@[str1,str2,str3]];
            NSString *str = [WSYUserDataTool getUserData:kNumber];
            self.segment.selectedIndex = [str integerValue];
        }
        self.refresh.enabled = YES;
        [self.refresh.layer removeAnimationForKey:@"rotate"];
        [self hideHUD];
    } failure:^(NSError *error) {
        @strongify(self);
        [self hideHUD];
        self.refresh.enabled = YES;
        [self.refresh.layer removeAnimationForKey:@"rotate"];
    }];
    
}

/** 去掉导航栏下划线 */
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view
{
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (BOOL)isNilOrEmpty:(NSString*)value
{
    if(value != nil && ![value isKindOfClass:[NSNull class]])
    {
        return value.length == 0;
    }
    return YES;
}

#pragma mark ============懒加载============

-(MAMapView *)mapView
{
    if (!_mapView)
    {
        _mapView = [[MAMapView alloc]initWithFrame:(CGRect){0, IS_IPHONE_X ? 124 : 100, kScreenWidth, kScreenHeight - (IS_IPHONE_X ? 207 : 149)}];
        _mapView.delegate = self;
        //加入annotation旋转动画后，暂未考虑地图旋转的情况。
        _mapView.rotateCameraEnabled = NO;
        _mapView.rotateEnabled = NO;
    }
    return _mapView;
}

- (MDTabBar *)segment
{
    if (!_segment) {
        _segment = [[MDTabBar alloc]initWithFrame:(CGRect){0, IS_IPHONE_X ? 88 : 64, kScreenWidth, 36}];
        _segment.delegate = self;
        _segment.backgroundColor = Color(249, 249, 249, 1);
        _segment.textColor = kThemeRedColor;
        _segment.normalTextColor = [UIColor lightGrayColor];
        _segment.indicatorColor = kThemeRedColor;
        _segment.rippleColor = kThemeRedColor;
    }
    return _segment;
}

- (UIButton *)refresh
{
    if (!_refresh) {
        _refresh = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refresh setImage:[UIImage imageNamed:@"H_refresh"] forState:UIControlStateNormal];
        [_refresh addTarget:self action:@selector(refreshClicked) forControlEvents:UIControlEventTouchUpInside];
        _refresh.layer.shadowOffset =  CGSizeMake(0, 5);
        _refresh.layer.shadowOpacity = 0.9;
        _refresh.layer.shadowColor = [UIColor jk_colorWithHexString:@"bababa"].CGColor;
    }
    return _refresh;
}

- (UIButton *)location
{
    if (!_location) {
        _location = [UIButton buttonWithType:UIButtonTypeCustom];
        [_location setImage:[UIImage imageNamed:@"H_location"] forState:UIControlStateNormal];
        [_location addTarget:self action:@selector(locationClicked) forControlEvents:UIControlEventTouchUpInside];
        _location.layer.shadowOffset =  CGSizeMake(0, 5);
        _location.layer.shadowOpacity = 0.9;
        _location.layer.shadowColor = [UIColor jk_colorWithHexString:@"bababa"].CGColor;
    }
    return _location;
}

- (UIButton *)rail
{
    if (!_rail) {
        _rail = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rail setImage:[UIImage imageNamed:@"H_rail"] forState:UIControlStateNormal];
        [_rail addTarget:self action:@selector(railClicked) forControlEvents:UIControlEventTouchUpInside];
        _rail.layer.shadowOffset =  CGSizeMake(0, 5);
        _rail.layer.shadowOpacity = 0.9;
        _rail.layer.shadowColor = [UIColor jk_colorWithHexString:@"bababa"].CGColor;
    }
    return _rail;
}

- (UIButton *)customRefresh
{
    if (!_customRefresh) {
        _customRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
        [_customRefresh setTitleColor:kThemeRedColor forState:UIControlStateNormal];
        [_customRefresh setBackgroundImage:[UIImage imageNamed:@"H_circle"] forState:UIControlStateNormal];
        [_customRefresh addTarget:self action:@selector(timeSelected) forControlEvents:UIControlEventTouchUpInside];
        _customRefresh.layer.shadowOffset =  CGSizeMake(0, 5);
        _customRefresh.layer.shadowOpacity = 0.9;
        _customRefresh.layer.shadowColor = [UIColor jk_colorWithHexString:@"bababa"].CGColor;
    }
    return _customRefresh;
}

#pragma mark ============MDTabBarDelegate============

- (void)tabBar:(MDTabBar *)tabBar didChangeSelectedIndex:(NSUInteger)selectedIndex
{
    NSLog(@"%lu===",(unsigned long)selectedIndex);
    NSString *str = [NSString stringWithFormat:@"%lu",(unsigned long)selectedIndex];
    [WSYUserDataTool setUserData:str forKey:kNumber];
    if (selectedIndex == 0) {
        [self.mapView removeAnnotations:self.animations];
        [self.mapView removeAnnotations:self.offlineAnimations];
        [self.mapView addAnnotations:self.onlineAnimations];
    }else if (selectedIndex == 1){
        [self.mapView removeAnnotations:self.animations];
        [self.mapView removeAnnotations:self.onlineAnimations];
        [self.mapView addAnnotations:self.offlineAnimations];
    }else{
        [self.mapView removeAnnotations:self.onlineAnimations];
        [self.mapView removeAnnotations:self.offlineAnimations];
        [self.mapView addAnnotations:self.animations];
    }
}

#pragma mark ============加载谷歌地图瓦片============
- (MATileOverlay *)constructTileOverlayWithType:(NSInteger)type
{
    MATileOverlay *tileOverlay = nil;
    tileOverlay = [[MATileOverlay alloc] initWithURLTemplate:kTileOverlayRemoteServerTemplate];
    
    /* minimumZ 是tileOverlay的可见最小Zoom值. */
    tileOverlay.minimumZ = kTileOverlayRemoteMinZ;
    /* minimumZ 是tileOverlay的可见最大Zoom值. */
    tileOverlay.maximumZ = kTileOverlayRemoteMaxZ;
    
    /* boundingMapRect 是用来 设定tileOverlay的可渲染区域. */
    tileOverlay.boundingMapRect = MAMapRectWorld;
    
    return tileOverlay;
}

#pragma mark ============MAMapViewDelegate============

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    //    [self.mapView selectAnnotation:annotation animated:YES];
    if ([annotation isKindOfClass:[WSYAnnotation class]]){
        static NSString *key1=@"WSYAnnotationKey";
        MAAnnotationView *annotationView=[_mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        if (!annotationView) {
            annotationView=[[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key1];
            //            annotationView.calloutOffset=CGPointMake(0, 100);//定义详情视图偏移量
        }
        
        annotationView.annotation=annotation;
        annotationView.image=((WSYAnnotation *)annotation).image;
        annotationView.centerOffset = CGPointMake(0, -22.5);
        
        return annotationView;
    } else if ([annotation isKindOfClass:[WSYCalloutAnnotation class]]) {
        WSYCalloutAnnotationView *calloutView=[WSYCalloutAnnotationView calloutViewWithMapView:mapView];
        calloutView.annotation = (id)annotation;
        return calloutView;
    } else {
        return nil;
    }
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    WSYAnnotation *annotation = (id)view.annotation;
    
    if ([annotation isKindOfClass:[WSYAnnotation class]]) {
        WSYCalloutAnnotation *calloutAnnotation=[[WSYCalloutAnnotation alloc]init];
        calloutAnnotation.coordinate=view.annotation.coordinate;
//        calloutAnnotation.state = annotation.state;
        calloutAnnotation.gpsState = annotation.gpsState;
        calloutAnnotation.onlineTime = annotation.onlineTime;
        calloutAnnotation.gpsTime = annotation.gpsTime;
        calloutAnnotation.title = annotation.title;
        calloutAnnotation.subtitle = annotation.subtitle;
        calloutAnnotation.phone = annotation.phone;
        calloutAnnotation.battery = annotation.battery;
        calloutAnnotation.terminalID = annotation.terminalID;
        view.centerOffset = CGPointMake(0, -25.875);
        if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[1]]) {
            calloutAnnotation.geoInfo = annotation.geoInfo;
            [mapView addAnnotation:calloutAnnotation];
            [self.mapView setCenterCoordinate:calloutAnnotation.coordinate];
            [UIView animateWithDuration:1.0 animations:^{
                // 移除动画
                [view.layer pop_removeAllAnimations];
                
                POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
                
                // 设置代理
                spring.delegate            = self;
                
                // 动画起始值 + 动画结束值
                spring.fromValue           = [NSValue valueWithCGSize:CGSizeMake(0.8f, 0.8f)];
                spring.toValue             = [NSValue valueWithCGSize:CGSizeMake(1.15f, 1.15f)];
                
                // 参数的设置
                spring.springSpeed         = 12.0;
                spring.springBounciness    = 4.0;
                spring.dynamicsMass        = 1.0;
                spring.dynamicsFriction    = 5.0;
                spring.dynamicsTension     = 200.0;
                
                // 执行动画
                [view.layer pop_addAnimation:spring forKey:nil];
            }completion:^(BOOL finished){
                [timer setFireDate:[NSDate distantFuture]];
                [countTimer setFireDate:[NSDate distantFuture]];
            }];

        }else{
            if(![[WSYUserDataTool getUserData:kForeign]isEqualToString:@"Foreign"]) {
                dispatch_group_t group = dispatch_group_create();
                NSString *str = [NSString stringWithFormat:@"20170629000060922%@1435660288EkUboF8P63ZDuob7ai4X",annotation.geoInfo];
                NSString *url = [NSString stringWithFormat:@"http://api.fanyi.baidu.com/api/trans/vip/translate?q=%@&from=zh&to=en&appid=20170629000060922&salt=1435660288&sign=%@",annotation.geoInfo,[str md5:str]];
                url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                dispatch_group_enter(group);
                [[WSYNetworkTool sharedManager]post:url params:nil successs:^(id responseBody) {
                    NSDictionary *dic = [responseBody[@"trans_result"] firstObject];
                    calloutAnnotation.geoInfo = dic[@"dst"];
                    dispatch_group_leave(group);
                } failure:^(NSError *error) {
                    dispatch_group_leave(group);
                }];
                
                dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                    [mapView addAnnotation:calloutAnnotation];
                    [self.mapView setCenterCoordinate:calloutAnnotation.coordinate];
                    [UIView animateWithDuration:1.0 animations:^{
                        // 移除动画
                        [view.layer pop_removeAllAnimations];
                        
                        POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
                        
                        // 设置代理
                        spring.delegate            = self;
                        
                        // 动画起始值 + 动画结束值
                        spring.fromValue           = [NSValue valueWithCGSize:CGSizeMake(0.8f, 0.8f)];
                        spring.toValue             = [NSValue valueWithCGSize:CGSizeMake(1.15f, 1.15f)];
                        
                        // 参数的设置
                        spring.springSpeed         = 12.0;
                        spring.springBounciness    = 4.0;
                        spring.dynamicsMass        = 1.0;
                        spring.dynamicsFriction    = 5.0;
                        spring.dynamicsTension     = 200.0;
                        
                        // 执行动画
                        [view.layer pop_addAnimation:spring forKey:nil];
                    }completion:^(BOOL finished){
                        [timer setFireDate:[NSDate distantFuture]];
                        [countTimer setFireDate:[NSDate distantFuture]];
                    }];
                });
            } else {
                calloutAnnotation.geoInfo = annotation.geoInfo;
                [mapView addAnnotation:calloutAnnotation];
                [self.mapView setCenterCoordinate:calloutAnnotation.coordinate];
                [UIView animateWithDuration:1.0 animations:^{
                    // 移除动画
                    [view.layer pop_removeAllAnimations];
                    
                    POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
                    
                    // 设置代理
                    spring.delegate            = self;
                    
                    // 动画起始值 + 动画结束值
                    spring.fromValue           = [NSValue valueWithCGSize:CGSizeMake(0.8f, 0.8f)];
                    spring.toValue             = [NSValue valueWithCGSize:CGSizeMake(1.15f, 1.15f)];
                    
                    // 参数的设置
                    spring.springSpeed         = 12.0;
                    spring.springBounciness    = 4.0;
                    spring.dynamicsMass        = 1.0;
                    spring.dynamicsFriction    = 5.0;
                    spring.dynamicsTension     = 200.0;
                    
                    // 执行动画
                    [view.layer pop_addAnimation:spring forKey:nil];
                }completion:^(BOOL finished){
                    [timer setFireDate:[NSDate distantFuture]];
                    [countTimer setFireDate:[NSDate distantFuture]];
                }];
            }
        }
    }
}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    view.centerOffset = CGPointMake(0, -22.5);
    [UIView animateWithDuration:0.5 animations:^{
        // 移除动画
        [view.layer pop_removeAllAnimations];
        
        POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        
        // 设置代理
        spring.delegate            = self;
        
        // 动画起始值 + 动画结束值
        spring.fromValue           = [NSValue valueWithCGSize:CGSizeMake(1.35f, 1.35f)];
        spring.toValue             = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
        
        // 参数的设置
        spring.springSpeed         = 12.0;
        spring.springBounciness    = 4.0;
        spring.dynamicsMass        = 1.0;
        spring.dynamicsFriction    = 5.0;
        spring.dynamicsTension     = 200.0;
        
        // 执行动画
        [view.layer pop_addAnimation:spring forKey:nil];
    }completion:^(BOOL finished){
        NSLog(@"%d====",timeCount);
        [timer setFireDate:[[NSDate alloc]initWithTimeIntervalSinceNow:timeCount]];
        [countTimer setFireDate:[[NSDate alloc]initWithTimeIntervalSinceNow:1]];
    }];
    
    [self removeCustomAnnotation];
}

-(void)removeCustomAnnotation
{
    [_mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[WSYCalloutAnnotation class]]) {
            [_mapView removeAnnotation:obj];
        }
    }];
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygonRenderer *polygonRenderer = [[MAPolygonRenderer alloc] initWithPolygon:(id)overlay];
        polygonRenderer.lineWidth   = 3.f;
        polygonRenderer.strokeColor = [UIColor colorWithRed:254/255.0 green:134/255.0 blue:24/255.0 alpha:0.5];
        polygonRenderer.fillColor   = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:103/255.0 alpha:0.4];
        
        return polygonRenderer;
    } else if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:(id)overlay];
        polylineView.lineWidth   = 5.f;
        polylineView.strokeImage = [UIImage imageNamed:@"M_arrowTexture"];
        //        polylineView.strokeColor = [UIColor colorWithRed:0 green:0.47 blue:1.0 alpha:0.9];
        return polylineView;
    } else if ([overlay isKindOfClass:[MAGroundOverlay class]])
    {
        MAGroundOverlayRenderer *groundOverlayView = [[MAGroundOverlayRenderer alloc]initWithGroundOverlay:(id)overlay];
        return groundOverlayView;
    } else if ([overlay isKindOfClass:[MATileOverlay class]])
    {
        MATileOverlayRenderer *renderer = [[MATileOverlayRenderer alloc] initWithTileOverlay:(id)overlay];
        return renderer;
    }
    return nil;
}

-(void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    //    掉落动画
    //    CGRect visibleRect = [mapView annotationVisibleRect];
    //    for (MAAnnotationView *view in views) {
    //        CGRect endFrame = view.frame;
    //        CGRect startFrame = endFrame;
    //        startFrame.origin.y = visibleRect.origin.y - startFrame.size.height;
    //        view.frame = startFrame;
    //        [UIView beginAnimations:@"drop" context:NULL];
    //        [UIView setAnimationDuration:1];
    //        view.frame = endFrame;
    //        [UIView commitAnimations];
    //    }
    
    for (MAAnnotationView *view in views) {
        // 移除动画
        [view.layer pop_removeAllAnimations];
        
        POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        
        // 设置代理
        spring.delegate            = self;
        
        // 动画起始值 + 动画结束值
        spring.fromValue           = [NSValue valueWithCGSize:CGSizeMake(0.7f, 0.7f)];
        spring.toValue             = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
        
        // 参数的设置
        spring.springSpeed         = 12.0;
        spring.springBounciness    = 4.0;
        spring.dynamicsMass        = 1.0;
        spring.dynamicsFriction    = 5.0;
        spring.dynamicsTension     = 200.0;
        
        // 执行动画
        [view.layer pop_addAnimation:spring forKey:nil];
    }
}

@end

//
//  WSYLocationViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/11.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYLocationViewController.h"
#import "WSYTimeSelectViewController.h"
#import "WSYCalloutAnnotationView.h"
#import "MovingAnnotationView.h"
#import "TracingPoint.h"
#import "WSYLocationModel.h"
#import "WSYAnnotation.h"
#import "WSYTrackListModel.h"
#import "Util.h"
#import "UIColor+JKHEX.h"
#import "WSYNSDateHelper.h"
#import "WSYStringTool.h"
#import "POP.h"

@interface WSYLocationViewController ()<MAMapViewDelegate> {
    CFTimeInterval _duration;
    NSTimer *timer;
    NSTimer *timerr;
    NSTimer *countTimer;
    int timeCount;
}

@property (nonatomic, strong) UIButton           *location;
@property (nonatomic, strong) UIButton           *refresh;
@property (nonatomic, strong) UIButton           *timeSelect;
@property (nonatomic, strong) UIButton           *customRefresh;

@property (nonatomic, strong) MAMapView          *mapView;
@property (nonatomic, strong) MAPointAnnotation  *car;
@property (nonatomic, strong) MAPolyline         *route;
@property (nonatomic, strong) WSYAnnotation      *customAnnotation;
@property (nonatomic, strong) MATileOverlay      *tileOverlay;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSDateFormatter    *dateFormatter;

@property (nonatomic, strong) NSMutableArray     *roadPointArr;
@property (nonatomic, strong) NSMutableArray     *tracking;
@property (nonatomic, strong) NSMutableArray     *routeAnno;
@property (nonatomic, strong) NSMutableArray     *lbsAnno;
@property (nonatomic, strong) NSMutableArray     *coordinates;
@property (strong, nonatomic) NSMutableArray     *animations;

@property (nonatomic, strong) NSMutableString    *startTime;
@property (nonatomic, strong) NSMutableString    *endTime;

@property (nonatomic, assign) BOOL               isLBSPoint;

@end

@implementation WSYLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mapView];
    
    [self.mapView setZoomLevel:18];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    
    if (_isTrack == YES) {
        self.navigationItem.title = WSY(@"Historical track");
        
        UIBarButtonItem *lbsButton = [[UIBarButtonItem alloc] initWithTitle:WSY(@"LBS") style:UIBarButtonItemStylePlain target:self action:@selector(lbsTrack)];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:WSY(@"Playback") style:UIBarButtonItemStylePlain target:self action:@selector(moving)];
        self.navigationItem.rightBarButtonItems = @[rightButton,lbsButton];
        
        [self.mapView addSubview:self.timeSelect];
        [self.timeSelect mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.mas_offset(15);
            if (IS_IPHONE_X) {
                make.top.mas_equalTo(self.view.mas_top).offset(102);
            } else {
                make.top.mas_equalTo(self.view.mas_top).offset(80);
            }
            make.width.height.mas_offset(40);
        }];

        _dateFormatter = [[NSDateFormatter alloc] init];
        NSDate *  senddate=[NSDate date];
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYY-MM-dd"];
        NSString *str=[dateformatter stringFromDate:senddate];
        _startTime = [NSMutableString stringWithString:str];
        [_startTime appendString:@" 00:00:00"];

        NSDate *  senddatee=[NSDate date];
        NSDateFormatter  *datee=[[NSDateFormatter alloc] init];
        [datee setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strr=[datee stringFromDate:senddatee];
        _endTime = [NSMutableString stringWithString:strr];
        _roadPointArr = [NSMutableArray array];
        //加载轨迹数据
        [self loadDataOfStartTime:_startTime endTime:_endTime];
        
    }else{
        self.navigationItem.title = WSY(@"Accurate positioning");
        
        if ([[WSYUserDataTool getUserData:kForeign] isEqualToString:@"Foreign"]) {
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
        
        [self.view addSubview:self.location];
        [self.location mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.mas_offset(15);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-30);
            make.width.height.mas_offset(40);
        }];
        
        [self.view addSubview:self.refresh];
        [self.refresh mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.mas_offset(15);
            make.bottom.mas_equalTo(self.location.mas_top).offset(-10);
            make.width.height.mas_offset(40);
        }];
        
        [self.view addSubview:self.customRefresh];
        [self.customRefresh mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.view).offset(-15);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-30);
            make.width.height.mas_offset(40);
        }];
        
        [self showHUD];
        //加载定位信息
        [self getLocation];
        
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isTrack == NO){
        //初始化定时器
        [self timeRefresh];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [timerr invalidate];
    timerr = nil;
    [timer invalidate];
    timer = nil;
    [countTimer invalidate];
    countTimer = nil;
}

#pragma mark ==========事件响应==========

- (void)timeRefresh
{
    countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countChange) userInfo:nil repeats:YES];
    if ([self isNilOrEmpty:[WSYUserDataTool getUserData:kRefreshNumber]]) {
        timeCount = 60;
    }else {
        timeCount = [[WSYUserDataTool getUserData:kRefreshNumber] intValue];
    }
    timerr = [NSTimer scheduledTimerWithTimeInterval:timeCount target:self selector:@selector(refeshTap) userInfo:nil repeats:YES];
}

- (void)timeStop
{
    [timerr invalidate];
    [countTimer invalidate];
    countTimer = nil;
    timerr = nil;
}

/**
 点击刷新
 */
- (void)refeshTap
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
    
    [self.mapView removeAnnotation:self.customAnnotation];
    [self getLocation];
}

/**
 选择时间
 */
- (void)timeTap
{
    WSYTimeSelectViewController *timeVc = [[WSYTimeSelectViewController alloc]init];
    timeVc.num = 2;
    timeVc.standardTime = YES;
    timeVc.delegateSignal = [RACSubject subject];
    [timeVc.delegateSignal subscribeNext:^(NSString *str){
        NSString *startStr = [NSString stringWithFormat:@"%@ 00:00:00",str];
        NSString *endStr = [NSString stringWithFormat:@"%@ 23:59:59",str];
        _startTime = [NSMutableString stringWithString:startStr];
        _endTime = [NSMutableString stringWithString:endStr];
        [self loadDataOfStartTime:_startTime endTime:_endTime];
    }];
    self.navigationItem.rightBarButtonItems[1].enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [_mapView removeAnnotation:_car];
    [_mapView removeAnnotations:_routeAnno];
    [_mapView removeAnnotations:_lbsAnno];
    [_mapView removeOverlay:_route];
    [timer invalidate];
    timer = nil;
    [self.navigationController pushViewController:timeVc animated:YES];
}

/**
 选择刷新时间
 */
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
    }];
    [alert addButton:@"40S" actionBlock:^(void) {
        @strongify(self);
        [self timeStop];
        [WSYUserDataTool setUserData:@"40" forKey:kRefreshNumber];
        [self timeRefresh];
    }];
    [alert addButton:@"50S" actionBlock:^(void) {
        @strongify(self);
        [self timeStop];
        [WSYUserDataTool setUserData:@"50" forKey:kRefreshNumber];
        [self timeRefresh];
    }];
    [alert addButton:@"60S" actionBlock:^(void) {
        @strongify(self);
        [self timeStop];
        [WSYUserDataTool setUserData:@"60" forKey:kRefreshNumber];
        [self timeRefresh];
    }];
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:self image:[UIImage imageNamed:@"H_time"] color:kThemeRedColor title:WSY(@"Refresh time") subTitle:WSY(@"Choose auto refresh time") closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}


- (BOOL)isNilOrEmpty:(NSString*)value
{
    if(value != nil && ![value isKindOfClass:[NSNull class]])
    {
        return value.length == 0;
    }
    return YES;
}

- (void)countChange
{
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

- (void)locationTap
{
    [self checkLocationServicesAuthorizationStatus];
}

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
        
        NSDictionary *param = @{@"MemberID":_ids,@"TouristTeamID":[WSYUserDataTool getUserData:kGuideID]};
        [[WSYNetworkTool sharedManager]post:WSY_GET_HAND_LOCATION params:param success:^(id responseBody) {
            self.location.enabled = YES;
        } failure:^(NSError *error) {
            self.location.enabled = YES;
        }];
    }
}

#pragma mark ============加载定位信息============

-(void)getLocation
{
    NSDictionary *param = @{@"TravelGencyID": [WSYUserDataTool getUserData:kTravelGencyID],@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID],@"MemberID": _ids};
    _animations = [NSMutableArray array];
    [[WSYNetworkTool sharedManager]post:WSY_GET_LOCATION params:param success:^(id responseBody) {
        [self hideHUD];
        if ([responseBody[@"Code"] intValue] == 0) {
            WSYLocationModel *model = [WSYLocationModel mj_objectWithKeyValues:responseBody[@"Data"]];
            double lo = [model.Lng doubleValue];
            double la = [model.Lat doubleValue];
            
            if (lo == 0 && la == 0) {
                _coordinate = CLLocationCoordinate2DMake(30.60826, 104.06312);
            }else{
                if ([[WSYUserDataTool getUserData:kForeign]isEqualToString:@"Foreign"]) {
                    self.coordinate = CLLocationCoordinate2DMake(la, lo);
                } else {
                    self. coordinate = AMapCoordinateConvert(CLLocationCoordinate2DMake(la, lo), AMapCoordinateTypeGPS);
                }
            }
            
            self.customAnnotation = [[WSYAnnotation alloc]initWithCoordinate:_coordinate];
            
            if ([model.State intValue] == 0) {
                self.customAnnotation.image=[UIImage imageNamed:@"H_offline"];
                self.customAnnotation.subtitle = @"离线";
            }else{
                self.customAnnotation.image=[UIImage imageNamed:@"H_online"];
                self.customAnnotation.subtitle = @"在线";
            }
            
            self.customAnnotation.title = model.MemberName;
            self.customAnnotation.phone = model.Tel;
            self.customAnnotation.gpsState = model.GpsState;
            self.customAnnotation.geoInfo = model.Geo;
            self.customAnnotation.onlineTime = [WSYNSDateHelper getLocalDateFormateUTCDate:model.OnlineTime];
            self.customAnnotation.gpsTime = [WSYNSDateHelper getLocalDateFormateUTCDate:model.GpsTime];
            
            NSString *battery = [NSString stringWithFormat:@"%@",model.Battery];
            if ([battery isEqualToString:@"-1"]) {
                self.customAnnotation.battery = @"充电";
            }else{
                self.customAnnotation.battery = battery;
            }
            
            [self.mapView addAnnotation:self.customAnnotation];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.mapView selectAnnotation:self.customAnnotation animated:YES];
            });
            
        } else {
            [self showInfoFromTitle:[NSString stringWithFormat:@"%@%@",_str,WSY(@"No location statistics")]];
        }
        self.refresh.enabled = YES;
        [self.refresh.layer removeAnimationForKey:@"rotate"];
    } failure:^(NSError *error) {
        [self hideHUD];
        [self.refresh.layer removeAnimationForKey:@"rotate"];
        self.refresh.enabled = YES;
    }];
    
}


#pragma mark ============懒加载============

- (MAMapView *)mapView
{
    if (!_mapView)
    {
        _mapView = ({
            MAMapView *mapView = [[MAMapView alloc]initWithFrame:({
                CGRect frame = (CGRect){0, (IS_IPHONE_X ? 88 : 64), kScreenWidth, kScreenHeight - (IS_IPHONE_X ? 88 : 64)};
                frame;
            })];
            mapView.delegate = self;
            //加入annotation旋转动画后，暂未考虑地图旋转的情况。
            mapView.rotateCameraEnabled = NO;
            mapView.rotateEnabled = NO;
            mapView;
        });
    }
    return _mapView;
}

- (UIButton *)refresh
{
    if (!_refresh) {
        _refresh = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refresh setImage:[UIImage imageNamed:@"H_refresh"] forState:UIControlStateNormal];
        [_refresh addTarget:self action:@selector(refeshTap) forControlEvents:UIControlEventTouchUpInside];
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
        [_location addTarget:self action:@selector(locationTap) forControlEvents:UIControlEventTouchUpInside];
        _location.layer.shadowOffset =  CGSizeMake(0, 5);
        _location.layer.shadowOpacity = 0.9;
        _location.layer.shadowColor = [UIColor jk_colorWithHexString:@"bababa"].CGColor;
    }
    return _location;
}

- (UIButton *)timeSelect
{
    if (!_timeSelect) {
        _timeSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeSelect setImage:[UIImage imageNamed:@"H_timeSelected"] forState:UIControlStateNormal];
        [_timeSelect addTarget:self action:@selector(timeTap) forControlEvents:UIControlEventTouchUpInside];
        _timeSelect.layer.shadowOffset =  CGSizeMake(0, 5);
        _timeSelect.layer.shadowOpacity = 0.9;
        _timeSelect.layer.shadowColor = [UIColor jk_colorWithHexString:@"bababa"].CGColor;
    }
    return _timeSelect;
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

#pragma mark ============加载轨迹============

- (void)loadDataOfStartTime:(NSString*)startTime endTime:(NSString*)endTime
{
    [self showHUD];
    NSDictionary *param = @{@"MemberID": _ids,
                            @"TerminalID": _terminalID,
                            @"StartTime": [WSYNSDateHelper getUTCFormateLocalDate:startTime],
                            @"EndTime": [WSYNSDateHelper getUTCFormateLocalDate:endTime],
                            @"Type":@1
                            };
    [[WSYNetworkTool sharedManager]post:WSY_GET_TRACE params:param success:^(id responseBody) {
        [self hideHUD];
        NSArray *userArray = [WSYTrackListModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
        
        if (userArray.count == 0) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self showInfoFromTitle:[NSString stringWithFormat:@"%@%@",_str,WSY(@"No historical track")]];

        } else {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            _coordinates = [NSMutableArray array];
            for(WSYTrackListModel *model in userArray) {
                NSString *coordinates = [NSString stringWithFormat:@"%@,%@",model.Lng,model.Lat];
                [_coordinates addObject:coordinates];
            }
            [self initAnnotation];
        }
    } failure:^(NSError *error) {
        [self hideHUD];
    }];
}

- (void)loadDataOfStartTimee:(NSString*)startTime endTimee:(NSString*)endTime
{
    [self showHUD];
    NSDictionary *param = @{@"MemberID": _ids,
                            @"TerminalID": _terminalID,
                            @"StartTime": [WSYNSDateHelper getUTCFormateLocalDate:startTime],
                            @"EndTime": [WSYNSDateHelper getUTCFormateLocalDate:endTime],
                            @"Type":@2
                            };
    [[WSYNetworkTool sharedManager]post:WSY_GET_TRACE params:param success:^(id responseBody) {
        [self hideHUD];
        NSArray *userArray = [WSYTrackListModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
        
        if (userArray.count == 0) {
            [self showInfoFromTitle:[NSString stringWithFormat:@"%@%@",_str,WSY(@"No LBS points")]];
            
        } else {
            _coordinates = [NSMutableArray array];
            for(WSYTrackListModel *model in userArray) {
                NSString *coordinates = [NSString stringWithFormat:@"%@,%@",model.Lng,model.Lat];
                [_coordinates addObject:coordinates];
            }
            _roadPointArr = [NSMutableArray arrayWithArray:_coordinates];
            
            CLLocationCoordinate2D * coords = malloc(_roadPointArr.count * sizeof(CLLocationCoordinate2D));
            for (NSInteger i = 0; i < _roadPointArr.count; i++) {
                
                NSArray *coordArrTotal = [_roadPointArr[i] componentsSeparatedByString:@","];
                if ([[WSYUserDataTool getUserData:kForeign]isEqualToString:@"Foreign"]) {
                    CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([coordArrTotal[1] doubleValue], [coordArrTotal[0] doubleValue]);
                    coords[i] = coord1;
                } else {
                    CLLocationCoordinate2D coord1 = AMapCoordinateConvert(CLLocationCoordinate2DMake([coordArrTotal[1] doubleValue], [coordArrTotal[0] doubleValue]), AMapCoordinateTypeGPS);
                    coords[i] = coord1;
                }
            }
            
            [self showLBSForCoords:coords count:_roadPointArr.count];
            
            if (coords) {
                free(coords);
            }
        }
    } failure:^(NSError *error) {
        [self hideHUD];
    }];
}

- (void)moving
{
    MovingAnnotationView * carView = (MovingAnnotationView *)[self.mapView viewForAnnotation:self.car];
    [carView addTrackingAnimationForPoints:_tracking duration:_duration];
    timer = [NSTimer scheduledTimerWithTimeInterval:_duration target:self selector:@selector(movingStop) userInfo:nil repeats:NO];
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)lbsTrack
{
    self.navigationItem.rightBarButtonItems[1].enabled = NO;
    [self loadDataOfStartTimee:_startTime endTimee:_endTime];
}

- (void)movingStop
{
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    [timer invalidate];
    timer = nil;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)initAnnotation
{
    if ([[WSYUserDataTool getUserData:kForeign] isEqualToString:@"Foreign"]) {
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
    [self initRoute];
    
    self.car = [[MAPointAnnotation alloc] init];
    TracingPoint * start = [_tracking firstObject];
    self.car.coordinate = start.coordinate;
    self.car.title = @"Car";
    [self.mapView addAnnotation:self.car];
}

- (void)initRoute
{
    _roadPointArr = [NSMutableArray arrayWithArray:_coordinates];
    
    if (_roadPointArr.count < 50) {
        _duration = 3;
    }else if (_roadPointArr.count < 100){
        _duration = 8;
    }else{
        _duration = 12;
    }
    CLLocationCoordinate2D * coords = malloc(_roadPointArr.count * sizeof(CLLocationCoordinate2D));
    for (NSInteger i = 0; i < _roadPointArr.count; i++) {
        
        NSArray *coordArrTotal = [_roadPointArr[i] componentsSeparatedByString:@","];
        if ([[WSYUserDataTool getUserData:kForeign]isEqualToString:@"Foreign"]) {
            CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([coordArrTotal[1] doubleValue], [coordArrTotal[0] doubleValue]);
            coords[i] = coord1;
        } else {
            CLLocationCoordinate2D coord1 = AMapCoordinateConvert(CLLocationCoordinate2DMake([coordArrTotal[1] doubleValue], [coordArrTotal[0] doubleValue]), AMapCoordinateTypeGPS);
            coords[i] = coord1;
        }
    }
    
    [self showRouteForCoords:coords count:_roadPointArr.count];
    [self initTrackingWithCoords:coords count:_roadPointArr.count];
    
    if (coords) {
        free(coords);
    }
}

- (void)showRouteForCoords:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    //show route
    _route = [MAPolyline polylineWithCoordinates:coords count:count];
    [self.mapView addOverlay:_route];
    
    _routeAnno = [NSMutableArray array];
    for (int i = 0 ; i < count; i++)
    {
        MAPointAnnotation * a = [[MAPointAnnotation alloc] init];
        a.coordinate = coords[i];
        if (i == 0) {
            a.title = @"startPoint";
        }else if(i == count - 1){
            a.title = @"endPoint";
        }else{
            a.title = @"route";
        }
        [_routeAnno addObject:a];
    }
    [self.mapView addAnnotations:_routeAnno];
    [self.mapView showAnnotations:_routeAnno animated:NO];
}

- (void)showLBSForCoords:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    
    _lbsAnno = [NSMutableArray array];
    for (int i = 0 ; i < count; i++)
    {
        MAPointAnnotation * a = [[MAPointAnnotation alloc] init];
        a.coordinate = coords[i];
        a.title = @"lbsPoint";
        [_lbsAnno addObject:a];
    }
    [self.mapView addAnnotations:_lbsAnno];
//    [self.mapView showAnnotations:_routeAnno animated:YES];
}

- (void)initTrackingWithCoords:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    _tracking = [NSMutableArray array];
    for (int i = 0; i<count - 1; i++)
    {
        TracingPoint * tp = [[TracingPoint alloc] init];
        tp.coordinate = coords[i];
        tp.course = [Util calculateCourseFromCoordinate:coords[i] to:coords[i+1]];
        [_tracking addObject:tp];
    }
        
    TracingPoint * tp = [[TracingPoint alloc] init];
    tp.coordinate = coords[count - 1];
    tp.course = ((TracingPoint *)[_tracking lastObject]).course;
    [_tracking addObject:tp];
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
    if ([annotation isKindOfClass:[WSYAnnotation class]]) {
        static NSString *key1 = @"WSYAnnotationKey";
        MAAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        if (!annotationView) {
            annotationView = [[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key1];
            //            annotationView.calloutOffset=CGPointMake(0, 100);//定义详情视图偏移量
        }
        
        annotationView.annotation = annotation;
        annotationView.image = ((WSYAnnotation *)annotation).image;
        annotationView.centerOffset = CGPointMake(0, -22.5);
        
        return annotationView;
        
    } else if ([annotation isKindOfClass:[WSYCalloutAnnotation class]]) {
        WSYCalloutAnnotationView *calloutView = [WSYCalloutAnnotationView calloutViewWithMapView:mapView];
        calloutView.annotation = (id)annotation;
        return calloutView;
        
    } else if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MovingAnnotationView *annotationView = (MovingAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[MovingAnnotationView alloc] initWithAnnotation:annotation
                                                              reuseIdentifier:pointReuseIndetifier];
        }
        
        if ([annotation.title isEqualToString:@"Car"]) {
            
            UIImage *imge  =  [UIImage imageNamed:@"M_userPosition"];
            annotationView.image =  imge;
            CGPoint centerPoint = CGPointZero;
            [annotationView setCenterOffset:centerPoint];
            
        } else if ([annotation.title isEqualToString:@"route"]) {
            
           annotationView.image = nil;
            
        } else if ([annotation.title isEqualToString:@"lbsPoint"]) {
            
            annotationView.image = [UIImage imageNamed:@"M_trackingPoints"];
            
        } else if ([annotation.title isEqualToString:@"startPoint"]) {
            
            annotationView.image = [UIImage imageNamed:@"M_startPoint"];
            
        } else if ([annotation.title isEqualToString:@"endPoint"]) {
            
            annotationView.image = [UIImage imageNamed:@"M_endPoint"];
            
        } else {
            annotationView.image = [UIImage imageNamed:@"M_blue"];
        }
        
        return annotationView;
    }
    return nil;
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
        calloutAnnotation.terminalID = self.ids;
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

            }];

        } else {
            if ([[WSYUserDataTool getUserData:kForeign]isEqualToString:@"Foreign"]) {
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

                }];
            } else {
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

                    }];
                    
                });
            }
        }
        
    }
    
}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    view.centerOffset = CGPointMake(0, -22.5);
    [UIView animateWithDuration:0.5 animations: ^{
        //        view.transform = CGAffineTransformScale(view.transform, 0.83333334, 0.83333334);
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
    } completion:^(BOOL finished) {

    }];
    [self removeCustomAnnotation];
}

- (void)removeCustomAnnotation
{
    [_mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[WSYCalloutAnnotation class]]) {
            [_mapView removeAnnotation:obj];
        }
    }];
}


- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:(id)overlay];
        polylineView.lineWidth   = 5.f;
        polylineView.strokeImage = [UIImage imageNamed:@"M_arrowTexture"];
//        polylineView.strokeColor = [UIColor colorWithRed:0 green:0.47 blue:1.0 alpha:0.9];
        return polylineView;
    } else if ([overlay isKindOfClass:[MATileOverlay class]]) {
        MATileOverlayRenderer *renderer = [[MATileOverlayRenderer alloc]initWithTileOverlay:(id)overlay];
        return renderer;
    }
    return nil;
}

//- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
//{
//    for (MAAnnotationView *view in views) {
//        // 移除动画
//        [view.layer pop_removeAllAnimations];
//        
//        POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//        
//        // 设置代理
//        spring.delegate            = self;
//        
//        // 动画起始值 + 动画结束值
//        spring.fromValue           = [NSValue valueWithCGSize:CGSizeMake(0.7f, 0.7f)];
//        spring.toValue             = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
//        
//        // 参数的设置
//        spring.springSpeed         = 12.0;
//        spring.springBounciness    = 4.0;
//        spring.dynamicsMass        = 1.0;
//        spring.dynamicsFriction    = 5.0;
//        spring.dynamicsTension     = 200.0;
//        
//        // 执行动画
//        [view.layer pop_addAnimation:spring forKey:nil];
//    }
//}

@end

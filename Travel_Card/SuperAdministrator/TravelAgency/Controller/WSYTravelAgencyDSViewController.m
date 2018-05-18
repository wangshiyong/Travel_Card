//
//  WSYTravelAgencyDSViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/16.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYTravelAgencyDSViewController.h"
#import "WSYTimeSelectViewController.h"
#import "WSYSuperHeadView.h"
#import "WSYLineOptions.h"
#import "WSYTimeDeviceModel.h"

@interface WSYTravelAgencyDSViewController ()<WSYButtonDelegete>{
    PYOption *option;
}

@property(nonatomic,strong) WSYSuperHeadView *headView;
@property (nonatomic, strong) WKEchartsView *kEchartView;
@property (nonatomic,strong) NSMutableString  *startTimeStr;
@property (nonatomic,strong) NSMutableString  *endTimeStr;
@property (nonatomic,strong) NSMutableString  *starttTimeStr;
@property (nonatomic,strong) NSMutableString  *enddTimeStr;
@property (nonatomic, strong) NSMutableArray *onlineArray;
@property (nonatomic, strong) NSMutableArray *offlineArray;
@property (nonatomic, strong) NSMutableArray *totalArray;
@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic,strong) NSDateFormatter  *dateFormatter;
@property (nonatomic,assign) BOOL isEndTime;

@end

@implementation WSYTravelAgencyDSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.name;
    
    //开始时间
    _dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *str=[dateformatter stringFromDate:senddate];
    self.startTimeStr = [NSMutableString stringWithString:str];
    [self.startTimeStr appendString:@" 00:00:00"];
    self.starttTimeStr = [NSMutableString stringWithString:self.startTimeStr];
    
    //结束时间
    self.endTimeStr = [NSMutableString stringWithString:str];
    [self.endTimeStr appendString:@" 23:59:59"];
    self.enddTimeStr = [NSMutableString stringWithString:self.endTimeStr];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.tableHeaderView = [self loadHeadView];
    
    @weakify(self);
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadNewData];
    }];
    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ==========初始化==========

- (UIView *)loadHeadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 53)];
    view.backgroundColor = [UIColor whiteColor];
    
    self.headView = [[WSYSuperHeadView alloc]initWithFrame:(CGRect){0, 0, kScreenWidth, 160}];
    [self.headView.startBtn setTitle:[self.startTimeStr substringToIndex:10] forState:UIControlStateNormal];
    [self.headView.endBtn setTitle:[self.endTimeStr substringToIndex:10] forState:UIControlStateNormal];
    self.headView.delegate = self;
    
    //    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"总使用次数:10000次"];
    //    text.yy_font = [UIFont systemFontOfSize:15.0f];
    //    text.yy_color = [UIColor lightGrayColor];
    //    [text yy_setColor:kThemeOrangeColor range:NSMakeRange(6, 5)];
    //    [text yy_setFont:[UIFont systemFontOfSize:28.0f] range:NSMakeRange(6, 5)];
    //
    //    self.headView.useNumLab.attributedText = text;
    //    self.headView.useNumLab.textAlignment = NSTextAlignmentCenter;
    [view addSubview:self.headView];
    
    self.kEchartView = [[WKEchartsView alloc]init];
    [view addSubview:self.kEchartView];
    [self.kEchartView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(view);
        make.right.equalTo(view.mas_right);
        make.top.equalTo(view).offset(184);
        make.height.mas_equalTo(kScreenHeight - 270);
    }];
    
    
    if (![[WSYUserDataTool getUserData:kTheme] isEqualToString:@""]) {
        [self.kEchartView setTheme:[WSYUserDataTool getUserData:kTheme]];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 1.0f;
    shapeLayer.strokeColor = Color(230, 230, 230, 1).CGColor;
    
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = 5.0;
    aPath.lineCapStyle = kCGLineCapRound; //线条拐角
    aPath.lineJoinStyle = kCGLineCapRound; //终点处理
    [aPath moveToPoint:CGPointMake(0, 150)];//设置初始点
    [aPath addQuadCurveToPoint:CGPointMake(kScreenWidth, 150) controlPoint:CGPointMake(kScreenWidth/2, 200)];
    shapeLayer.path = aPath.CGPath;
    [view.layer addSublayer:shapeLayer];
    
    return view;
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    @weakify(self);
    NSLog(@"%@====%@",self.startTimeStr,self.endTimeStr);
    NSDictionary *param = @{@"StartTime": [WSYNSDateHelper getUTCFormateLocalDate:self.startTimeStr],
                            @"EndTime": [WSYNSDateHelper getUTCFormateLocalDate:self.endTimeStr],
                            @"TravelAgencyID": self.travelGencyID};
    [[WSYNetworkTool sharedManager]post:WSY_TRAVEL_AGENCY_COUNT params:param success:^(id responseBody) {
        @strongify(self);
        if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[0]]) {
            NSString *str = [NSString stringWithFormat:@"%@:%@%@",WSY(@"Total use time"),responseBody[@"Data"],WSY(@"times")];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
            text.yy_font = [UIFont systemFontOfSize:15.0f];
            text.yy_color = [UIColor lightGrayColor];
            [text yy_setColor:kThemeOrangeColor range:NSMakeRange(15, (str.length - 20))];
            [text yy_setFont:[UIFont systemFontOfSize:28.0f] range:NSMakeRange(15, (str.length - 20))];
            
            self.headView.useNumLab.attributedText = text;
        } else {
            NSString *str = [NSString stringWithFormat:@"%@:%@%@",WSY(@"Total use time"),responseBody[@"Data"],WSY(@"times")];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
            text.yy_font = [UIFont systemFontOfSize:15.0f];
            text.yy_color = [UIColor lightGrayColor];
            [text yy_setColor:kThemeOrangeColor range:NSMakeRange(6, (str.length - 7))];
            [text yy_setFont:[UIFont systemFontOfSize:28.0f] range:NSMakeRange(6, (str.length - 7))];
            
            self.headView.useNumLab.attributedText = text;
        }
        self.headView.useNumLab.textAlignment = NSTextAlignmentCenter;
//        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
    
    NSDictionary *paramm = @{@"StartTime": [WSYNSDateHelper getUTCFormateLocalDate:self.starttTimeStr],
                             @"EndTime": [WSYNSDateHelper getUTCFormateLocalDate:self.enddTimeStr],
                             @"TravelAgencyID": self.travelGencyID};
    [[WSYNetworkTool sharedManager]post:WSY_GET_TEAM_ACCOUNT params:paramm success:^(id responseBody) {
        @strongify(self);
        [self.kEchartView clearEcharts];
        NSArray *array = [WSYTimeDeviceModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
        if (array.count == 0) {
            [self showInfoFromTitleWindow:WSY(@"No statistical data for the current time period")];
            [self.tableView.mj_header endRefreshing];
        } else {
            self.onlineArray = [NSMutableArray array];
            self.offlineArray = [NSMutableArray array];
            self.totalArray = [NSMutableArray array];
            self.timeArray = [NSMutableArray array];
            for (int i = 0; i < array.count; i++) {
                WSYTimeDeviceModel *model = array[i];
                [self.onlineArray addObject:model.OnlineCount];
                [self.offlineArray addObject:model.OfflineCount];
                [self.totalArray addObject:model.TotalCount];
                [self.timeArray addObject:[self transformTime:model.DateTime]];
                //                NSLog(@"%@=====",[WSYNSDateHelper getLocalDateFormateUTCDate:model.time]);
            }
            [self loadChartView];
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (NSString *)transformTime:(NSString *)time {
    NSString *timeStr = [NSString stringWithFormat:@"%d %@",[[time substringWithRange:NSMakeRange(11, 2)] intValue] + 8,WSY(@"o'clock")];
    return timeStr;
}

//加载折线图
- (void)loadChartView {
    NSString *subtitle = nil;
    NSNumber *value = nil;
    if (self.isEndTime == YES) {
        subtitle = [NSString stringWithFormat:@"%@",[self.enddTimeStr substringToIndex:10]];
    } else {
        subtitle = [NSString stringWithFormat:@"%@",[self.starttTimeStr substringToIndex:10]];
    }
    if (![[WSYUserDataTool getUserData:kTheme] isEqualToString:@""]) {
        [self.kEchartView setTheme:[WSYUserDataTool getUserData:kTheme]];
    }
    
    if (self.onlineArray.count >= 9) {
        value = @50;
    } else {
        value = @100;
    }
    option = [WSYLineOptions standardLineOptionWithSubtitle:subtitle withTimeArray:self.timeArray withTotalArray:self.totalArray withOnlineArray:self.onlineArray withOfflineArray:self.offlineArray withEndEqual:value];
    [self.kEchartView setOption:option];
    [self.kEchartView loadEcharts];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];
    });
}

#pragma mark ==========点击事件==========

- (void)showNewData {
    @weakify(self);
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadNewData];
    }];
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark ==========Table view data source==========

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark ==========WSYButtonDelegete==========

- (void)startBtnBeTouched:(id)sender {
    WSYTimeSelectViewController *timeVc = [WSYTimeSelectViewController new];
    timeVc.num = 0;
    timeVc.endTimeStr = [self.endTimeStr substringToIndex:10];
    timeVc.startTimeStr = [self.startTimeStr substringToIndex:10];
    timeVc.delegateSignal = [RACSubject subject];
    [timeVc.delegateSignal subscribeNext:^(NSString *str){
        [self.headView.startBtn setTitle:str forState:UIControlStateNormal];
        self.startTimeStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@ 00:00:00",str]];
        self.starttTimeStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@ 00:00:00",str]];
        self.enddTimeStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@ 23:59:59",str]];
        [self showNewData];
    }];
    //    timeVc.NextViewControllerBlock = ^(NSString *tfText){
    //        [self.headView.startBtn setTitle:tfText forState:UIControlStateNormal];
    //        [self.headView.endBtn setTitle:tfText forState:UIControlStateNormal];
    //
    //    };
    [self.navigationController pushViewController:timeVc animated:YES];
}

- (void)endBtnBeTouched:(id)sender {
    WSYTimeSelectViewController *timeVc = [WSYTimeSelectViewController new];
    timeVc.num = 1;
    timeVc.startTimeStr = [self.startTimeStr substringToIndex:10];
    timeVc.endTimeStr = [self.endTimeStr substringToIndex:10];
    timeVc.delegateSignal = [RACSubject subject];
    [timeVc.delegateSignal subscribeNext:^(NSString *str){
        [self.headView.endBtn setTitle:str forState:UIControlStateNormal];
        self.endTimeStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@ 23:59:59",str]];
        self.starttTimeStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@ 00:00:00",str]];
        self.enddTimeStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@ 23:59:59",str]];
        self.isEndTime = YES;
        [self showNewData];
    }];
    [self.navigationController pushViewController:timeVc animated:YES];
}


@end

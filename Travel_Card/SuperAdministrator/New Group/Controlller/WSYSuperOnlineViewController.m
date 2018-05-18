//
//  WSYSuperOnlineViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/13.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYSuperOnlineViewController.h"
#import "WSYTimeSelectViewController.h"
#import "DGActivityIndicatorView.h"
#import "WSYLineOptions.h"
#import "WSYTimeModel.h"

@interface WSYSuperOnlineViewController () {
    PYOption *option;
}

@property (nonatomic, strong) WKEchartsView *kEchartView;
@property (nonatomic,strong) NSMutableString  *startTimeStr;
@property (nonatomic,strong) NSMutableString  *endTimeStr;
@property (nonatomic, strong) NSMutableArray *onlineArray;
@property (nonatomic, strong) NSMutableArray *offlineArray;
@property (nonatomic, strong) NSMutableArray *totalArray;
@property (nonatomic, strong) NSMutableArray *timeArray;

@end

@implementation WSYSuperOnlineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self loadBarButtonItem];
    
    //主题切换通知
    @weakify(self);
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"theme" object:nil]subscribeNext:^(NSNotification *notification){
        @strongify(self);
        [self.kEchartView setTheme:notification.object];
    }];
    
    //开始时间
    NSDate *date=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *str=[dateformatter stringFromDate:date];
    self.startTimeStr = [NSMutableString stringWithString:str];
    [self.startTimeStr appendString:@" 00:00:00"];
    
    //结束时间
    self.endTimeStr = [NSMutableString stringWithString:str];
    [self.endTimeStr appendString:@" 23:59:59"];
    
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"timeSelect" object:nil]subscribeNext:^(id x){
        @strongify(self);
        [self timeItemTap];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadNewData
{
    @weakify(self);
    NSDictionary *param = @{@"StartTime": [WSYNSDateHelper getUTCFormateLocalDate:self.startTimeStr],@"EndTime": [WSYNSDateHelper getUTCFormateLocalDate:self.endTimeStr],@"TravelAgencyID": [WSYUserDataTool getUserData:kTravelGencyID]};
    [[WSYNetworkTool sharedManager]post:WSY_TRAVEL_TIME_SPAN params:param success:^(id responseBody) {
        @strongify(self);
        [self.kEchartView clearEcharts];
        NSArray *array = [WSYTimeModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
        if (array.count == 0) {
            [self showInfoFromTitleWindow:WSY(@"No statistical data for the current time period")];
            [self.tableView.mj_header endRefreshing];
        } else {
            self.onlineArray = [NSMutableArray array];
            self.offlineArray = [NSMutableArray array];
            self.totalArray = [NSMutableArray array];
            self.timeArray = [NSMutableArray array];
            for (int i = 0; i < array.count; i++) {
                WSYTimeModel *model = array[i];
                [self.onlineArray addObject:model.OnlineCount];
                [self.offlineArray addObject:model.OfflineCount];
                [self.totalArray addObject:model.TotalCount];
                [self.timeArray addObject:[self transformTime:model.DateTime]];
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

#pragma mark ==========初始化==========

- (void)loadBarButtonItem {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"N_Setting"] style:UIBarButtonItemStylePlain target:(WSYBaseNavigationViewController *)self.navigationController action:@selector(showMenu)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"M_Time"] style:UIBarButtonItemStylePlain target:self action:@selector(timeItemTap)];
}

//加载折线图
- (void)loadChartView {
    NSString *subtitle = nil;
    NSNumber *value = nil;
    subtitle = [NSString stringWithFormat:@"%@",[self.startTimeStr substringToIndex:10]];
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

- (void)timeItemTap {
    WSYTimeSelectViewController *timeVc = [[WSYTimeSelectViewController alloc]init];
    timeVc.num = 2;
    timeVc.delegateSignal = [RACSubject subject];
    @weakify(self);
    [timeVc.delegateSignal subscribeNext:^(NSString *str){
        self.startTimeStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@ 00:00:00",str]];
        self.endTimeStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@ 23:59:59",str]];
        self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self loadNewData];
        }];
        [self.tableView.mj_header beginRefreshing];
    }];
    [self.navigationController pushViewController:timeVc animated:YES];
}

#pragma mark ==========Table view data source==========

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kScreenHeight - 113;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    self.kEchartView = [[WKEchartsView alloc]init];
    [view addSubview:self.kEchartView];
    [self.kEchartView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(view).insets(UIEdgeInsetsMake(20, 0, 20, 0));
    }];
//    [self loadChartView];
    return view;
}

@end

//
//  WSYMessageViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/10.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYMessageViewController.h"
#import "WSYLocationViewController.h"
#import "WSYTimeSelectViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "WSYAlarmListModel.h"
#import "WSYMessageCell.h"
#import "WSYTrackHeadView.h"
#import "WSYStringTool.h"

@interface WSYMessageViewController ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (strong, nonatomic) NSMutableArray     *alarmArray;
@property (nonatomic, strong) NSMutableString    *starttime;
@property (nonatomic, strong) NSMutableString    *endtime;
@property (nonatomic, strong) NSMutableString    *time;
@property (nonatomic, assign) BOOL               isNowTime;
@property (strong, nonatomic) UIButton           *backTopButton;

@end

@implementation WSYMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = WSY(@"Alarm information");
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *str=[dateformatter stringFromDate:senddate];
    _starttime = [NSMutableString stringWithString:str];
    [_starttime appendString:@" 00:00:00"];
    
    //结束时间
    _endtime = [NSMutableString stringWithString:str];
    [_endtime appendString:@" 23:59:59"];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"WSYMessageCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    @weakify(self);
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"M_Time"] style:UIBarButtonItemStylePlain target:self action:@selector(timeTap)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    if (self.isNoticeMessage == YES) {
        UIBarButtonItem *barbtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"N_Back"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissVc)];
        self.navigationItem.leftBarButtonItem=barbtn;
    }
    
    [WSYUserDataTool removeUserData:kFirstLaunchNotice];
    
    [self setUpScrollToTopView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissVc
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)timeTap
{
    WSYTimeSelectViewController *timeVc = [[WSYTimeSelectViewController alloc]init];
    timeVc.num = 2;
    timeVc.standardTime = YES;
    timeVc.delegateSignal = [RACSubject subject];
    @weakify(self);
    [timeVc.delegateSignal subscribeNext:^(NSString *str){
        @strongify(self);
        self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self);
            NSString *startStr = [NSString stringWithFormat:@"%@ 00:00:00",str];
            NSString *endStr = [NSString stringWithFormat:@"%@ 23:59:59",str];
            self.starttime = [NSMutableString stringWithString:startStr];
            self.endtime = [NSMutableString stringWithString:endStr];
            self.isNowTime = YES;
            self.time = [NSMutableString stringWithString:str];
            [self loadData];
        }];
        [self.tableView.mj_header beginRefreshing];
    }];
    [self.navigationController pushViewController:timeVc animated:YES];
}

/** 滚回顶部 */
- (void)setUpScrollToTopView
{
    _backTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_backTopButton];
    [_backTopButton addTarget:self action:@selector(ScrollToTop) forControlEvents:UIControlEventTouchUpInside];
    [_backTopButton setImage:[UIImage imageNamed:@"M_GoBack"] forState:UIControlStateNormal];
    _backTopButton.hidden = YES;
    [self.tableView bringSubviewToFront:_backTopButton];
}

/**
 加载报警列表
 */
- (void)loadData
{
    
    @weakify(self);
    NSDictionary *param = @{@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID],@"StartTime": [WSYNSDateHelper getUTCFormateLocalDate:_starttime],@"EndTime": [WSYNSDateHelper getUTCFormateLocalDate:_endtime]};
    [[WSYNetworkTool sharedManager]post:WSY_GET_ALARM params:param success:^(id responseBody) {
        @strongify(self);
        NSArray *array = [WSYAlarmListModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
        if (array.count == 0) {
            [_alarmArray removeAllObjects];
            [self.tableView reloadData];
            self.tableView.emptyDataSetSource = self;
            self.tableView.emptyDataSetDelegate = self;
            [self.tableView reloadEmptyDataSet];
            [self.tableView.mj_header endRefreshing];
        }else{
            if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[0]]) {
                dispatch_group_t group = dispatch_group_create();
                for(int i= 0;i<array.count;i++){
                    __block WSYAlarmListModel *model = array[i];
                    if ([model.Content hasPrefix:@"呼救地址"]) {
                        dispatch_group_enter(group);
                        NSString *str = [NSString stringWithFormat:@"20170629000060922%@1435660288EkUboF8P63ZDuob7ai4X",model.Content];
                        NSString *url = [NSString stringWithFormat:@"http://api.fanyi.baidu.com/api/trans/vip/translate?q=%@&from=zh&to=en&appid=20170629000060922&salt=1435660288&sign=%@",model.Content,[str md5:str]];
                        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        [[WSYNetworkTool sharedManager]post:url params:nil successs:^(id responseBody) {
                            NSDictionary *dic = [responseBody[@"trans_result"] firstObject];
                            model.Content = dic[@"dst"];
                            model = array[i];
                            dispatch_group_leave(group);

                        }failure:^(NSError *error) {
                            dispatch_group_leave(group);
                        }];
                    }
                }
                dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                    self.alarmArray = [NSMutableArray arrayWithArray:array];
                    [self.tableView reloadData];
                    [self.tableView.mj_header endRefreshing];
                });
            } else {
                self.alarmArray = [NSMutableArray arrayWithArray:array];
                //            self.alarmArray = (NSMutableArray*)[[array reverseObjectEnumerator] allObjects];
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
            }
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark ============UIScrollViewDelegate============

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.backTopButton.hidden = (scrollView.contentOffset.y > kScreenHeight + 200) ? NO : YES;//判断回到顶部按钮是否隐藏
    self.backTopButton.frame  = CGRectMake(kScreenWidth - 80, self.tableView.contentOffset.y + kScreenHeight - (IS_IPHONE_X ? 80 : 80), 40, 40);
}

#pragma mark =============Table view滚回顶部=============
- (void)ScrollToTop
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark ============Table view data source============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.alarmArray.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 40;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    WSYTrackHeadView *headView = [[WSYTrackHeadView alloc]initWithFrame:(CGRect){0, 0, kScreenWidth, 40}];
//    if (self.isNowTime == YES) {
//        headView.timeLab.text = self.time;
//    } else {
//        NSDate *date=[NSDate date];
//        [_dateFormatter setDateFormat:@"YYYY-MM-dd"];
//        NSString *str = [_dateFormatter stringFromDate:date];
//        headView.timeLab.text = str;
//    }
//    return headView;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    WSYMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([WSYMessageCell class]) owner:nil options:nil] lastObject];
    }
    
    cell.model = self.alarmArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WSYAlarmListModel *model = self.alarmArray[indexPath.row];
    if (![[model.Type stringValue] isEqualToString:@"7"]) {
        WSYLocationViewController *locationVc = [[WSYLocationViewController alloc]init];
        locationVc.isTrack = NO;
        locationVc.ids = model.MemberID;
        [self.navigationController pushViewController:locationVc animated:YES];
    }
}

#pragma mark ============DZNEmptyDataSetSource Methods============

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    text = WSY(@"No information");
    
    font = [UIFont boldSystemFontOfSize:17.0];
    textColor = [UIColor grayColor];
    
    if (!text) {
        return nil;
    }
    
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"H_alarm1"];
}

#pragma mark ============DZNEmptyDataSetDelegate Methods============

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -64;
}

@end

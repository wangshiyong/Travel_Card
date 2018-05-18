//
//  WSYProviderListViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/13.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYProviderListViewController.h"
#import "WSYTimeSelectViewController.h"
#import "WSYSuperHeadView.h"
#import "WSYUseListCell.h"
#import "WSYUseListModel.h"

@interface WSYProviderListViewController ()<WSYButtonDelegete,UISearchResultsUpdating,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>{
    UIImageView *navBarHairlineImageView;
}

@property (nonatomic,strong) WSYSuperHeadView *headView;
@property (nonatomic,strong) NSMutableString  *startTimeStr;
@property (nonatomic,strong) NSMutableString  *endTimeStr;
@property (strong, nonatomic) NSMutableArray  *searchDataSource;
@property (nonatomic,strong) NSDateFormatter  *dateFormatter;
@property (strong,nonatomic) NSMutableArray   *data;
@property(nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) UIButton        *backTopButton;

@end

@implementation WSYProviderListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"N_Setting"] style:UIBarButtonItemStylePlain target:(WSYBaseNavigationViewController *)self.navigationController action:@selector(showMenu)];
    
    //去掉导航栏下划线
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.hidden = YES;
    
    //开始时间
    _dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *str=[dateformatter stringFromDate:senddate];
    self.startTimeStr = [NSMutableString stringWithString:str];
    [self.startTimeStr appendString:@" 00:00:00"];

    //结束时间
    self.endTimeStr = [NSMutableString stringWithString:str];
    [self.endTimeStr appendString:@" 23:59:59"];

    self.headView = [[WSYSuperHeadView alloc]initWithFrame:(CGRect){0, iOS11Later ? 56 : 44, kScreenWidth, 160}];
    [self.headView.startBtn setTitle:str forState:UIControlStateNormal];
    [self.headView.endBtn setTitle:str forState:UIControlStateNormal];
    self.headView.delegate = self;

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, iOS11Later ? 216 : 204)];
    [header addSubview:self.searchController.searchBar];
    [header addSubview:self.headView];
    self.tableView.tableHeaderView = header;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    @weakify(self);
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadNewData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    [self setUpScrollToTopView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/** 滚回顶部 */
- (void)setUpScrollToTopView
{
    _backTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_backTopButton];
    [_backTopButton addTarget:self action:@selector(ScrollToTop) forControlEvents:UIControlEventTouchUpInside];
    [_backTopButton setImage:[UIImage imageNamed:@"M_GoBack"] forState:UIControlStateNormal];
//    _backTopButton.hidden = YES;
    
    [self.tableView bringSubviewToFront:_backTopButton];
}

#pragma mark =============懒加载=============

- (UISearchController*)searchController
{
    if (!_searchController) {
        _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
        _searchController.dimsBackgroundDuringPresentation = NO;
        [_searchController.searchBar sizeToFit];
        _searchController.searchBar.barTintColor = [UIColor groupTableViewBackgroundColor];
        //        _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchController.searchResultsUpdater = self;
//        self.definesPresentationContext = YES;
//        _searchController.hidesNavigationBarDuringPresentation = NO;
        
        _searchController.searchBar.layer.borderWidth = 1;
        _searchController.searchBar.layer.borderColor = [[UIColor groupTableViewBackgroundColor] CGColor];
        
        [_searchController.searchBar setValue:WSY(@"Cancel") forKey:@"_cancelButtonText"];
        _searchController.searchBar.placeholder = WSY(@"Scenic spot service provider");
        _searchController.searchBar.backgroundColor = [UIColor whiteColor];
    }
    return _searchController;
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    @weakify(self);
    NSDictionary *param = @{@"StartTime": [WSYNSDateHelper getUTCFormateLocalDate:self.startTimeStr],@"EndTime": [WSYNSDateHelper getUTCFormateLocalDate:self.endTimeStr]};
    [[WSYNetworkTool sharedManager]post:WSY_TRAVEL_USE_ACCOUNT params:param success:^(id responseBody) {
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
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
    
    [[WSYNetworkTool sharedManager]post:WSY_GET_ACCOUNT_LIST params:param success:^(id responseBody) {
        @strongify(self);
        NSArray *array = [WSYUseListModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
        self.data = [NSMutableArray arrayWithArray:array];
        [self.tableView reloadData];
        
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)showNewData
{
    @weakify(self);
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadNewData];
    }];
    [self.tableView.mj_header beginRefreshing];
}


#pragma mark =============UIScrollViewDelegate=============
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _backTopButton.hidden = (scrollView.contentOffset.y > kScreenHeight - 250) ? NO : YES;//判断回到顶部按钮是否隐藏
    _backTopButton.frame  = CGRectMake(kScreenWidth - 70, self.tableView.contentOffset.y + kScreenHeight - (IS_IPHONE_X ? 204 : 170), 40, 40);
}

#pragma mark =============Table view滚回顶部=============
- (void)ScrollToTop
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.searchController.active) {
        return _data.count;
    }else{
        return _searchDataSource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    WSYUseListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WSYUseListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (!self.searchController.active) {
        cell.model = self.data[indexPath.row];
    }else{
        cell.model = self.searchDataSource[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark =============UISearchResultsUpdating=============

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if ([searchController.searchBar.text isEqualToString:@""]) {
        _searchDataSource = _data;
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.TravelAgencyName contains [cd]%@ ", searchController.searchBar.text];
        NSArray *array = [NSArray arrayWithArray:_data];
        _searchDataSource = (NSMutableArray *)[array filteredArrayUsingPredicate:predicate];
        if (_searchDataSource.count == 0) {
            self.tableView.emptyDataSetSource = self;
            self.tableView.emptyDataSetDelegate = self;
            [self.tableView reloadEmptyDataSet];
        }
    }
    [self.tableView reloadData];
}

#pragma mark ==========WSYButtonDelegete==========

- (void)startBtnBeTouched:(id)sender
{
    WSYTimeSelectViewController *timeVc = [WSYTimeSelectViewController new];
    timeVc.num = 0;
    timeVc.endTimeStr = [self.endTimeStr substringToIndex:10];
    timeVc.startTimeStr = [self.startTimeStr substringToIndex:10];
    timeVc.delegateSignal = [RACSubject subject];
    [timeVc.delegateSignal subscribeNext:^(NSString *str){
        [self.headView.startBtn setTitle:str forState:UIControlStateNormal];
        self.startTimeStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@ 00:00:00",str]];
        [self showNewData];
    }];
//    timeVc.NextViewControllerBlock = ^(NSString *tfText){
//        [self.headView.startBtn setTitle:tfText forState:UIControlStateNormal];
//        [self.headView.endBtn setTitle:tfText forState:UIControlStateNormal];
//
//    };
    [self.navigationController pushViewController:timeVc animated:YES];
    self.searchController.active = NO;
}

- (void)endBtnBeTouched:(id)sender
{
    WSYTimeSelectViewController *timeVc = [WSYTimeSelectViewController new];
    timeVc.num = 1;
    timeVc.startTimeStr = [self.startTimeStr substringToIndex:10];
    timeVc.endTimeStr = [self.endTimeStr substringToIndex:10];
    timeVc.delegateSignal = [RACSubject subject];
    [timeVc.delegateSignal subscribeNext:^(NSString *str){
        [self.headView.endBtn setTitle:str forState:UIControlStateNormal];
        self.endTimeStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@ 23:59:59",str]];
        [self showNewData];
    }];
    [self.navigationController pushViewController:timeVc animated:YES];
    self.searchController.active = NO;
}

#pragma mark ============DZNEmptyDataSetSource Methods============

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;

    NSMutableDictionary *attributes = [NSMutableDictionary new];

    text = WSY(@"No results found");

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
    return [UIImage imageNamed:@"M_search"];
}


@end

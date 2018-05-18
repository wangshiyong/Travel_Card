//
//  WSYTravelAgencyViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/16.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYTravelAgencyViewController.h"
#import "WSYTravelAgencyDSViewController.h"
#import "WSYSuperInfoViewController.h"
#import "WSYTravelListCell.h"
#import "WSYTravelListModel.h"
#import "UIColor+JKHEX.h"

@interface WSYTravelAgencyViewController ()<UISearchResultsUpdating,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property(nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray     *searchDataSource;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) UIButton *backTopButton;

@end

@implementation WSYTravelAgencyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, iOS11Later ? 56 : 44)];
    [header addSubview:self.searchController.searchBar];
    self.tableView.tableHeaderView = header;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"N_Setting"] style:UIBarButtonItemStylePlain target:(WSYBaseNavigationViewController *)self.navigationController action:@selector(showMenu)];
    
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

#pragma mark =============滚回顶部=============
- (void)setUpScrollToTopView
{
    _backTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_backTopButton];
    [_backTopButton addTarget:self action:@selector(ScrollToTop) forControlEvents:UIControlEventTouchUpInside];
    [_backTopButton setImage:[UIImage imageNamed:@"M_GoBack"] forState:UIControlStateNormal];
    _backTopButton.hidden = YES;

    [self.tableView bringSubviewToFront:_backTopButton];
}

#pragma mark =============数据处理相关=============
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    @weakify(self);
    NSDictionary *param = @{@"TravelAgencyID": [WSYUserDataTool getUserData:kTravelGencyID]};
    [[WSYNetworkTool sharedManager]post:WSY_TRAVEL_LIST params:param success:^(id responseBody) {
        @strongify(self);
        NSArray *array = [WSYTravelListModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
        if (array.count == 0) {
            [self.data removeAllObjects];
            [self.tableView reloadData];
            self.tableView.emptyDataSetSource = self;
            self.tableView.emptyDataSetDelegate = self;
            [self.tableView reloadEmptyDataSet];
        }else{
            self.data = [NSMutableArray arrayWithArray:array];
            [self.tableView reloadData];
        }
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark =============点击事件=============

- (IBAction)add:(id)sender
{
//    WSYSuperInfoViewController *infoVc = [[WSYSuperInfoViewController alloc]init];
//    infoVc.isAdd = YES;
//    [self.navigationController pushViewController:infoVc animated:YES];
}

- (void)call:(NSString*)phoneStr
{
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneStr]];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:telURL options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:telURL];
    }
}


#pragma mark =============懒加载=============

- (UISearchController*)searchController
{
    if (!_searchController) {
        _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
        _searchController.dimsBackgroundDuringPresentation = NO;
        [_searchController.searchBar sizeToFit];
        _searchController.searchBar.barTintColor = [UIColor groupTableViewBackgroundColor];
        // _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchController.searchResultsUpdater = self;
        // self.definesPresentationContext = YES;
        // _searchController.hidesNavigationBarDuringPresentation = YES;
        
        _searchController.searchBar.layer.borderWidth = 1;
        _searchController.searchBar.layer.borderColor = [[UIColor groupTableViewBackgroundColor] CGColor];
        
        [_searchController.searchBar setValue:WSY(@"Cancel") forKey:@"_cancelButtonText"];
        _searchController.searchBar.placeholder = WSY(@"Scenic spot service provider");
        _searchController.searchBar.backgroundColor = [UIColor whiteColor];
    }
    return _searchController;
}

#pragma mark =============UIScrollViewDelegate=============
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _backTopButton.hidden = (scrollView.contentOffset.y > kScreenHeight - 500) ? NO : YES;//判断回到顶部按钮是否隐藏
    _backTopButton.frame  = CGRectMake(kScreenWidth - 70, self.tableView.contentOffset.y + kScreenHeight - (IS_IPHONE_X ? 144 : 110), 40, 40);
}

#pragma mark =============Table view滚回顶部=============
- (void)ScrollToTop
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark =============Table view data source=============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.searchController.active) {
        return _data.count;
    }else{
        return _searchDataSource.count;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 56;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    return self.searchController.searchBar;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    WSYTravelListCell *cell = (WSYTravelListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[WSYTravelListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
//    cell.delegate = self;
    
    @weakify(self);
    if (!self.searchController.active) {
        @strongify(self);
        cell.model = self.data[indexPath.row];
        
        [[[cell.dataBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            WSYTravelAgencyDSViewController *travelVc = [[WSYTravelAgencyDSViewController alloc]init];
            travelVc.travelGencyID = cell.model.TravelGencyID;
            travelVc.name = cell.model.TravelGencyName;
            [self.navigationController pushViewController:travelVc animated:YES];
        }];
        
        //    [cell.callBtn.layer addSublayer:[UIColor setGradualChangingColor:<#(UIView *)#> fromColor:@"F76B1C" toColor:(NSString *)@"FBDA61"]];
        [[[cell.callBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            [self call:cell.model.DutyPhone];
        }];
    } else {
        @strongify(self);
        cell.model = self.searchDataSource[indexPath.row];
        
        [[[cell.dataBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            WSYTravelAgencyDSViewController *travelVc = [[WSYTravelAgencyDSViewController alloc]init];
            travelVc.travelGencyID = cell.model.TravelGencyID;
            travelVc.name = cell.model.TravelGencyName;
            [self.navigationController pushViewController:travelVc animated:YES];
        }];
        
        [[[cell.callBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            [self call:cell.model.DutyPhone];
        }];
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    WSYSuperInfoViewController *infoVc = [[WSYSuperInfoViewController alloc]init];
//    infoVc.isAdd = false;
//    [self.navigationController pushViewController:infoVc animated:YES];
}

#pragma mark =============UISearchResultsUpdating=============

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if ([searchController.searchBar.text isEqualToString:@""]) {
        _searchDataSource = _data;
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.TravelGencyName contains [cd]%@ ", searchController.searchBar.text];
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

#pragma mark =============删除操作=============
#pragma mark Swipe Delegate

//-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
//{
//    return YES;
//}
//
//-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
//             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
//{
//
//    swipeSettings.transition = MGSwipeTransition3D;
//    expansionSettings.buttonIndex = 0;
//
//    __weak WSYTravelAgencyViewController * me = self;
//    //    MailData * mail = [me mailForIndexPath:[self.tableView indexPathForCell:cell]];
//
//    if (direction == MGSwipeDirectionLeftToRight) {
//
//        expansionSettings.fillOnTrigger = NO;
//        expansionSettings.threshold = 2;
//        return @[[MGSwipeButton buttonWithTitle:@"右滑删除" backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0] padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
//
//            //            MailData * mail = [me mailForIndexPath:[me.tableView indexPathForCell:sender]];
//            //            mail.read = !mail.read;
//            //            [me updateCellIndicactor:mail cell:(WSYScheduleListCell*)sender];
//            [cell refreshContentView]; //needed to refresh cell contents while swipping
//
//            //change button text
//            //            [(UIButton*)[cell.leftButtons objectAtIndex:0] setTitle:[me readButtonText:mail.read] forState:UIControlStateNormal];
//
//            return YES;
//        }]];
//    }
//    else {
//
//        expansionSettings.fillOnTrigger = YES;
//        expansionSettings.threshold = 1.1;
//
//        CGFloat padding = 15;
//
//        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor colorWithRed:1.0 green:59/255.0 blue:50/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
//            NSIndexPath * indexPath = [me.tableView indexPathForCell:sender];
//            //            ScheduleListModel *model = _listArray[indexPath.row];
//            //            NSDictionary *param = @{@"teamID": [WSYUserDataTool getUserData:kGuideID],@"tripID":model.ids};
//            SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
//            [alert setHorizontalButtons:YES];
//
//            [alert addButton:@"确定" actionBlock:^(void) {
//
//            }];
//
//
//            alert.completeButtonFormatBlock = ^NSDictionary* (void) {
//                NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
//                buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
//                return buttonConfig;
//            };
//
//
//            [alert showCustom:[UIImage imageNamed:@"T_delAdministrator"] color:kThemeRedColor title:@"景区服务商删除" subTitle:@"确定删除当前景区服务商？" closeButtonTitle:@"取消" duration:0.0f];
//
//            //            [_listArray removeObjectAtIndex:indexPath.row];//移除数据源的数据
//            //            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//            return YES; //don't autohide to improve delete animation
//        }];
//
//        return @[trash];
//    }
//
//    return nil;
//
//}

#pragma mark ============DZNEmptyDataSetSource Methods============

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    if (_searchController.active) {
        text = WSY(@"No results found");
    }else{
        text = WSY(@"No scenic spot service provider");
    }
    
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
    if (!_searchController.active) {
        return [UIImage imageNamed:@"M_device"];
    }else{
        return [UIImage imageNamed:@"M_search"];
    }
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

//
//  WSYTeamViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/17.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYTeamViewController.h"
#import "WSYTeamInfoViewController.h"
#import "WSYGuideViewController.h"
#import "WSYTeamListModel.h"
#import "WSYTeamCell.h"

@interface WSYTeamViewController ()<MGSwipeTableCellDelegate,UISearchResultsUpdating,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource>

@property(nonatomic, strong) UISearchController *searchController;
@property(nonatomic, strong) NSMutableArray *teamArray;
@property(nonatomic, strong) NSMutableArray *searchDataSource;

@end

@implementation WSYTeamViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupTableView];
    [self setupnavigationItem];
    
    @weakify(self);
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadNewData];
    }];
    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableView
{

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, iOS11Later ? 56 : 44)];
    [header addSubview:self.searchController.searchBar];
    self.tableView.tableHeaderView = header;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.backgroundView = [[UIView alloc] init];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}

- (void)setupnavigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"N_Setting"] style:UIBarButtonItemStylePlain target:(WSYBaseNavigationViewController *)self.navigationController action:@selector(showMenu)];
//    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTeam)];
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"A_Guide"] style:UIBarButtonItemStylePlain target:self action:@selector(enterGuideList)];
//    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: nextButton,addButton,nil]];
}

- (void)loadNewData
{
    @weakify(self);
    NSDictionary *param = @{@"TravelAgencyID": [WSYUserDataTool getUserData:kTravelGencyID]};
    [[WSYNetworkTool sharedManager]post:WSY_TOURIST_LIST params:param success:^(id responseBody) {
        @strongify(self);
        NSArray *array = [WSYTeamListModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
        if (array.count == 0) {
            [self.teamArray removeAllObjects];
            [self.tableView reloadData];
            self.tableView.emptyDataSetSource = self;
            self.tableView.emptyDataSetDelegate = self;
            [self.tableView reloadEmptyDataSet];
        }else{
            self.teamArray = [NSMutableArray arrayWithArray:array];
            [self.tableView reloadData];
        }
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark =============点击事件=============

/**
 添加导游
 */
- (void)addTeam
{
    WSYTeamInfoViewController *infoVc = [[WSYTeamInfoViewController alloc]init];
    infoVc.isAdd = YES;
    [self.navigationController pushViewController:infoVc animated:YES];
}


/**
 进入导游列表
 */
- (void)enterGuideList
{
    WSYGuideViewController *guideVc = [[WSYGuideViewController alloc]init];
    [self.navigationController pushViewController:guideVc animated:YES];
}

- (void)call:(NSString*)phoneStr
{
    [self callPhoneAction:phoneStr];
}

- (void)callPhoneAction:(NSString *)phoneStr
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
        //        _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchController.searchResultsUpdater = self;
        //        self.definesPresentationContext = YES;
        //        _searchController.hidesNavigationBarDuringPresentation = YES;
        
        _searchController.searchBar.layer.borderWidth = 1;
        _searchController.searchBar.layer.borderColor = [[UIColor groupTableViewBackgroundColor] CGColor];
        
        [_searchController.searchBar setValue:WSY(@"Cancel") forKey:@"_cancelButtonText"];
        _searchController.searchBar.placeholder = WSY(@"Tour Group");
        _searchController.searchBar.backgroundColor = [UIColor whiteColor];
    }
    return _searchController;
}

#pragma mark =============Table view data source=============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.searchController.active) {
        return _teamArray.count;
    }else{
        return _searchDataSource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    WSYTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WSYTeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
//    cell.delegate = self;
    @weakify(self);
    if (!self.searchController.active) {
        cell.model = self.teamArray[indexPath.row];
        
        [[[cell.call rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            @strongify(self);
            [self call:cell.model.GuidPhone];
        }];
    } else {
        cell.model = self.searchDataSource[indexPath.row];
        
        [[[cell.call rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            @strongify(self);
            [self call:cell.model.GuidPhone];
        }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//#pragma mark =============删除操作=============
//#pragma mark Swipe Delegate
//
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
//    __weak WSYTeamViewController * me = self;
//
//    if (direction == MGSwipeDirectionLeftToRight) {
//
//        expansionSettings.fillOnTrigger = NO;
//        expansionSettings.threshold = 2;
//        return @[[MGSwipeButton buttonWithTitle:@"右滑删除" backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0] padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
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
//
//
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
//            [alert showCustom:[UIImage imageNamed:@"A_delTeam"] color:kThemeRedColor title:@"旅游团删除" subTitle:@"确定删除当前旅游团？" closeButtonTitle:@"取消" duration:0.0f];
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

#pragma mark =============UISearchResultsUpdating=============

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if ([searchController.searchBar.text isEqualToString:@""]) {
        _searchDataSource = _teamArray;
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.TouristTeamName contains [cd]%@ ", searchController.searchBar.text];
        NSArray *array = [NSArray arrayWithArray:_teamArray];
        _searchDataSource = (NSMutableArray *)[array filteredArrayUsingPredicate:predicate];
        if (_searchDataSource.count == 0) {
            self.tableView.emptyDataSetSource = self;
            self.tableView.emptyDataSetDelegate = self;
            [self.tableView reloadEmptyDataSet];
        }
    }
    [self.tableView reloadData];
}

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
        text = WSY(@"No tour group");
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

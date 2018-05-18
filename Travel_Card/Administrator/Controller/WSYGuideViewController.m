//
//  WSYGuideViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/19.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYGuideViewController.h"
#import "WSYGuideInfoViewController.h"
#import "WSYGuideListModel.h"
#import "WSYGuideCell.h"

@interface WSYGuideViewController ()<UISearchResultsUpdating,MGSwipeTableCellDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property(nonatomic, strong) UISearchController *searchController;
@property(nonatomic, strong) NSMutableArray *guideArray;
@property(nonatomic, strong) NSMutableArray *searchDataSource;
@property(nonatomic, strong) WSYGuideListModel *model;

@end

@implementation WSYGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"导游列表";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGuide)];
    
    [self setupTableView];
    
    @weakify(self);
    NSDictionary *param = @{@"TravelGencyID": [WSYUserDataTool getUserData:kTravelGencyID]};
    [[WSYNetworkTool sharedManager]post:WSY_GUIDE_LIST params:param success:^(id responseBody) {
        @strongify(self);
        NSArray *array = [WSYGuideListModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
        if (array.count == 0) {
            [_guideArray removeAllObjects];
            [self.tableView reloadData];
            self.tableView.emptyDataSetSource = self;
            self.tableView.emptyDataSetDelegate = self;
            [self.tableView reloadEmptyDataSet];
        }else{
            self.guideArray = [NSMutableArray arrayWithArray:array];
            [self.tableView reloadData];
        }
        
    } failure:^(NSError *error) {
        
    }];
    [self.tableView.mj_header endRefreshing];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableView {
    if (iOS11Later) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 56)];
        [header addSubview:self.searchController.searchBar];
        self.tableView.tableHeaderView = header;
    } else {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        [header addSubview:self.searchController.searchBar];
        self.tableView.tableHeaderView = header;
    }
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.backgroundView = [[UIView alloc] init];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
//    self.tableView.emptyDataSetSource = self;
//    self.tableView.emptyDataSetDelegate = self;
//    [self.tableView reloadEmptyDataSet];
}

#pragma mark =============点击事件=============

/**
 添加导游
 */
- (void)addGuide {
    WSYGuideInfoViewController *infoVc = [[WSYGuideInfoViewController alloc]init];
    [self.navigationController pushViewController:infoVc animated:YES];
}

- (void)call:(NSString *)phoneStr {
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    [alert setHorizontalButtons:YES];
    
    [alert addButton:WSY(@"OK") actionBlock:^(void) {
        UIWebView*callWebview =[[UIWebView alloc] init];
        NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneStr]];
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        [self.view addSubview:callWebview];
    }];
    
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    
    [alert showCustom:[UIImage imageNamed:@"T_callTip"] color:kThemeRedColor title:@"电话拨打" subTitle:[NSString stringWithFormat:@"确定拨打电话%@?",phoneStr] closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}

#pragma mark =============懒加载=============

- (UISearchController*)searchController{
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
        
        [_searchController.searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
        _searchController.searchBar.placeholder = @"导游";
        _searchController.searchBar.backgroundColor = [UIColor whiteColor];
    }
    return _searchController;
}

#pragma mark ============Table view data source============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.searchController.active) {
        return _guideArray.count;
    }else{
        return _searchDataSource.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 116;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WSYGuideCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WSYGuideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
//    cell.delegate = self;
    if (!self.searchController.active) {
        cell.model = _guideArray[indexPath.row];
        [[[cell.call rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            [self call:cell.model.Phone];
        }];
    } else {
        cell.model = _searchDataSource[indexPath.row];
        [[[cell.call rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            [self call:cell.model.Phone];
        }];
    }

    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark ============删除操作============
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
//    __weak WSYGuideViewController * me = self;
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
//            [alert showCustom:[UIImage imageNamed:@"M_del"] color:kThemeRedColor title:@"导游删除" subTitle:@"确定删除当前导游？" closeButtonTitle:@"取消" duration:0.0f];
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

#pragma mark ============UISearchResultsUpdating============
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    if ([searchController.searchBar.text isEqualToString:@""]) {
        _searchDataSource = _guideArray;
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains [cd]%@ ", searchController.searchBar.text];
        NSArray *array = [NSArray arrayWithArray:_guideArray];
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
        text = @"未找到结果";
    }else{
        text = @"没有导游";
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

//- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
//{
//    NSString *text = nil;
//    UIFont *font = [UIFont boldSystemFontOfSize:15.0];
//    UIColor *textColor = nil;
//
//    NSMutableDictionary *attributes = [NSMutableDictionary new];
//
//    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
//    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
//    paragraph.alignment = NSTextAlignmentCenter;
//
//    text = @"请在后台添加电子围栏";
//
//    if (!text) {
//        return nil;
//    }
//
//    if (font) [attributes setObject:font forKey:NSFontAttributeName];
//    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
//    if (paragraph) [attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];
//
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
//
//    return attributedString;
//}
//
//- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
//{
//    NSString *text = nil;
//    UIFont *font = nil;
//    UIColor *textColor = nil;
//
//    text = @"下拉刷新";
//    font = [UIFont boldSystemFontOfSize:16.0];
//    textColor = [UIColor redColor];
//
//    if (!text) {
//        return nil;
//    }
//
//    NSMutableDictionary *attributes = [NSMutableDictionary new];
//    if (font) [attributes setObject:font forKey:NSFontAttributeName];
//    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
//
//    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
//}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if (!_searchController.active) {
        return [UIImage imageNamed:@"M_device"];
    }else{
        return [UIImage imageNamed:@"M_search"];
    }
}

//- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
//{
//    return [UIColor whiteColor];
//}

//- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
//{
//    return 9.0;
//}

#pragma mark - DZNEmptyDataSetDelegate Methods

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

@end

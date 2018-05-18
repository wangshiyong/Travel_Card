//
//  WSYManagerViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/26.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYManagerViewController.h"
#import "WSYPersonInfoViewController.h"
#import "WSYLocationViewController.h"
#import "WSYItinerarylListViewController.h"
#import "WSYScanViewController.h"
#import "WSYManagerCell.h"
#import "WSYMemberListModel.h"
#import <AVFoundation/AVFoundation.h>

@interface WSYManagerViewController ()<UISearchResultsUpdating, MGSwipeTableCellDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>{
    UIImageView *navBarHairlineImageView;
}

@property (strong, nonatomic) NSMutableArray     *accountArray;
@property (strong, nonatomic) NSMutableArray     *searchDataSource;

@property(nonatomic, strong) UISearchController  *searchController;

@property (nonatomic, strong) UIButton           *button;
@property (strong, nonatomic) UIButton           *backTopButton;

@end

@implementation WSYManagerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, iOS11Later ? 44 : 34 )];
    [header addSubview:self.searchController.searchBar];
    self.tableView.tableHeaderView = header;
    self.tableView.backgroundView = [[UIView alloc] init];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    @weakify(self);
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kScanSuccess object:nil]subscribeNext:^(id x){
        @strongify(self);
        self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self loadData];
        }];
        [self.tableView.mj_header beginRefreshing];
    }];
    
    //去掉导航栏下划线
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.hidden = YES;
    
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self scanningQRCode];
    }];
    self.navigationItem.rightBarButtonItem.title = WSY(@"Dismiss");
    
    [self.view addSubview:self.button];
    
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kchangeLanguage object:nil]subscribeNext:^(id x){
        @strongify(self);
        [self.tableView reloadData];
    }];
    
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

/** 加载设备列表 */
-(void)loadData
{
    NSDictionary *param = @{@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID]};
    @weakify(self);
    [[WSYNetworkTool sharedManager]post:WSY_GET_TOURIST params:param success:^(id responseBody) {
        @strongify(self);
        NSArray *array = [WSYMemberListModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
        if (array.count == 0) {
            self.accountArray = [NSMutableArray arrayWithArray:array];
            self.tableView.emptyDataSetSource = self;
            self.tableView.emptyDataSetDelegate = self;
            [self.tableView reloadEmptyDataSet];
            [self.tableView reloadData];
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }else{
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.accountArray = [NSMutableArray arrayWithArray:array];
            [self.tableView reloadData];
        }
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
    
}

#pragma mark ============点击事件============
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

/** 解散团 */
- (IBAction)disband:(id)sender
{
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    [alert setHorizontalButtons:YES];
    @weakify(self);
    [alert addButton:WSY(@"OK") actionBlock:^(void) {
        [self showStrHUD:WSY(@"Dismiss...")];
        NSDictionary *param = @{@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID]};
        [[WSYNetworkTool sharedManager]post:WSY_DELETE_ALL_TOURIST params:param success:^(id responseBody) {
            if ([responseBody[@"Code"] intValue] == 0) {
                @strongify(self);
                [self hideHUD];
                [self showSuccessHUD:WSY(@" Success  ")];
                [self loadData];
            } else {
                @strongify(self);
                [self hideHUD];
                [self showErrorHUD:WSY(@"Fail  ")];
            }
        } failure:^(NSError *error) {
            [self hideHUD];
        }];
    }];
    
    
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    
    
    [alert showCustom:[UIImage imageNamed:@"M_disband"] color:kThemeRedColor title:WSY(@"Dismiss the group") subTitle:WSY(@"Sure to dismiss the group?") closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}

/** 扫描二维码方法 */
- (void)scanningQRCode
{
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        WSYScanViewController *scanVc = [[WSYScanViewController alloc]init];
                        [self.navigationController pushViewController:scanVc animated:YES];
                    });
                    
                    // 用户第一次同意了访问相机权限
                    NSLog(@"用户第一次同意了访问相机权限");
                    
                } else {
                    
                    // 用户第一次拒绝了访问相机权限
                    NSLog(@"用户第一次拒绝了访问相机权限");
                }
            }];
        }else if (status == AVAuthorizationStatusAuthorized) {
            WSYScanViewController *scanVc = [[WSYScanViewController alloc]init];
            [self.navigationController pushViewController:scanVc animated:YES];
        }else if (status == AVAuthorizationStatusDenied){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:WSY(@"The camera is unauthorized") message:WSY(@"Go set in settings") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:WSY(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:WSY(@"Setting") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

#pragma mark ============懒加载============

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
        _searchController.searchBar.placeholder = WSY(@"Equipment Number");
        _searchController.searchBar.backgroundColor = [UIColor whiteColor];
    }
    return _searchController;
}

- (UIButton*)button
{
    if(!_button){
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setBackgroundImage:[UIImage imageNamed:@"M_add"] forState:UIControlStateNormal];
    }
    return _button;
}

#pragma mark ============Table view data source============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.searchController.active) {
        return _accountArray.count;
    }else{
        return _searchDataSource.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    WSYManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WSYManagerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.delegate = self;
    
    @weakify(self);
    if (!self.searchController.active) {
        @strongify(self);
        cell.model = self.accountArray[indexPath.row];
        
        //查看成员信息
        [[[cell.tsn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            @strongify(self);
            WSYPersonInfoViewController *infoVc = [[WSYPersonInfoViewController alloc]init];
            infoVc.str = cell.model.CodeMachine;
            [self.navigationController pushViewController:infoVc animated:YES];
        }];
        
        //查看定位信息
        [[[cell.location rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            @strongify(self);
            WSYLocationViewController *locationVc = [[WSYLocationViewController alloc]init];
            locationVc.isTrack = NO;
            locationVc.str = cell.model.CodeMachine;
            locationVc.ids = cell.model.MemberID;
            [self.navigationController pushViewController:locationVc animated:YES];
        }];
        
        //查看轨迹信息
        [[[cell.track rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            @strongify(self);
            WSYLocationViewController *locationVc = [[WSYLocationViewController alloc]init];
            locationVc.isTrack = YES;
            locationVc.str = cell.model.CodeMachine;
            locationVc.ids = cell.model.MemberID;
            locationVc.terminalID = cell.model.TerminalID;
            [self.navigationController pushViewController:locationVc animated:YES];
        }];
    } else {
        @strongify(self);
        cell.model = self.searchDataSource[indexPath.row];
        
        //查看成员信息
        [[[cell.tsn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            @strongify(self);
            WSYPersonInfoViewController *infoVc = [[WSYPersonInfoViewController alloc]init];
            infoVc.str = cell.model.CodeMachine;
            [self.navigationController pushViewController:infoVc animated:YES];
        }];
        
        //查看定位信息
        [[[cell.location rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            @strongify(self);
            WSYLocationViewController *locationVc = [[WSYLocationViewController alloc]init];
            locationVc.isTrack = NO;
            locationVc.str = cell.model.CodeMachine;
            locationVc.ids = cell.model.MemberID;
            [self.navigationController pushViewController:locationVc animated:YES];
        }];
        
        //查看轨迹信息
        [[[cell.track rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(UIButton *x){
            @strongify(self);
            WSYLocationViewController *locationVc = [[WSYLocationViewController alloc]init];
            locationVc.isTrack = YES;
            locationVc.str = cell.model.CodeMachine;
            locationVc.ids = cell.model.MemberID;
            locationVc.terminalID = cell.model.TerminalID;
            [self.navigationController pushViewController:locationVc animated:YES];
        }];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark ============UISearchResultsUpdating============

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if ([searchController.searchBar.text isEqualToString:@""]) {
        _searchDataSource = _accountArray;
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.CodeMachine contains [cd]%@ ", searchController.searchBar.text];
        NSArray *array = [NSArray arrayWithArray:_accountArray];
        _searchDataSource = (NSMutableArray *)[array filteredArrayUsingPredicate:predicate];
        if (_searchDataSource.count == 0) {
            self.tableView.emptyDataSetSource = self;
            self.tableView.emptyDataSetDelegate = self;
            [self.tableView reloadEmptyDataSet];
        }
    }
    [self.tableView reloadData];
}

#pragma mark ============删除操作============
#pragma mark Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    
    swipeSettings.transition = MGSwipeTransition3D;
    expansionSettings.buttonIndex = 0;
    
    //    MailData * mail = [me mailForIndexPath:[self.tableView indexPathForCell:cell]];
    
    if (direction == MGSwipeDirectionLeftToRight) {
        
        expansionSettings.fillOnTrigger = NO;
        expansionSettings.threshold = 2;
        return @[[MGSwipeButton buttonWithTitle:WSY(@"Slide to delete") backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0] padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
            
            //            MailData * mail = [me mailForIndexPath:[me.tableView indexPathForCell:sender]];
            //            mail.read = !mail.read;
            //            [me updateCellIndicactor:mail cell:(WSYScheduleListCell*)sender];
            [cell refreshContentView]; //needed to refresh cell contents while swipping
            
            //change button text
            //            [(UIButton*)[cell.leftButtons objectAtIndex:0] setTitle:[me readButtonText:mail.read] forState:UIControlStateNormal];
            
            return YES;
        }]];
    }
    else {
        
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        @weakify(self);
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:WSY(@"Delete ") backgroundColor:[UIColor colorWithRed:1.0 green:59/255.0 blue:50/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            @strongify(self);
            NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
            SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
            [alert setHorizontalButtons:YES];
            if (!self.searchController.active) {
                WSYMemberListModel *model = self.accountArray[indexPath.row];
                NSDictionary *param = @{@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID],@"MemberID":model.MemberID};
                [alert addButton:WSY(@"OK") actionBlock:^(void) {
                    [self showHUDWithStr:WSY(@"Deleting...")];
                    [[WSYNetworkTool sharedManager]post:WSY_DELETE_TOURIST params:param success:^(id responseBody) {
                        [self hideNaHUD];
                        if ([responseBody[@"Code"] intValue] == 0) {
                            @strongify(self);
                            [self.accountArray removeObjectAtIndex:indexPath.row];//移除数据源的数据
                            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                            
                            if (self.accountArray.count == 0) {
                                self.tableView.emptyDataSetSource = self;
                                self.tableView.emptyDataSetDelegate = self;
                                [self.tableView reloadEmptyDataSet];
                                self.navigationItem.rightBarButtonItem.enabled = NO;
                                [self showSuccessHUD:WSY(@" Success ")];
                                //                    [[NSNotificationCenter defaultCenter]postNotificationName:kDisenble object:nil];
                            } else {
                                [self showSuccessHUD:WSY(@" Success ")];
                            }
                        } else {
                            [self showErrorHUD:WSY(@"Fail ")];
                        }
                    } failure:^(NSError *error) {
                        [self hideNaHUD];
                    }];
                }];
            } else {
                WSYMemberListModel *model = self.searchDataSource[indexPath.row];
                NSDictionary *param = @{@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID],@"MemberID":model.MemberID};
                [alert addButton:WSY(@"OK") actionBlock:^(void) {
                    [self showHUDWithStr:WSY(@"Deleting...")];
                    [[WSYNetworkTool sharedManager]post:WSY_DELETE_TOURIST params:param success:^(id responseBody) {
                        [self hideNaHUD];
                        if ([responseBody[@"Code"] intValue] == 0) {
                            @strongify(self);
                            self.searchController.active = false;
                            [self showSuccessHUD:WSY(@" Success ")];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter]postNotificationName:kScanSuccess object:nil];
                            });
                        } else {
                            [self showErrorHUD:WSY(@"Fail ")];
                        }
                        
                    } failure:^(NSError *error) {
                        [self hideNaHUD];
                    }];
                }];
            }
            
            
            
            alert.completeButtonFormatBlock = ^NSDictionary* (void) {
                NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
                buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
                return buttonConfig;
            };
            
            
            [alert showCustom:[UIImage imageNamed:@"M_del"] color:kThemeRedColor title:WSY(@"Delete member") subTitle:WSY(@"Delete the selected member?") closeButtonTitle:WSY(@"Cancel") duration:0.0f];
            
            return YES; //don't autohide to improve delete animation
        }];
        
        return @[trash];
    }
    
    return nil;
    
}

#pragma mark ============UIScrollViewDelegate============

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.backTopButton.hidden = (scrollView.contentOffset.y > kScreenHeight) ? NO : YES;//判断回到顶部按钮是否隐藏
    self.button.frame  = CGRectMake(kScreenWidth - 110, self.tableView.contentOffset.y + kScreenHeight - (IS_IPHONE_X ? 134 : 100), 40, 40);
    self.backTopButton.frame  = CGRectMake(kScreenWidth - 110, self.tableView.contentOffset.y + kScreenHeight - (IS_IPHONE_X ? 184 : 150), 40, 40);
}

#pragma mark =============Table view滚回顶部=============
- (void)ScrollToTop
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
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
        text = WSY(@"No tourist equipment");
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
//    text = @"请添加游客设备";
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

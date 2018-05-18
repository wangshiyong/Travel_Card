//
//  WSYRailListViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/11/15.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYRailListViewController.h"
#import "WSYRailViewController.h"
#import "WSYRailListCell.h"
#import "WSYRailListModel.h"

@interface WSYRailListViewController ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (strong, nonatomic) NSMutableArray *railArray;

@end

@implementation WSYRailListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = WSY(@"Electronic fence list");
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    @weakify(self);
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData];
    }];
    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** 加载围栏列表 */
-(void)loadData
{
    @weakify(self);
    NSDictionary *param = @{@"TravelAgencyID": [WSYUserDataTool getUserData:kTravelGencyID],@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID]};
    [[WSYNetworkTool sharedManager]post:WSY_GET_FENCE params:param success:^(id responseBody) {
        @strongify(self)
        if ([responseBody[@"Code"] integerValue] == 0) {
            NSArray *array = [WSYRailListModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
            if (array.count == 0) {
                [self.railArray removeAllObjects];
                self.tableView.emptyDataSetSource = self;
                self.tableView.emptyDataSetDelegate = self;
                [self.tableView reloadEmptyDataSet];
            }else{
                self.railArray = [NSMutableArray arrayWithArray:array];
                [self.tableView reloadData];
            }
        } else {
            [self.railArray removeAllObjects];
            self.tableView.emptyDataSetSource = self;
            self.tableView.emptyDataSetDelegate = self;
            [self.tableView reloadEmptyDataSet];
        }
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.railArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const identifier = @"Cell";
    WSYRailListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[WSYRailListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.model = self.railArray[indexPath.row];
//    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WSYRailListModel *model = self.railArray[indexPath.row];
    WSYRailViewController *railVc = [[WSYRailViewController alloc]init];
    railVc.ids = model.ID;
    [self.navigationController pushViewController:railVc animated:YES];
}

//#pragma mark ============删除操作============
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
//        @weakify(self);
//        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor colorWithRed:1.0 green:59/255.0 blue:50/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
//            @strongify(self);
//            NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
//            SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
//            [alert setHorizontalButtons:YES];
//            WSYRailListModel *model = self.railArray[indexPath.row];
//            [alert addButton:@"确定" actionBlock:^(void) {
//                [self showHUDWithStr:@"删除中..."];
//                NSDictionary *param = @{@"ElectronicFenceID": model.ids,@"Enabled": @"false",@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID]};
//                [[WSYNetworkTool sharedManager]post:WSY_SET_FENCE_STATE params:param success:^(id responseBody) {
//                    [self hideNaHUD];
//                    if ([responseBody[@"Code"] intValue] == 0) {
//                        [self showSuccessHUD:@"删除成功"];
//                        [self.railArray removeObjectAtIndex:indexPath.row];//移除数据源的数据
//                        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//                        self.tableView.emptyDataSetSource = self;
//                        self.tableView.emptyDataSetDelegate = self;
//                        [self.tableView reloadEmptyDataSet];
//                    } else {
//                        [self showErrorHUD:@"删除失败"];
//                    }
//                } failure:^(NSError *error) {
//                    [self hideNaHUD];
//                }];
//
//            }];
//
//
//
//            alert.completeButtonFormatBlock = ^NSDictionary* (void) {
//                NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
//                buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
//                return buttonConfig;
//            };
//
//
//            [alert showCustom:[UIImage imageNamed:@"I_del1"] color:kThemeRedColor title:@"围栏删除" subTitle:@"确定删除当前围栏？" closeButtonTitle:@"取消" duration:0.0f];
//
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
    
    text = WSY(@"No Electronic Fence");
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
    return [UIImage imageNamed:@"H_fencing"];
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

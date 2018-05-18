//
//  WSYItineraryViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/25.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYItineraryViewController.h"
#import "WSYReleaseViewController.h"
#import "WSYItineraryModel.h"
#import "WSYItineraryCell.h"
#import "MGSwipeButton.h"

@interface WSYItineraryViewController ()<MGSwipeTableCellDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UIButton *button;
@property (strong, nonatomic) NSMutableArray *listArray;
@property (nonatomic, strong) NSMutableString *starttime;
@property (nonatomic, strong) NSMutableString *endtime;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *delItem;

@end

@implementation WSYItineraryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.view addSubview:self.button];
    [self.tableView bringSubviewToFront:self.button];
    
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *str=[dateformatter stringFromDate:senddate];
    _starttime = [NSMutableString stringWithString:str];
    [_starttime appendString:@" 00:00:00"];
    
    //结束时间
    _endtime = [NSMutableString stringWithString:str];
    [_endtime appendString:@" 23:59:59"];
    
    @weakify(self);
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kReleaseNotice object:nil]subscribeNext:^(id x){
        @strongify(self);
        self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self loadData];
        }];
        [self.tableView.mj_header beginRefreshing];
    }];
    
    _delItem.title = WSY(@"Empty");

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadData
{
    @weakify(self);
    NSDictionary *param = @{@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID], @"TravelGencyID":[WSYUserDataTool getUserData:kTravelGencyID],@"start":[WSYNSDateHelper getUTCFormateLocalDate:_starttime],@"end":[WSYNSDateHelper getUTCFormateLocalDate:_endtime]};
    [[WSYNetworkTool sharedManager]post:WSY_GET_TRIP params:param success:^(id responseBody) {
        @strongify(self);
        NSArray *array = [WSYItineraryModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
        if (array.count == 0) {
            self.delItem.enabled = NO;
            [self.listArray removeAllObjects];
            self.tableView.emptyDataSetSource = self;
            self.tableView.emptyDataSetDelegate = self;
            [self.tableView reloadEmptyDataSet];
            [self.tableView reloadData];
        }else{
            self.delItem.enabled = YES;
            self.listArray = [NSMutableArray arrayWithArray:array];
            [self.tableView reloadData];
        }
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
    
}

- (IBAction)delList:(id)sender
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.shouldDismissOnTapOutside = YES;
    @weakify(self);
    [alert setHorizontalButtons:YES];
    [alert addButton:WSY(@"OK") actionBlock:^(void) {
        @strongify(self);
        [self showStrHUD:WSY(@"Emptying...")];
        NSDictionary *param = @{@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID], @"TravelGencyID":[WSYUserDataTool getUserData:kTravelGencyID]};
        [[WSYNetworkTool sharedManager]post:WSY_DELETE_TEAM_TRIP params:param success:^(id responseBody) {
            [self hideHUD];
            if ([responseBody[@"Code"] intValue] == 0) {
                [self showSuccessHUD:WSY(@" Success")];
                [self.listArray removeAllObjects];
                self.delItem.enabled = NO;
                self.tableView.emptyDataSetSource = self;
                self.tableView.emptyDataSetDelegate = self;
                [self.tableView reloadEmptyDataSet];
                [self.tableView reloadData];
                
            } else {
                [self showErrorHUD:WSY(@" Fail")];
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
    
    [alert showCustom:[UIImage imageNamed:@"I_del1"] color:kThemeRedColor title:WSY(@"Clean") subTitle:WSY(@"Sure to delete all itinerary information") closeButtonTitle:WSY(@"Cancel") duration:0.0f];
    
}

- (void)releaseAction:(id)sender
{
    WSYReleaseViewController *releaseVc = [[WSYReleaseViewController alloc]init];
    [self.navigationController pushViewController:releaseVc animated:YES];
}

#pragma mark ============懒加载============

-(UIButton*)button
{
    if(!_button){
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button addTarget:self action:@selector(releaseAction:) forControlEvents:UIControlEventTouchUpInside];
        [_button setBackgroundImage:[UIImage imageNamed:@"I_release1"] forState:UIControlStateNormal];
    }
    return _button;
}

#pragma mark ============UIScrollViewDelegate============

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.button.frame  = CGRectMake(kScreenWidth - 110, self.tableView.contentOffset.y + kScreenHeight - (IS_IPHONE_X ? 134 : 100), 40, 40);
}

#pragma mark ============Table view data source============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    WSYItineraryCell *cell = (WSYItineraryCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WSYItineraryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.model = self.listArray[indexPath.row];
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    @weakify(self);
    //    MailData * mail = [me mailForIndexPath:[self.tableView indexPathForCell:cell]];
    
    if (direction == MGSwipeDirectionLeftToRight) {
        
        expansionSettings.fillOnTrigger = NO;
        expansionSettings.threshold = 2;
        return @[[MGSwipeButton buttonWithTitle:WSY(@"Slide to delete") backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0] padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
            
            return YES;
        }]];
    }
    else {
        
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:WSY(@"Delete ") backgroundColor:[UIColor colorWithRed:1.0 green:59/255.0 blue:50/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            @strongify(self);
            NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
            WSYItineraryModel *model = self.listArray[indexPath.row];
            SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
            [alert setHorizontalButtons:YES];

            [alert addButton:WSY(@"OK") actionBlock:^(void) {
                [self showHUDWithStr:WSY(@"Deleting...")];
                NSDictionary *param = @{@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID], @"TravelGencyID":[WSYUserDataTool getUserData:kTravelGencyID],@"TripID":model.ID};
                [[WSYNetworkTool sharedManager]post:WSY_DELETE_TRIP params:param success:^(id responseBody) {
                    @strongify(self);
                    [self hideNaHUD];
                    if ([responseBody[@"Code"] intValue] == 0) {
                        [self.listArray removeObjectAtIndex:indexPath.row];//移除数据源的数据
                        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                        [self showSuccessHUD:WSY(@" Success ")];
                        if (self.listArray.count == 0) {
                            self.delItem.enabled = NO;
                            self.tableView.emptyDataSetSource = self;
                            self.tableView.emptyDataSetDelegate = self;
                            [self.tableView reloadEmptyDataSet];
                        }
                        
                    } else {
                        [self showErrorHUD:WSY(@"Fail ")];
                    }

                } failure:^(NSError *error) {
                    [self hideNaHUD];
                }];
            }];
        
            
            alert.completeButtonFormatBlock = ^NSDictionary* (void) {
                NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
                buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
                return buttonConfig;
            };
            
            
            [alert showCustom:[UIImage imageNamed:@"I_del1"] color:kThemeRedColor title:WSY(@"Delete") subTitle:WSY(@"Sure to delete all itinerary information?") closeButtonTitle:WSY(@"Cancel") duration:0.0f];
            
            //            [_listArray removeObjectAtIndex:indexPath.row];//移除数据源的数据
            //            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            return YES; //don't autohide to improve delete animation
        }];
        
        return @[trash];
    }
    
    return nil;
    
}

#pragma mark ============DZNEmptyDataSetSource Methods============

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
//    text = @"没有行程信息";
    text = WSY(@"No itinerary information");
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
    return [UIImage imageNamed:@"I_trip"];
}

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

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -64;
}


@end

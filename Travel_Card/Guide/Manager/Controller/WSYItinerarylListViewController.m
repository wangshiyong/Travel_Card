//
//  WSYItinerarylListViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/11.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYItinerarylListViewController.h"
#import "WSYLocationViewController.h"
#import "WSYTrackCell.h"
#import "WSYTrackHeadView.h"

@interface WSYItinerarylListViewController ()

@end

@implementation WSYItinerarylListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = WSY(@"Route");
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"M_Time"] style:UIBarButtonItemStylePlain target:self action:@selector(selectedTime)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)selectedTime
{
    
}

#pragma mark ============Table view data source============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WSYTrackHeadView *headView = [[WSYTrackHeadView alloc]initWithFrame:(CGRect){0, 0, kScreenWidth, 40}];
    headView.timeLab.text = @"2017年10月";
    headView.tsnLab.text = @"设备号：0000001";
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WSYTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WSYTrackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.startLab.text = @"2017-10-11 15:33:48";
    cell.endLab.text = @"2017-10-11 19:33:48";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WSYLocationViewController *locationVc = [[WSYLocationViewController alloc]init];
    [self.navigationController pushViewController:locationVc animated:YES];
}

@end

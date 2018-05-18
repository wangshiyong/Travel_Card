//
//  WSYGuideInfoViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/19.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYGuideInfoViewController.h"
#import "WSYSuperInfoCell.h"

@interface WSYGuideInfoViewController ()

@property (nonatomic, strong) NSArray *contents;

@end

@implementation WSYGuideInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"导游信息";
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"更新" style:UIBarButtonItemStylePlain target:self action:@selector(update)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update{
    
}

- (NSArray *)contents
{
    if (!_contents)
    {
        _contents = @[@"姓名", @"电话", @"账号" ,@"密码", @"证件类型"];
    }
    
    return _contents;
}

#pragma mark ============Table view data source============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WSYSuperInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WSYSuperInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.titleLab.text = self.contents[indexPath.row];
    cell.textField.placeholder = self.contents[indexPath.row];
    
    return cell;
}

@end

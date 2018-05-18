//
//  WSYSuperInfoViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/16.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYSuperInfoViewController.h"
#import "WSYSuperInfoCell.h"

@interface WSYSuperInfoViewController ()

@property (assign, nonatomic) BOOL ableEdit;

@end

@implementation WSYSuperInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    if (self.isAdd == YES) {
        self.navigationItem.title = @"添加景区服务商";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(complete)];
    } else {
        self.navigationItem.title = @"深圳科佳讯测试旅行社";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(update:)];
    }
    
    //属性监听
    self.ableEdit = NO;
    
    @weakify(self);
    [RACObserve(self, ableEdit) subscribeNext:^(id x){
        @strongify(self);
        [self.tableView reloadData];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update:(UIBarButtonItem *)sender {
    self.ableEdit = !self.ableEdit;
    if (_ableEdit) {
        sender.title = @"完成";
        self.ableEdit = YES;
    }else{
        sender.title = @"编辑";
        self.ableEdit = NO;
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)complete{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ============Table view data source============

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 4;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:(CGRect){0, 0, kScreenWidth, 10}];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WSYSuperInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WSYSuperInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    
//    @weakify(self);
    [[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(id x){
//        @strongify(self);
        if (indexPath.section == 0) {
            if([x length] > 20){
                cell.textField.text = [NSString stringWithFormat:@"%@",[x substringToIndex:20]];
            }
        } else if (indexPath.section == 1) {
            if([x length] > 11){
                cell.textField.text = [NSString stringWithFormat:@"%@",[x substringToIndex:11]];
            }
        } else {
            if([x length] > 20){
                cell.textField.text = [NSString stringWithFormat:@"%@",[x substringToIndex:20]];
            }
        }
//        [self.nameArrs removeObjectAtIndex:indexPath.row];
//        [self.nameArrs insertObject:cell.name.text atIndex:indexPath.row];
//        if([x length] > 11){
//            cell.name.text = [NSString stringWithFormat:@"%@",[x substringToIndex:11]];
//        }
    }];
    
    if (self.isAdd) {
        if (indexPath.section == 0) {
            cell.titleLab.text = @"名称";
            cell.textField.placeholder = @"名称";
            [cell.textField becomeFirstResponder];
        } else if (indexPath.section == 1) {
            NSArray *array = [NSArray arrayWithObjects:@"负责人",@"电话",@"账号",@"密码", nil];
            cell.titleLab.text = array[indexPath.row];
            cell.textField.placeholder = array[indexPath.row];
            if (indexPath.row == 1) {
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            } else if (indexPath.row == 3) {
                cell.textField.secureTextEntry = YES;
                cell.textField.keyboardType = UIKeyboardTypeDefault;
            } else {
                cell.textField.keyboardType = UIKeyboardTypeDefault;
            }
        } else {
            cell.titleLab.text = @"地址";
            cell.textField.placeholder = @"地址";
        }
    } else {        
        if (self.ableEdit == NO) {
            cell.textField.enabled = NO;
        }else{
            cell.textField.enabled = YES;
        }
        if (indexPath.section == 0) {
            cell.titleLab.text = @"名称";
            cell.textField.placeholder = @"名称";
            [cell.textField becomeFirstResponder];
        } else if (indexPath.section == 1) {
            NSArray *array = [NSArray arrayWithObjects:@"负责人",@"电话",@"账号",@"密码", nil];
            cell.titleLab.text = array[indexPath.row];
            cell.textField.placeholder = array[indexPath.row];
            if (indexPath.row == 1) {
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            } else if (indexPath.row == 3) {
                cell.textField.secureTextEntry = YES;
                cell.textField.keyboardType = UIKeyboardTypeDefault;
            } else {
                cell.textField.keyboardType = UIKeyboardTypeDefault;
            }
        } else {
            cell.titleLab.text = @"地址";
            cell.textField.placeholder = @"地址";
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

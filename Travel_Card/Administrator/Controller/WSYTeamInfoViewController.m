//
//  WSYTeamInfoViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/17.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYTeamInfoViewController.h"
#import "WSYSuperInfoCell.h"
#import "BRStringPickerView.h"
#import "WSYTextField.h"

@interface WSYTeamInfoViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) WSYTextField *nameTF;
@property (nonatomic, strong) WSYTextField *personTF;
@property (nonatomic, strong) WSYTextField *lineTF;
@property (nonatomic, strong) WSYTextField *accountTF;
@property (nonatomic, strong) WSYTextField *pwdTF;

@end

@implementation WSYTeamInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.isAdd == YES) {
        self.navigationItem.title = @"添加旅游团";
    } else {
        self.navigationItem.title = @"深圳科佳讯测试旅行社";
    }
    
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"更新" style:UIBarButtonItemStylePlain target:self action:@selector(update)];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RACSignal *valid = [RACSignal combineLatest:@[self.nameTF.rac_textSignal,
                                                      self.personTF.rac_textSignal,
                                                      self.accountTF.rac_textSignal,
                                                      self.pwdTF.rac_textSignal,
                                                      self.lineTF.rac_textSignal]
                                             reduce:^(NSString *nameTF, NSString *personTF, NSString *accountTF, NSString *pwdTF, NSString *lineTF){
                                                 return @(nameTF.length > 0 && personTF.length > 0 && accountTF.length > 5 && pwdTF.length > 5 && lineTF.length > 0);
                                             }];
        RAC(self.navigationItem.rightBarButtonItem, enabled) = valid;
        
        [self.nameTF.rac_textSignal subscribeNext:^(id x){
            if([x length] > 15){
                self.nameTF.text = [NSString stringWithFormat:@"%@",[x substringToIndex:15]];
            }
        }];
        
        [self.personTF.rac_textSignal subscribeNext:^(id x){
            if([x length] > 10){
                self.personTF.text = [NSString stringWithFormat:@"%@",[x substringToIndex:10]];
            }
        }];
        
        [self.accountTF.rac_textSignal subscribeNext:^(id x){
            if([x length] > 15){
                self.accountTF.text = [NSString stringWithFormat:@"%@",[x substringToIndex:15]];
            }
        }];
        
        [self.pwdTF.rac_textSignal subscribeNext:^(id x){
            if([x length] > 10){
                self.pwdTF.text = [NSString stringWithFormat:@"%@",[x substringToIndex:10]];
            }
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update{

}

#pragma mark ============UITableViewCell上添加TextField============

- (WSYTextField *)getTextField:(UITableViewCell *)cell {
    WSYTextField *textField = [[WSYTextField alloc]initWithFrame:CGRectMake(115, 0, kScreenWidth - 135, 44)];
    textField.backgroundColor = [UIColor clearColor];
    textField.font = [UIFont systemFontOfSize:15.0f];
    textField.textAlignment = NSTextAlignmentLeft;
    textField.textColor = RGB_HEX(0x666666, 1.0);
    textField.delegate = self;
    [cell.contentView addSubview:textField];
    return textField;
}

- (void)setupNameTF:(UITableViewCell *)cell {
    if (!_nameTF) {
        _nameTF = [self getTextField:cell];
        _nameTF.placeholder = @"团名称";
        _nameTF.returnKeyType = UIReturnKeyDone;
        _nameTF.tag = 0;
    }
}

- (void)setupPersonTF:(UITableViewCell *)cell {
    if (!_personTF) {
        _personTF = [self getTextField:cell];
        _personTF.placeholder = @"负责导游";
    }
}

- (void)setupAccountTF:(UITableViewCell *)cell {
    if (!_accountTF) {
        _accountTF = [self getTextField:cell];
        _accountTF.placeholder = @"账号(6~15位)";
    }
}

- (void)setupPwdTF:(UITableViewCell *)cell {
    if (!_pwdTF) {
        _pwdTF = [self getTextField:cell];
        _pwdTF.placeholder = @"密码(6~10位)";
        _pwdTF.secureTextEntry = YES;
    }
}

- (void)setupLineTF:(UITableViewCell *)cell {
    if (!_lineTF) {
        _lineTF = [self getTextField:cell];
        _lineTF.placeholder = @"旅游线路";
    }
}

#pragma mark ============Table view data source============

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 3;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"团名称";
        [self setupNameTF:cell];
    } else if (indexPath.section == 1) {
        NSArray *array = [NSArray arrayWithObjects:@"负责导游",@"账号", @"密码",nil];
        cell.textLabel.text = array[indexPath.row];
        if (indexPath.row == 0) {
            [self setupPersonTF:cell];
            @weakify(self);
            self.personTF.tapAcitonBlock = ^{
                @strongify(self);
                [BRStringPickerView showStringPickerWithTitle:@"请选择导游" dataSource:@[@"小王", @"小李", @"小朱"] defaultSelValue:@"小王" isAutoSelect:NO resultBlock:^(id selectValue) {
                    self.personTF.text = selectValue;
                }];
            };
        } else if (indexPath.row == 1) {
            [self setupAccountTF:cell];
        } else {
            [self setupPwdTF:cell];
        }
    } else {
        cell.textLabel.text = @"旅游线路";
        [self setupLineTF:cell];
        @weakify(self);
        self.lineTF.tapAcitonBlock = ^{
            @strongify(self);
            [BRStringPickerView showStringPickerWithTitle:@"请选择线路" dataSource:@[@"北京-长沙", @"上海-深圳", @"广州-重庆"] defaultSelValue:@"北京-长沙" isAutoSelect:NO resultBlock:^(id selectValue) {
                self.lineTF.text = selectValue;
            }];
        };
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

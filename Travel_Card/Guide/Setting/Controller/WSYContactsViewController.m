//
//  WSYContactsViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/29.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYContactsViewController.h"

// Models
#import "WSYContactsModel.h"

// Views
#import "WSYContactsCell.h"

@interface WSYContactsViewController ()

@property (nonatomic, strong) NSMutableArray *nameArray;
@property (nonatomic, strong) NSMutableArray *phoneArray;
@property (assign, nonatomic) BOOL ableEdit;

@end

@implementation WSYContactsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = WSY(@"Emergency Contacts");
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIBarButtonItem *myButton = [[UIBarButtonItem alloc] initWithTitle:WSY(@"Edit") style:UIBarButtonItemStylePlain target:self action:@selector(clickEvent:)];
    
    self.navigationItem.rightBarButtonItem = myButton;
    
    @weakify(self);
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    //属性监听
    self.ableEdit = NO;
    [RACObserve(self, ableEdit) subscribeNext:^(id x){
        @strongify(self);
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 数据加载
 */
- (void)loadData
{
    _nameArray = [NSMutableArray array];
    _phoneArray = [NSMutableArray array];
    @weakify(self);
    NSDictionary *param = @{@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID]};
    [[WSYNetworkTool sharedManager]post:WSY_GET_SOS_NAME params:param success:^(id responseBody) {
        @strongify(self);
        NSArray *array = [WSYContactsModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
        for(int i = 0; i < array.count; i++){
            WSYContactsModel *model = array[i];
            if ([self isNilOrEmpty:model.Contact]) {
                [_nameArray addObject:@""];
            } else {
                [_nameArray addObject:model.Contact];
            }
            
            if ([self isNilOrEmpty:model.Phone]) {
                [_phoneArray addObject:@""];
            } else {
                [_phoneArray addObject:model.Phone];
            }
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (BOOL)isNilOrEmpty:(NSString*)value
{
    if(value != nil && ![value isKindOfClass:[NSNull class]])
    {
        return value.length == 0;
    }
    return YES;
}

- (BOOL)isChinaMobile:(NSString *)phoneNum
{ 
    NSString *CM = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[0678])\\d{8}$";
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    return [regextestcm evaluateWithObject:phoneNum];
}

- (BOOL)isPhoneNum:(NSString *)phoneNum
{
    return phoneNum.length >= 11;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

//- (BOOL)validateNumber:(NSString*)number {
//    BOOL res = YES;
//    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
//    int i = 0;
//    while (i < number.length) {
//        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
//        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
//        if (range.length == 0) {
//            res = NO;
//            break;
//        }
//        i++;
//    }
//    return res;
//}


#pragma mark ============点击事件============

- (void)clickEvent: (UIBarButtonItem *)sendr
{
    _ableEdit = !_ableEdit;
    if (_ableEdit) {
        sendr.title = WSY(@"Updating");
        self.ableEdit = YES;
    } else {
        sendr.title = WSY(@"Edit");
        [self saveSOS];
    }
}

- (void)saveSOS
{
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    for (NSInteger i = 0; i < 3; i++) {
        if (![self isNilOrEmpty:_phoneArray[i]]) {
            if (![self isPhoneNum:_phoneArray[i]]) {
                [alert showError:WSY(@"Please input right TEL") subTitle:nil closeButtonTitle:nil duration:1.0f];
                self.navigationItem.rightBarButtonItem.title = WSY(@"Updating");
                self.ableEdit = YES;
                return;
            }
        }
    }
    self.ableEdit = NO;
    NSString *phoneSos = [NSString string];
    for (NSInteger i = 0; i < 3; i++) {
        phoneSos = [phoneSos stringByAppendingString:[NSString stringWithFormat:@",%@",_phoneArray[i]]];
    }

    NSString *nameSos = [NSString string];
    for (NSInteger i = 0; i< 3 ; i++) {
        nameSos = [nameSos stringByAppendingString:[NSString stringWithFormat:@",%@",_nameArray[i]]];
    }
    
    nameSos = [nameSos substringFromIndex:1];
    phoneSos = [phoneSos substringFromIndex:1];

    [self showHUDWithStr:WSY(@"Updating...")];
    @weakify(self);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSDictionary *param = @{@"TouristTeamID":[WSYUserDataTool getUserData:kGuideID],@"SOSContactPhone":phoneSos};
    [[WSYNetworkTool sharedManager]post:WSY_SET_SOS_PHONE params:param success:^(id responseBody) {
        NSString *codeStr = [NSString stringWithFormat:@"%@",responseBody[@"Code"]];
        if ([codeStr isEqualToString:@"0"]) {
            [alert showSuccess:WSY(@"Update succeeded") subTitle:nil closeButtonTitle:nil duration:1.0f];
        }else{
            [alert showError:WSY(@"Update failure") subTitle:nil closeButtonTitle:nil duration:1.0f];
        }
        dispatch_group_leave(group);
    } failure:^(NSError *error) {
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    NSDictionary *param2 = @{@"TouristTeamID":[WSYUserDataTool getUserData:kGuideID],@"SOSContactName":nameSos};
    [[WSYNetworkTool sharedManager]post:WSY_SET_SOS_NAME params:param2 success:^(id responseBody) {
//        NSString *codeStr = [NSString stringWithFormat:@"%@",responseBody[@"Code"]];
//        if ([codeStr isEqualToString:@"0"]) {
//            [alert showSuccess:@"更新成功" subTitle:nil closeButtonTitle:nil duration:1.0f];
//        }else{
//            [alert showError:@"更新失败" subTitle:nil closeButtonTitle:nil duration:1.0f];
//        }
        dispatch_group_leave(group);
    } failure:^(NSError *error) {
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        @strongify(self);
        [self hideNaHUD];
    });
}

#pragma mark ============Table view data source／delegate============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _nameArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_5) {
        return 100;
    }
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    WSYContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WSYContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (self.ableEdit == NO) {
        cell.name.enabled = NO;
        cell.phone.enabled = NO;
    }else{
        cell.name.enabled = YES;
        cell.phone.enabled = YES;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.name.text = _nameArray[indexPath.row];
    cell.phone.text = _phoneArray[indexPath.row];

    @weakify(self);
    [[cell.phone.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(id x){
        @strongify(self);
        [self.phoneArray removeObjectAtIndex:indexPath.row];
        if([x length] > 15){
            cell.phone.text = [NSString stringWithFormat:@"%@",[x substringToIndex:15]];
        }
        [self.phoneArray insertObject:cell.phone.text atIndex:indexPath.row];
    }];

    [[cell.name.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]subscribeNext:^(id x){
        @strongify(self);
        [self.nameArray removeObjectAtIndex:indexPath.row];
        [self.nameArray insertObject:cell.name.text atIndex:indexPath.row];
        if([x length] > 11){
            cell.name.text = [NSString stringWithFormat:@"%@",[x substringToIndex:11]];
        }
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

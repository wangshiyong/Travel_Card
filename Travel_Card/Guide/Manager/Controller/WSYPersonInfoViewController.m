//
//  WSYPersonInfoViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/11.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYPersonInfoViewController.h"
#import "UINavigationBar+Awesome.h"
#import "UIScrollView+ScalableCover.h"
#import "WSYSuperInfoCell.h"
#import "WSYMemberInfoModel.h"
#import "UIImage+Tint.h"

#define NAVBAR_CHANGE_POINT 64
static NSString *const kMan = @"Man";
static NSString *const kWoman = @"Woman";

@interface WSYPersonInfoViewController ()

@property (nonatomic, strong) UIImageView *headImage;
@property (nonatomic, strong) NSMutableArray *array;
@property (assign, nonatomic) BOOL ableEdit;

@end

@implementation WSYPersonInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = WSY(@"Personal information");
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:19.0f],NSFontAttributeName ,nil]];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [[UITableViewHeaderFooterView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 180)];
    [self.tableView addScalableCoverWithImage:[UIImage imageNamed:@"M_HeadImage"]];
    
    [self setupNavigationItem];
    
    [self showHUD];
    
    //属性监听
    self.ableEdit = NO;
    
    @weakify(self);
    [RACObserve(self, ableEdit) subscribeNext:^(id x){
        @strongify(self);
        [self.tableView reloadData];
    }];
    

    NSDictionary *param = @{@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID],@"CodeMachine": _str};
    [[WSYNetworkTool sharedManager]post:WSY_GET_INFO params:param success:^(id responseBody) {
        @strongify(self);
        [self hideHUD];
        if ([responseBody[@"Code"] intValue] == 0) {
            NSArray *array = [WSYMemberInfoModel mj_objectArrayWithKeyValuesArray:responseBody[@"Data"]];
            WSYMemberInfoModel *model = array[0];            
            _array = [NSMutableArray arrayWithObjects:model.CodeMachine,model.Sex,model.Phone, nil];
            [self.tableView reloadData];
        } else {
            [self showErrorHUD:WSY(@" Fail  ")];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self scrollViewDidScroll:self.tableView];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar lt_reset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)isNilOrEmpty:(NSString*)value
{
    if(value != nil && ![value isKindOfClass:[NSNull class]])
    {
        return value.length == 0;
    }
    
    return YES;
}

- (void)setupNavigationItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"N_Back"].imageForWhite forState:UIControlStateNormal];
    [btn sizeToFit];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
//    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn1 setTitle:@"编辑"  forState:UIControlStateNormal];
//    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btn1 sizeToFit];
//
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    
//    @weakify(self);
//    [[btn1 rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
//        @strongify(self);
//        self.ableEdit = !self.ableEdit;
//
//        if (self.ableEdit) {
//            [btn1 setTitle:@"更新"  forState:UIControlStateNormal];
//            self.ableEdit = YES;
//        }else{
//            [btn1 setTitle:@"编辑"  forState:UIControlStateNormal];
//            self.ableEdit = NO;
//            [self update];
//        }
//    }];
    
//    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)update {
//    NSDictionary *param = @{@"name":_array[0],@"sex":_array[1],@"phone":_array[4],@"certificateNumber":_array[3],@"codeMachine":_str,@"certificate":_array[2]};
//    [[WSYNetworkTool sharedManager]post:WSY_TOUR_UPDATE_INFO params:param success:^(id responseBody) {
//        if ([responseBody[@"d"] isEqualToString:@"更新异常，请联系技术人员"]) {
//            [self showErrorHUD:responseBody[@"d"]];
//        }else{
//            [self showSuccessHUD:@"更新成功"];
//        }
//    } failure:^(NSError *error) {
//
//    }];
//}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark ============UIScrollViewDelegate============

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    UIColor * color = kThemeRedColor;
//    CGFloat offsetY = scrollView.contentOffset.y;
//    
//        if (offsetY > NAVBAR_CHANGE_POINT) {
//            CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - offsetY) / 64));
//             [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
//        } else {
//            [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
//        }
}

#pragma mark ============Table view data source============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WSYSuperInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WSYSuperInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    
    NSArray *array = [NSArray arrayWithObjects:WSY(@"Name"),WSY(@"Sex"),WSY(@"TEL"), nil];
    cell.titleLab.text = array[indexPath.row];
    cell.textField.placeholder = array[indexPath.row];
    
//    if (self.ableEdit == NO) {
        cell.textField.enabled = NO;
//    }else{
//        if (indexPath.row == 4 || indexPath.row == 1) {
//            cell.textField.enabled = NO;
//        } else if(indexPath.row == 3) {
//            cell.textField.enabled = YES;
//            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
//        } else {
//            cell.textField.keyboardType = UIKeyboardTypeDefault;
//            cell.textField.enabled = YES;
//        }
//    }
    
    cell.textField.text = self.array[indexPath.row];
    
//    @weakify(self);
//    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kMan object:nil]subscribeNext:^(id x){
//        @strongify(self);
//        if (indexPath.row == 1) {
//            cell.textField.text = @"男";
//            [self.array removeObjectAtIndex:indexPath.row];
//            [self.array insertObject:@"男" atIndex:indexPath.row];
//
//        }
//    }];
//
//    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kWoman object:nil]subscribeNext:^(id x){
//        @strongify(self);
//        if (indexPath.row == 1) {
//            cell.textField.text = @"女";
//            [self.array removeObjectAtIndex:indexPath.row];
//            [self.array insertObject:@"女" atIndex:indexPath.row];
//        }
//    }];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (self.ableEdit == YES && indexPath.row == 1) {
//        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//        alert.shouldDismissOnTapOutside = YES;
//        [alert setHorizontalButtons:YES];
//        [alert addButton:@"男" actionBlock:^(void) {
//            [[NSNotificationCenter defaultCenter]postNotificationName:kMan object:nil];
//        }];
//        [alert addButton:@"女" actionBlock:^(void) {
//            [[NSNotificationCenter defaultCenter]postNotificationName:kWoman object:nil];
//        }];
//
//        [alert showCustom:self image:[UIImage imageNamed:@"M_sex"] color:kThemeRedColor title:@"请选择性别" subTitle:nil closeButtonTitle:nil duration:0.0f];
//    }
}

@end

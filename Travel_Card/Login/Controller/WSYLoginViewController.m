//
//  WSYLoginViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/25.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYLoginViewController.h"
#import "WSYTabBarController.h"
#import "WSYRootViewController.h"
#import "WSYSuperRootViewController.h"
#import "WSYLoginViewModel.h"
#import <EAIntroView/EAIntroView.h>

static NSString *const kGuide = @"Guide";
static NSString *const kRememberGuideSelect = @"RememberGuideSelect";
static NSString *const kRememberManageSelect = @"RememberManageSelect";
static NSString *const kSavePage = @"SavePage";

@interface WSYLoginViewController ()<UIGestureRecognizerDelegate,EAIntroDelegate,UITextFieldDelegate,CLLocationManagerDelegate>{
    UIView *rootView;
}

@property (weak, nonatomic) IBOutlet UITextField *useName;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
@property (weak, nonatomic) IBOutlet UIButton    *login;
@property (weak, nonatomic) IBOutlet UIButton    *check;
@property (weak, nonatomic) IBOutlet UILabel *company;
@property (weak, nonatomic) IBOutlet UILabel *saveLab;

@property (strong, nonatomic) UISegmentedControl *segment;

@property (nonatomic,strong) WSYLoginViewModel   *loginModel;

@property (nonatomic, assign) BOOL               isGuide;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation WSYLoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[WSYUserDataTool getUserData:kGuideIsLogin]integerValue] == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYTabBarController"];
            [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [self presentViewController:vc animated:YES completion:nil];
        });
    } else if ([[WSYUserDataTool getUserData:kManageIsLogin]integerValue] == 1) {
        if ([[[WSYUserDataTool getUserData:kTravelGencyID] stringValue] isEqualToString:@"-1"]) {
            [WSYUserDataTool removeUserData:kMenu];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"superRootController"];
                [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                [self presentViewController:vc animated:YES completion:nil];
            });
        } else {
            [WSYUserDataTool setUserData:@"0" forKey:kMenu];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"rootController"];
                [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                [self presentViewController:vc animated:YES completion:nil];
            });
        }
    } else {
        [self checkNewVersion];
        //引导页
        if (![[WSYUserDataTool getUserData:kSavePage] isEqualToString:@"save"]) {
            [self showPageControl];
        }
    }
    [self hideHUDWindow];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    [self setupUI];
    [self bindUI];
    [self bindModel];
    if (![[WSYUserDataTool getUserData:kMaps]isEqualToString:@"Maps"]) {
        [self startLocation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    //获取账号密码
    if ([[WSYUserDataTool getUserData:kGuide] integerValue] == 1){
        self.segment.selectedSegmentIndex = 1;
        self.isGuide = YES;
        NSArray *accountAndPassword = [WSYUserDataTool getkGuideAccountAndPassword];
        self.useName.text = accountAndPassword? accountAndPassword[0] : @"";
        
        if ([[WSYUserDataTool getUserData:kRememberGuideSelect] integerValue] == 1) {
            self.pwd.text = accountAndPassword[1];
            self.check.selected = YES;
        }else{
            self.pwd.text = @"";
            self.check.selected = NO;
        }
        if (self.pwd.text.length > 5 && self.useName.text.length > 5) {
            self.login.enabled = YES;
            self.login.alpha = 1.0;
        }else{
            self.login.enabled = NO;
            self.login.alpha = 0.4;
        }
    }else{
        self.segment.selectedSegmentIndex = 0;
        self.isGuide = NO;
        NSArray *accountAndPassword = [WSYUserDataTool getkManageAccountAndPassword];
        self.useName.text = accountAndPassword? accountAndPassword[0] : @"";
        
        if ([[WSYUserDataTool getUserData:kRememberManageSelect] integerValue] == 1) {
            self.pwd.text = accountAndPassword[1];
            self.check.selected = YES;
        }else{
            self.pwd.text = @"";
            self.check.selected = NO;
        }
        
        if (self.pwd.text.length > 5 && self.useName.text.length > 5) {
            self.login.enabled = YES;
            self.login.alpha = 1.0;
        }else{
            self.login.enabled = NO;
            self.login.alpha = 0.4;
        }
    }
}

/**
 初始化UI界面
 */
- (void)setupUI
{
    self.useName.layer.cornerRadius = 5.0f;
    self.useName.layer.borderWidth = 1.0f;
    self.useName.layer.borderColor = kThemeRedColor.CGColor;
    self.useName.layer.masksToBounds = YES;
    UIImageView *userImage = [[UIImageView alloc]initWithFrame:(CGRect){0, 0, 36, 36}];
    userImage.image = [UIImage imageNamed:@"L_userName"];
    self.useName.leftView = userImage;
    self.useName.leftViewMode = UITextFieldViewModeAlways;
    self.useName.delegate = self;
    self.useName.placeholder = WSY(@"Account ");
    
    self.pwd.layer.cornerRadius = 5.0f;
    self.pwd.layer.borderWidth = 1.0f;
    self.pwd.layer.borderColor = kThemeRedColor.CGColor;
    UIImageView *pwdImage = [[UIImageView alloc]initWithFrame:(CGRect){20, 0, 36, 36}];
    pwdImage.image = [UIImage imageNamed:@"L_pwd"];
    self.pwd.leftView = pwdImage;
    self.pwd.leftViewMode = UITextFieldViewModeAlways;
    self.pwd.delegate = self;
    self.pwd.placeholder = WSY(@"Password ");
    
    self.login.layer.cornerRadius = 5.0f;
    self.login.clipsToBounds = YES;
    [self.login setTitle:WSY(@"Log in") forState:UIControlStateNormal];
    
    [self.view addSubview:self.segment];
    [self.segment mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.bottom.equalTo(self.useName.mas_top).offset(-40);
        maker.left.equalTo(self.view).offset(48);
        maker.right.equalTo(self.view.mas_right).offset(-48);
        maker.height.mas_equalTo(36);
    }];
    
    self.saveLab.text = WSY(@"Save ");
    self.company.text = WSY(@"©2017 Smart Guide Information Technology Co., Lt.");
    
    @weakify(self);
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kchangeLanguage object:nil]subscribeNext:^(id x){
        @strongify(self);
        [self.segment setTitle:WSY(@"Management") forSegmentAtIndex:0];
        [self.segment setTitle:WSY(@"Tour Guide") forSegmentAtIndex:1];
        [self.login setTitle:WSY(@"Log in") forState:UIControlStateNormal];
        self.company.text = WSY(@"©2017 Smart Guide Information Technology Co., Lt.");
        self.useName.placeholder = WSY(@"Account ");
        self.pwd.placeholder = WSY(@"Password ");
        self.saveLab.text = WSY(@"Save ");
    }];
}

/**
 绑定登录
 */
- (void)bindModel
{
    self.loginModel = [[WSYLoginViewModel alloc]init];

    RAC(self.loginModel, userName) = self.useName.rac_textSignal;
    RAC(self.loginModel, password) = self.pwd.rac_textSignal;
    RAC(self.login, enabled) = [self.loginModel validSignal];
    
    @weakify(self);
    [self.loginModel.successSubject subscribeNext:^(NSString *str) {
        [self hideHUD];
        [self showSuccessHUDWindow:str];
        if (self.isGuide == YES) {
            [WSYUserDataTool setUserData:@1 forKey:kGuideIsLogin];
            WSYTabBarController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYTabBarController"];
            [tabBar setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [self presentViewController:tabBar animated:YES completion:nil];
        } else {
             [WSYUserDataTool setUserData:@1 forKey:kManageIsLogin];
            if ([[[WSYUserDataTool getUserData:kTravelGencyID] stringValue] isEqualToString:@"-1"]) {
                NSLog(@"0");
                [WSYUserDataTool removeUserData:kMenu];
                WSYSuperRootViewController *rootVc = [self.storyboard instantiateViewControllerWithIdentifier:@"superRootController"];
                [rootVc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                [self presentViewController:rootVc animated:YES completion:nil];
            } else {
                NSLog(@"1");
                [WSYUserDataTool setUserData:@"0" forKey:kMenu];
                WSYRootViewController *rootVc = [self.storyboard instantiateViewControllerWithIdentifier:@"rootController"];
                [rootVc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                [self presentViewController:rootVc animated:YES completion:nil];

            }
        }
        if (self.check.selected == NO) {
            self.pwd.text = @"";
            self.login.enabled = NO;
            self.login.alpha = 0.4;
        }
        NSLog(@"成功");
    }];
    
    [self.loginModel.failureSubject subscribeNext:^(NSString *str) {
        [self hideHUD];
        [self showErrorHUDView:str];
        NSLog(@"失败");
    }];
    
    [self.loginModel.errorSubject subscribeNext:^(id x) {
        [self hideHUD];
    }];
    
    RAC(self.login, alpha) = [[self.loginModel validSignal] map:^(NSNumber *b){
        return b.boolValue ? @1: @0.4;
    }];
    
    
    [[self.login rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
        [self showStrHUD:WSY(@"Loading...")];
        
        if ([[WSYUserDataTool getUserData:kGuide] integerValue] == 1) {
            self.loginModel.isGuide = YES;
            [self.loginModel loginBtn];
        } else {
            self.loginModel.isGuide = NO;
            [self.loginModel loginBtn];
        }
    }];
}

- (void)bindUI
{
    @weakify(self);
    [[self.segment rac_newSelectedSegmentIndexChannelWithNilValue:@0]subscribeNext:^(id x) {
        @strongify(self);
        if ([x integerValue]== 0) {
            [WSYUserDataTool removeUserData:kGuide];
            self.isGuide = NO;
            self.loginModel.isGuide = NO;
            NSArray *accountAndPassword = [WSYUserDataTool getkManageAccountAndPassword];
            self.useName.text = accountAndPassword? accountAndPassword[0] : @"";
            self.loginModel.userName = accountAndPassword? accountAndPassword[0] : @"";
            self.loginModel.password = accountAndPassword? accountAndPassword[1] : @"";
            
            if ([[WSYUserDataTool getUserData:kRememberManageSelect] integerValue] == 1) {
                self.pwd.text = accountAndPassword[1];
                self.check.selected = YES;
            }else{
                self.pwd.text = @"";
                self.check.selected = NO;
            }
            if (self.pwd.text.length > 5 && self.useName.text.length >= 5) {
                self.login.enabled = YES;
                self.login.alpha = 1.0;
            }else{
                self.login.enabled = NO;
                self.login.alpha = 0.4;
            }
        }else{
            [WSYUserDataTool setUserData:@1 forKey:kGuide];
            self.isGuide = YES;
            self.loginModel.isGuide = YES;
            NSArray *accountAndPassword = [WSYUserDataTool getkGuideAccountAndPassword];
            self.useName.text = accountAndPassword? accountAndPassword[0] : @"";
            self.loginModel.userName = accountAndPassword? accountAndPassword[0] : @"";
            self.loginModel.password = accountAndPassword? accountAndPassword[1] : @"";
            
            if ([[WSYUserDataTool getUserData:kRememberGuideSelect] integerValue] == 1) {
                self.pwd.text = accountAndPassword[1];
                self.check.selected = YES;
            }else{
                self.pwd.text = @"";
                self.check.selected = NO;
            }
            if (self.pwd.text.length > 5 && self.useName.text.length > 5) {
                self.login.enabled = YES;
                self.login.alpha = 1.0;
            }else{
                self.login.enabled = NO;
                self.login.alpha = 0.4;
            }
        }
    }];
    
    [[self.check rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
        @strongify(self);
        self.check.selected = !self.check.selected;
        if (self.check.selected) {
            if (self.isGuide == YES) {
                [WSYUserDataTool setUserData:@1 forKey:kRememberGuideSelect];
            }else{
                [WSYUserDataTool setUserData:@1 forKey:kRememberManageSelect];
            }
        }else{
            if (self.isGuide == YES) {
                [WSYUserDataTool removeUserData:kRememberGuideSelect];
            }else{
                [WSYUserDataTool removeUserData:kRememberManageSelect];
            }
        }
    }];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]init];
    [[recognizer rac_gestureSignal]subscribeNext:^(id x){
        @strongify(self);
        [self.useName resignFirstResponder];
        [self.pwd resignFirstResponder];
    }];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
}

/** 引导页 */
-(void)showPageControl
{
    rootView = self.view;
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.bgImage = [UIImage imageNamed:WSY(@"M_BG1")];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:WSY(@"M_BG2")];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.bgImage = [UIImage imageNamed:WSY(@"M_BG3")];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.bgImage = [UIImage imageNamed:WSY(@"M_BG4")];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:rootView.bounds];
    intro.pageControl.currentPageIndicatorTintColor = kThemeRedColor;
    intro.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [intro setDelegate:self];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, kScreenWidth/2 , 70)];
    [btn setTitle:WSY(@"Use now") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:kThemeRedColor];
    btn.layer.borderWidth = 2.f;
    btn.layer.cornerRadius = 10;
    btn.layer.borderColor = [kThemeRedColor CGColor];
    intro.skipButton = btn;
    intro.skipButtonAlignment = EAViewAlignmentCenter;
    intro.skipButtonY = 140.f;
    intro.pageControlY = 62.f;
    intro.skipButton.enabled = NO;
    intro.skipButton.alpha = 0.f;
    
    page4.onPageDidAppear = ^{
        intro.skipButton.enabled = YES;
        intro.limitPageIndex = intro.visiblePageIndex;
        [UIView animateWithDuration:0.3f animations:^{
            intro.skipButton.alpha = 1.f;
        }];
    };
    
    page4.onPageDidDisappear = ^{
        intro.skipButton.enabled = NO;
        [intro setScrollingEnabled:YES];
        [UIView animateWithDuration:0.3f animations:^{
            intro.skipButton.alpha = 0.f;
        }];
    };
    
    [intro setPages:@[page1,page2,page3,page4]];
    
    [intro showInView:rootView animateDuration:0.3];
    [WSYUserDataTool setUserData:@"save" forKey:kSavePage];
}

/** 检测版本更新 */
- (void)checkNewVersion
{
    NSString *urlStr = @"http://itunes.apple.com/lookup?id=1217302886";
    [[WSYNetworkTool sharedManager]post:urlStr params:nil successs:^(id responseBody) {
        NSArray *resultsArray = [responseBody objectForKey:@"results"];
        if (![resultsArray count]) {
            NSLog(@"error: resultsArray == nil");
            return ;
        }

        NSDictionary *infoDic = [resultsArray objectAtIndex:0];
        NSString *latesVersion = [infoDic objectForKey:@"version"];
        
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
        
        double doubleCurrentVersion = [currentVersion doubleValue];
        double doubleUpdateVersion = [latesVersion doubleValue];

        if (doubleCurrentVersion > doubleUpdateVersion) {
            NSLog(@"本地大于线上版本");
            return;
        }
        
        NSArray * serverArray = [latesVersion componentsSeparatedByString:@"."];
        NSArray * localArray = [currentVersion componentsSeparatedByString:@"."];

        for (int i = 0; i < serverArray.count; i++) {
            //以服务器版本为基准，判断本地版本位数小于服务器版本时，直接返回（并且判断为新版本，比如服务器1.5.1 本地为1.5）
            if(i > (localArray.count - 1)){
                return;
            }
            
            //有新版本，服务器版本对应数字大于本地
            if ( [serverArray[i] intValue] > [localArray[i] intValue] ) {
                NSString *title = WSY(@"Update Notification");
                NSString *messageStr = [NSString stringWithFormat:@"%@(%@),%@",WSY(@"Find a new version of "),latesVersion,WSY(@"Do you want to update?")];
                
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                alert.shouldDismissOnTapOutside = YES;
                [alert setHorizontalButtons:YES];
                [alert addButton:WSY(@"Updating") actionBlock:^(void) {
                    [WSYUserDataTool removeUserData:kSavePage];
                    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/zhi-hui-bei-dou/id1217302886?mt=8"];
                    [[UIApplication sharedApplication]openURL:url];
                }];
                alert.completeButtonFormatBlock = ^NSDictionary* (void) {
                    NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
                    buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
                    return buttonConfig;
                };
                
                
                [alert showCustom:self image:[UIImage imageNamed:@"L_update"] color:kThemeRedColor title:title subTitle:messageStr closeButtonTitle:WSY(@"Cancel") duration:0.0f];
                
            }
        }

    } failure:^(NSError *error) {
        
    }];
    
}

#pragma mark ==========懒加载==========

- (UISegmentedControl *)segment
{
    if (!_segment) {
        _segment = [[UISegmentedControl alloc]initWithItems:@[WSY(@"Management"),WSY(@"Tour Guide")]];
        _segment.selectedSegmentIndex = 0;
        UIFont *font = [UIFont systemFontOfSize:16.0f];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        [_segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [_segment setTintColor:kThemeRedColor];
    }
    return _segment;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == _pwd){
        //4s 5 5s
        if (kScreenWidth == 320) {
            self.pwd.frame = CGRectMake(self.pwd.frame.origin.x, self.pwd.frame.origin.y - 20, self.pwd.frame.size.width, self.pwd.frame.size.height);
            self.useName.frame = CGRectMake(self.useName.frame.origin.x, self.useName.frame.origin.y - 10, self.useName.frame.size.width, self.useName.frame.size.height);
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == _pwd){
        //4s 5 5s
        if (kScreenWidth == 320) {
            self.pwd.frame = CGRectMake(self.pwd.frame.origin.x, self.pwd.frame.origin.y + 20, self.pwd.frame.size.width, self.pwd.frame.size.height);
            self.useName.frame = CGRectMake(self.useName.frame.origin.x, self.useName.frame.origin.y + 10, self.useName.frame.size.width, self.useName.frame.size.height);
        }
    }
}

#pragma mark============判断国内国外============
//开始定位
- (void)startLocation
{
    if ([CLLocationManager locationServicesEnabled])
    {
        //        CLog(@"--------开始定位");
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        //控制定位精度,越高耗电量越
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter = 10.0f;
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}
//定位代理经纬度回调
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *newLocation = locations[0];
    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error){
        if (array.count > 0){
            CLPlacemark *placemark = [array objectAtIndex:0];
            
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            NSLog(@"%@",placemark.country);
            
            if ([placemark.country isEqualToString:@"中国"] || [placemark.country isEqualToString:@"China"]) {
                [WSYUserDataTool removeUserData:kForeign];
            } else {
                [WSYUserDataTool setUserData:@"Foreign" forKey:kForeign];
            }
        
        }
        else if (error == nil && [array count] == 0)
        {
            [WSYUserDataTool setUserData:@"Foreign" forKey:kForeign];
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            [WSYUserDataTool setUserData:@"Foreign" forKey:kForeign];
            NSLog(@"An error occurred = %@", error);
        }
    }];
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
    
}

@end


//
//  WSYModifyPasswordViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/28.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYModifyPasswordViewController.h"
#import "JPUSHService.h"

@interface WSYModifyPasswordViewController ()<MDTextFieldDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) MDTextField *oldPwd;
@property (nonatomic, strong) MDTextField *pwd;
@property (nonatomic, strong) MDTextField *repeatPwd;

@property (nonatomic, strong) UIButton *saveBtn;

@property (assign,nonatomic) NSString *password;

@end

@implementation WSYModifyPasswordViewController

static NSInteger seq = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = WSY(@"Change Password");
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.oldPwd.delegate    = self;
    self.pwd.delegate       = self;
    self.repeatPwd.delegate = self;
    self.saveBtn.enabled    = NO;
    self.saveBtn.alpha      = 0.4;

    [self.view addSubview:self.oldPwd];
    [self.view addSubview:self.pwd];
    [self.view addSubview:self.repeatPwd];
    [self.view addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.repeatPwd.mas_top).offset(120);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(40);
    }];
    
    [self.oldPwd becomeFirstResponder];
    
    self.password = [WSYUserDataTool getkGuideAccountAndPassword][1];
    
    @weakify(self);
    [[self.saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        @strongify(self);
        if ([self.password isEqualToString:self.pwd.text]) {
            [self showErrorHUDView:WSY(@"New password cannot be the same as current password")];
            return ;
        }
        [self showHUDWithStr:WSY(@"Updating...")];
        NSDictionary *param = @{@"TravelAgencyID":[WSYUserDataTool getUserData:kTravelGencyID],@"TouristTeamID":[WSYUserDataTool getUserData:kGuideID],@"Account":[WSYUserDataTool getkGuideAccountAndPassword][0],@"Password":self.pwd.text};
        [[WSYNetworkTool sharedManager]post:WSY_UPDATE_PASSWORD params:param success:^(id responseBody) {
            [self hideNaHUD];
            SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
            NSString *codeStr = [NSString stringWithFormat:@"%@",responseBody[@"Code"]];
            if ([codeStr isEqualToString:@"0"]) {
                [alert addButton:WSY(@"OK") actionBlock:^(void) {
                    [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                        NSLog(@"%ld====%@=====%ld",(long)iResCode,iAlias,(long)seq);
                    } seq:[self seq]];
                    [WSYUserDataTool removeUserData:kGuideIsLogin];
                    [WSYUserDataTool removeUserData:kLogoutLanguage];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert showSuccess:WSY(@"Safety tips") subTitle:WSY(@"Password update succeeded, please log in again!") closeButtonTitle:nil duration:0.0f];
            }else{
                [alert showError:WSY(@"Update failure") subTitle:nil closeButtonTitle:nil duration:1.0f];
            }
        } failure:^(NSError *error) {
            [self hideNaHUD];
        }];
        
        NSDictionary *paramm = @{@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID]};
        [[WSYNetworkTool sharedManager]post:WSY_TEAM_LOGOUT params:paramm success:^(id responseBody) {
            
        } failure:^(NSError *error) {
            
        }];
    }];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]init];
    [[recognizer rac_gestureSignal]subscribeNext:^(id x){
        @strongify(self);
        [self.oldPwd resignFirstResponder];
        [self.pwd resignFirstResponder];
        [self.repeatPwd resignFirstResponder];
    }];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)seq {
    return ++ seq;
}

#pragma mark ============懒加载============

-(MDTextField *)oldPwd{
    if (!_oldPwd) {
        _oldPwd = ({
            MDTextField *oldPwd = [[MDTextField alloc]initWithFrame:({
                CGRect frame = (CGRect){20, 80, kScreenWidth - 40, 80};
                frame;
            })];
            oldPwd.label = WSY(@"Input current password");
            oldPwd.floatingLabel = YES;
            oldPwd.highlightLabel = YES;
            oldPwd.maxCharacterCount = 10;
            oldPwd.singleLine = YES;
            oldPwd.secureTextEntry = YES;
            oldPwd.highlightColor = kThemeOrangeColor;
            oldPwd.errorColor = kThemeRedColor;
            oldPwd;
        });
    }
    return _oldPwd;
}

-(MDTextField *)pwd{
    if (!_pwd) {
        _pwd = ({
            MDTextField *pwd = [[MDTextField alloc]initWithFrame:({
                CGRect frame = (CGRect){20, 160, kScreenWidth - 40, 80};
                frame;
            })];
            pwd.label = WSY(@"Input new password");
            pwd.floatingLabel = YES;
            pwd.highlightLabel = YES;
            pwd.maxCharacterCount = 10;
            pwd.singleLine = YES;
            pwd.secureTextEntry = YES;
            pwd.highlightColor = kThemeOrangeColor;
            pwd.errorColor = kThemeRedColor;
            pwd;
        });
    }
    return _pwd;
}

-(MDTextField *)repeatPwd{
    if (!_repeatPwd) {
        _repeatPwd = ({
            MDTextField *repeatPwd = [[MDTextField alloc]initWithFrame:({
                CGRect frame = (CGRect){20, 245, kScreenWidth - 40, 80};
                frame;
            })];
            repeatPwd.label = WSY(@"Confirm new password");
            repeatPwd.floatingLabel = YES;
            repeatPwd.highlightLabel = YES;
            repeatPwd.maxCharacterCount = 10;
            repeatPwd.singleLine = YES;
            repeatPwd.secureTextEntry = YES;
            repeatPwd.highlightColor = kThemeOrangeColor;
            repeatPwd.errorColor = kThemeRedColor;
            repeatPwd;
        });
    }
    return _repeatPwd;
}

-(UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = ({
            UIButton *saveBtn = [[UIButton alloc]init];
            [saveBtn setTitle:WSY(@"OK") forState:UIControlStateNormal];
            saveBtn.layer.cornerRadius = 5.0;
            saveBtn.backgroundColor = kThemeRedColor;
            saveBtn;
        });
    }
    return _saveBtn;
}

#pragma mark ============MDTextFieldDelegate============

- (void)textFieldDidChange:(MDTextField *)textField {
    if (textField.text.length < 6 && textField.text.length > 0) {
        textField.hasError = YES;
        textField.errorMessage = WSY(@"Password length should be at least 6 bits");
    }else if (textField.text.length > textField.maxCharacterCount){
        textField.text = [NSString stringWithFormat:@"%@",[textField.text substringToIndex:10]];
        textField.hasError = YES;
        textField.errorMessage = WSY(@"Maximum length of the password is 10 bits");
    }else {
        textField.hasError = NO;
    }
    
    if (self.oldPwd.text.length > 5 && self.pwd.text.length > 5 && self.repeatPwd.text.length > 5) {
        if (self.repeatPwd.text != self.pwd.text) {
            self.repeatPwd.hasError = YES;
            self.repeatPwd.errorMessage = WSY(@"Inconsistencies in password");
            self.saveBtn.enabled = NO;
            self.saveBtn.alpha = 0.4;
        } else if (![self.password isEqualToString:self.oldPwd.text]) {
            self.saveBtn.enabled = NO;
            self.saveBtn.alpha = 0.4;
        } else {
            self.repeatPwd.hasError = NO;
            self.saveBtn.enabled = YES;
            self.saveBtn.alpha = 1.0;
        }
    } else {
        self.saveBtn.enabled = NO;
        self.saveBtn.alpha = 0.4;
    }
}

- (BOOL)textFieldShouldReturn:(MDTextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(MDTextField *)textField {
    if (textField == self.pwd || textField == self.repeatPwd) {
        if (![self.password isEqualToString:self.oldPwd.text] ) {
            self.oldPwd.hasError = YES;
            self.oldPwd.errorMessage = WSY(@"Wrong password");
        }
    } else {
        self.oldPwd.hasError = NO;
    }
}

@end

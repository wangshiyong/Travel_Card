//
//  WSYReleaseViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/9.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYReleaseViewController.h"
#import "UITextView+Placeholder.h"

@interface WSYReleaseViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITextView  *textView;
@property (nonatomic, strong) UILabel     *hintLab;
@property (nonatomic, strong) UILabel     *numLab;
@property (nonatomic, strong) UIButton    *releaseBtn;

@end

@implementation WSYReleaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = WSY(@"Post Itinerary");
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self setupUI];
    
    if (self.isMemberRelease == YES) {
        UIBarButtonItem *barbtn=[[UIBarButtonItem alloc] initWithTitle:WSY(@"Cancel") style:UIBarButtonItemStyleDone target:self action:@selector(dismissVc)];
        self.navigationItem.rightBarButtonItem=barbtn;
    }
    
    @weakify(self);
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]init];
    [[recognizer rac_gestureSignal]subscribeNext:^(id x){
        @strongify(self);
        [self.textView resignFirstResponder];
    }];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissVc {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupUI {
    @weakify(self);
    [self.view addSubview:self.textView];
    if (IS_IPHONE_5) {
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make){
            @strongify(self);
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.top.equalTo(self.view).offset(84);
            make.height.mas_equalTo(120);
        }];
    } else if (IS_IPHONE_X){
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make){
            @strongify(self);
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.top.equalTo(self.view).offset(114);
            make.height.mas_equalTo(180);
        }];
    } else {
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make){
            @strongify(self);
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.top.equalTo(self.view).offset(84);
            make.height.mas_equalTo(180);
        }];
    }

    
    [self.view addSubview:self.hintLab];
    [self.hintLab mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.textView.mas_bottom).offset(10);
        make.width.mas_equalTo(kScreenWidth - 100);
    }];
    
    [self.view addSubview:self.numLab];
    [self.numLab mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.textView.mas_bottom).offset(10);
        make.width.mas_equalTo(100);
    }];
    
    [self.view addSubview:self.releaseBtn];
    [self.releaseBtn mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.numLab.mas_bottom).offset(20);
        make.height.mas_equalTo(40);
    }];
    
    [self.textView becomeFirstResponder];
    
    [self controlMonitor];
}

//监听
- (void)controlMonitor {
    @weakify(self);
    [self.textView.rac_textSignal subscribeNext:^(NSString *str){
        @strongify(self);
        if (str.length > 0) {
            self.releaseBtn.enabled = YES;
            self.releaseBtn.alpha = 1.0;
        }else{
            self.releaseBtn.enabled = NO;
            self.releaseBtn.alpha = 0.4;
        }
//        if (![self matchStringFormat:str withRegex:@"^[\u4e00-\u9fa5\\u0030-\\u0039]*$"]) {
//            [self showInfoFromTitle:@"请输入中文或者数字"];
//        }

        if (str.length >= 50) {
            self.textView.text = [NSString stringWithFormat:@"%@",[str substringToIndex:50]];
            self.numLab.textColor = kThemeRedColor;
            self.hintLab.text = WSY(@"Reminder: input no more than 50 bits");
            self.numLab.text = @"50/50";
        }else{
            self.hintLab.text = @"";
            self.numLab.textColor = [UIColor grayColor];
            self.numLab.text = [NSString stringWithFormat:@"%lu/50",(unsigned long)str.length];
        }
    }];
    
    [[self.releaseBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x){
        @strongify(self);
//        if (![self matchStringFormat:self.textView.text withRegex:@"^[\u4e00-\u9fa5\\u0030-\\u0039]*$"]) {
//            [self showInfoFromTitle:@"请输入中文或者数字"];
//            return ;
//        }
        if (self.isMemberRelease == YES) {
            [self showHUDWithStr:WSY(@"Posting...")];
            NSDictionary *param = @{@"MemberID":self.memberID,@"TouristTeamID":[WSYUserDataTool getUserData:kGuideID],@"Subject": self.deviceID,@"Content":self.textView.text};
            [[WSYNetworkTool sharedManager]post:WSY_TRIP_MEMBER params:param success:^(id responseBody) {
                [self hideNaHUD];
                if ([responseBody[@"Code"] intValue] == 0 ) {
                    [self showSuccessHUDWindow:WSY(@"Success  ")];
                    [self dismissVc];
                }else{
                    [self showErrorHUDView:WSY(@"No location, post fail")];
                }
            } failure:^(NSError *error) {
                [self hideNaHUD];
            }];

        } else {
            [self showHUDWithStr:WSY(@"Posting...")];
            NSDictionary *param = @{@"TravelGencyID":[WSYUserDataTool getUserData:kTravelGencyID],@"TouristTeamID":[WSYUserDataTool getUserData:kGuideID],@"Subject": WSY(@"Itinerary"),@"Content":self.textView.text};
            [[WSYNetworkTool sharedManager]post:WSY_CREATE_TRIP params:param success:^(id responseBody) {
                [self hideNaHUD];
                if ([responseBody[@"Code"] intValue] == 0 ) {
                    [self showSuccessHUDWindow:WSY(@"Success  ")];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kReleaseNotice object:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    [self showErrorHUDView:WSY(@" Fail ")];
                }
            } failure:^(NSError *error) {
                [self hideNaHUD];
            }];
        }
    }];
}

#pragma mark - 正则判断
- (BOOL)matchStringFormat:(NSString *)matchedStr withRegex:(NSString *)regex
{
    //SELF MATCHES一定是大写
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:matchedStr];
}

#pragma mark ============懒加载============

-(UITextView *)textView{
    if (!_textView) {
        _textView = ({
            UITextView *textView = [[UITextView alloc]init];
            textView.backgroundColor = [UIColor whiteColor];
            textView.layer.cornerRadius = 10.0;
            textView.font = [UIFont systemFontOfSize:17.0f];
            textView.placeholder = WSY(@"Please input itinerary content");
            textView;
        });
    }
    return _textView;
}

-(UILabel *)hintLab{
    if (!_hintLab) {
        _hintLab = ({
            UILabel *hintLab = [[UILabel alloc]init];
            hintLab.textColor = kThemeRedColor;
            hintLab.font = [UIFont systemFontOfSize:IS_IPHONE_5 ? 12.0f : 15.0f];
            hintLab;
        });
    }
    return _hintLab;
}

-(UILabel *)numLab{
    if (!_numLab) {
        _numLab = ({
            UILabel *numLab = [[UILabel alloc]init];
            numLab.textColor = [UIColor lightGrayColor];
            numLab.textAlignment = NSTextAlignmentRight;
            numLab.font = [UIFont systemFontOfSize:15.0f];
            numLab.text = @"0/50";
            numLab;
        });
    }
    return _numLab;
}

-(UIButton *)releaseBtn{
    if (!_releaseBtn) {
        _releaseBtn = ({
            UIButton *releaseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [releaseBtn setTitle:WSY(@"Post") forState:UIControlStateNormal];
            [releaseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            releaseBtn.titleLabel.font = [UIFont systemFontOfSize:19.0];
            releaseBtn.layer.cornerRadius = 5.0;
            releaseBtn.backgroundColor = kThemeRedColor;
            releaseBtn;
        });
    }
    return _releaseBtn;
}

@end

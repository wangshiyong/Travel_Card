//
//  WSYScanViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/24.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYScanViewController.h"
#import "UINavigationBar+Awesome.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+Tint.h"
#import "WSYButton.h"
#import "SGQRCode.h"

@interface WSYScanViewController () <SGQRCodeScanManagerDelegate>

@property (nonatomic, strong) SGQRCodeScanManager *manager;
@property (nonatomic, strong) SGQRCodeScanningView *scanningView;
@property (nonatomic, strong) WSYButton *flashlightBtn;
@property (nonatomic, strong) WSYButton *inputBtn;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UILabel *hitLabel;
@property (nonatomic, assign) BOOL isfrishScan;

@end

@implementation WSYScanViewController

#pragma mark ============生命周期============

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scanningView addTimer];
//    [self.manager resetSampleBufferDelegate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.scanningView removeTimer];
//    [self.manager cancelSampleBufferDelegate];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.navigationController.navigationBar lt_reset];
    [SGQRCodeHelperTool SG_CloseFlashlight];
}

- (void)dealloc
{
    NSLog(@"SGQRCodeScanningVC - dealloc");
    [self removeScanningView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = WSY(@"Scan");
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"N_Back"].imageForWhite forState:UIControlStateNormal];
    [btn sizeToFit];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftItem;

    [self.view addSubview:self.promptLabel];
    [self.view addSubview:self.flashlightBtn];
    [self.view addSubview:self.inputBtn];
    [self.view addSubview:self.hitLabel];


    self.isfrishScan = YES;
    [self showHUDWindow];
    //扫描
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view addSubview:self.scanningView];
        [self.view sendSubviewToBack:self.scanningView];
        [self hideHUDWindow];
        [self setupSGQRCodeScanning];
    });
    
    @weakify(self);
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil]subscribeNext:^(id x){
        @strongify(self);
        self.flashlightBtn.selected = NO;
        [self.flashlightBtn setImage:[UIImage imageNamed:@"M_open"] forState:UIControlStateNormal];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)removeScanningView
{
    [self.scanningView removeTimer];
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
}

- (void)setupSGQRCodeScanning
{
    self.manager = [SGQRCodeScanManager sharedManager];
    NSArray *arr = @[AVMetadataObjectTypeCode128Code];  //AVMetadataObjectTypeQRCode
    // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
    [self.manager setupSessionPreset:AVCaptureSessionPresetHigh metadataObjectTypes:arr currentController:self];
    [self.manager cancelSampleBufferDelegate];
    self.manager.delegate = self;
}

- (void)back
{
    [self.rt_navigationController popViewControllerAnimated:YES];
}

#pragma mark ============点击事件============

- (void)light_buttonAction:(UIButton *)button
{
    if (button.selected == NO) {
        [SGQRCodeHelperTool SG_openFlashlight];
        button.selected = YES;
    } else {
        [SGQRCodeHelperTool SG_CloseFlashlight];
        button.selected = NO;
    }
}

- (void)input_buttonAction:(UIButton *)button
{
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    [alert setHorizontalButtons:YES];
    SCLTextView *textField = [alert addTextField:WSY(@"Please input equipment code")];
//    textField.keyboardType = UIKeyboardTypeNumberPad;
    [alert addButton:WSY(@"OK") actionBlock:^(void) {
        NSString *str = textField.text;
        if (str.length == 7) {
            NSDictionary *param = @{@"TravelGencyID":[WSYUserDataTool getUserData:kTravelGencyID],@"TouristTeamID":[WSYUserDataTool getUserData:kGuideID],@"sex":WSY(@"Male"),@"CodeCodeMachine":str};
            [[WSYNetworkTool sharedManager]post:WSY_ADD_TOURIST params:param success:^(id responseBody) {
                AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc]init];
                if ([responseBody[@"Code"] integerValue] == 0) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:kScanSuccess object:nil];
//                    AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc]init];
                    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:[NSString stringWithFormat:@"%@ %@",str,WSY(@"  Success  ")]];
                    utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
                    if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[1]]) {
                        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
                    } else {
                        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
                    }
                    [av speakUtterance:utterance];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        _isfrishScan = YES;
                    });
                    self.hitLabel.text = [NSString stringWithFormat:@"%@ %@",str,WSY(@"  Success  ")];
                } else {
                    if ([responseBody[@"Message"] hasPrefix:@"该设备"]) {
                        [self showErrorHUD:[NSString stringWithFormat:@"%@ %@",str,WSY(@"has been bound")]];
                        self.hitLabel.text = [NSString stringWithFormat:@"%@ %@",str,WSY(@"has been bound")];
                        
                        if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[1]]) {
                            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:WSY(@"has been bound")];
                            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
                            [av speakUtterance:utterance];
                        } else {
                            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:WSY(@"has been bound")];
                            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
                            [av speakUtterance:utterance];
                        }
                    } else if ([responseBody[@"Message"] hasPrefix:@"设备未"]) {
                        [self showErrorHUD:[NSString stringWithFormat:@"%@ %@",str,WSY(@"din't join the travel agency")]];
                        self.hitLabel.text = [NSString stringWithFormat:@"%@ %@",str,WSY(@"din't join the travel agency")];
                        
                        if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[1]]) {
                            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:WSY(@"din't join the travel agency")];
                            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
                            [av speakUtterance:utterance];
                        } else {
                            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:WSY(@"din't join the travel agency")];
                            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
                            [av speakUtterance:utterance];
                        }
                    } else {
                        [self showErrorHUD:[NSString stringWithFormat:@"%@ %@",str,WSY(@"It has exceeded the upper limit")]];
                        self.hitLabel.text = [NSString stringWithFormat:@"%@ %@",str,WSY(@"It has exceeded the upper limit")];
                        
                        if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[1]]) {
                            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:WSY(@"It has exceeded the upper limit")];
                            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
                            [av speakUtterance:utterance];
                        } else {
                            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:WSY(@"It has exceeded the upper limit")];
                            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
                            [av speakUtterance:utterance];
                        }
                    }

//                    [self.manager palySoundName:@"soundd.caf"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        _isfrishScan = YES;
                    });
                }
            } failure:^(NSError *error) {
//                [self.manager startRunning];
            }];
        } else {
            [self showInfoFromTitle:WSY(@"Please input equipment code")];
        }
    }];
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:[UIImage imageNamed:@"M_input2"] color:kThemeRedColor title:WSY(@"Add equipment") subTitle:WSY(@"Sure to add equipment?") closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}

#pragma mark ============懒加载============

- (SGQRCodeScanningView *)scanningView
{
    if (!_scanningView) {
        _scanningView = [[SGQRCodeScanningView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _scanningView.scanningImageName = @"M_LineGrid";
        _scanningView.scanningAnimationStyle = ScanningAnimationStyleGrid;
        _scanningView.cornerColor = [UIColor orangeColor];
    }
    return _scanningView;
}

- (UILabel *)promptLabel
{
    if (!_promptLabel) {
        _promptLabel = ({
            UILabel *promptLabel = [[UILabel alloc]initWithFrame:({
                CGRect frame = (CGRect){0, 0.2 * kScreenHeight + 20, kScreenWidth, 25};
                frame;
            })];
            promptLabel.textAlignment = NSTextAlignmentCenter;
            promptLabel.font = [UIFont boldSystemFontOfSize:15.0];
            promptLabel.textColor = [UIColor whiteColor];
            promptLabel.text = WSY(@"Scan automatically within the frame");
            promptLabel;
        });
    }
    return _promptLabel;
}

- (UILabel *)hitLabel
{
    if (!_hitLabel) {
        _hitLabel = ({
            UILabel *hitLabel = [[UILabel alloc]initWithFrame:({
                CGRect frame = (CGRect){0, 0.2 * kScreenHeight -20, kScreenWidth, 25};
                frame;
            })];
            hitLabel.textAlignment = NSTextAlignmentCenter;
            hitLabel.font = [UIFont boldSystemFontOfSize:15.0];
            hitLabel.textColor = [UIColor whiteColor];
            hitLabel;
        });
    }
    return _hitLabel;
}

- (WSYButton *)flashlightBtn
{
    if (!_flashlightBtn) {
        _flashlightBtn = ({
            WSYButton *flashlightBtn = [WSYButton buttonWithType:UIButtonTypeCustom];
            flashlightBtn.frame = (CGRect){kScreenWidth - 160, kScreenHeight - 100, 120, 80};
            [flashlightBtn setImage:[UIImage imageNamed:@"M_open"] forState:UIControlStateNormal];
            [flashlightBtn setImage:[UIImage imageNamed:@"M_off"] forState:UIControlStateSelected];
            [flashlightBtn addTarget:self action:@selector(light_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [flashlightBtn setTitle:WSY(@"Turn on") forState:UIControlStateNormal];
            [flashlightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            flashlightBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            flashlightBtn.buttonPosition = PositionedButtonTypeTitleBottom;
            flashlightBtn.imageTitleSpacing = 15.0f;
            flashlightBtn;
        });
    }
    return _flashlightBtn;
}

- (WSYButton *)inputBtn
{
    if (!_inputBtn) {
        _inputBtn = ({
            WSYButton *inputBtn = [WSYButton buttonWithType:UIButtonTypeCustom];
            inputBtn.frame = (CGRect){40, kScreenHeight - 100, 120, 80};
            [inputBtn setImage:[UIImage imageNamed:@"M_input"] forState:UIControlStateNormal];
            [inputBtn addTarget:self action:@selector(input_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [inputBtn setTitle:WSY(@"Input") forState:UIControlStateNormal];
            [inputBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            inputBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            inputBtn.buttonPosition = PositionedButtonTypeTitleBottom;
            inputBtn.imageTitleSpacing = 15.0f;
            inputBtn;
        });
    }
    return _inputBtn;
}

#pragma mark ============SGQRCodeScanManagerDelegate============

- (void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects
{
    NSString *stringValue = [NSString string];
    if (metadataObjects != nil && metadataObjects.count > 0) {
//        [scanManager palySoundName:@"SGQRCode.bundle/sound.caf"];
//        [scanManager stopRunning];
//        [scanManager videoPreviewLayerRemoveFromSuperlayer];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];

        stringValue = [obj stringValue];
        
        if (_isfrishScan) {
            _isfrishScan = NO;
            NSDictionary *param = @{@"TravelGencyID":[WSYUserDataTool getUserData:kTravelGencyID],@"TouristTeamID":[WSYUserDataTool getUserData:kGuideID],@"sex":WSY(@"Male"),@"CodeCodeMachine":stringValue};
            [[WSYNetworkTool sharedManager]post:WSY_ADD_TOURIST params:param success:^(id responseBody) {
                AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc]init];
                if ([responseBody[@"Code"] integerValue] == 0) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:kScanSuccess object:nil];
                    //                    AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc]init];
                    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:[NSString stringWithFormat:@"%@ %@",stringValue,WSY(@"  Success  ")]];
                    utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
                    if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[1]]) {
                        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
                    } else {
                        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
                    }
                    [av speakUtterance:utterance];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        _isfrishScan = YES;
                    });
                    self.hitLabel.text = [NSString stringWithFormat:@"%@ %@",stringValue,WSY(@"  Success  ")];
                } else {
                    if ([responseBody[@"Message"] hasPrefix:@"该设备"]) {
                        [self showErrorHUD:[NSString stringWithFormat:@"%@ %@",stringValue,WSY(@"has been bound")]];
                        self.hitLabel.text = [NSString stringWithFormat:@"%@ %@",stringValue,WSY(@"has been bound")];
                        
                        if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[1]]) {
                            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:WSY(@"has been bound")];
                            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
                            [av speakUtterance:utterance];
                        } else {
                            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:WSY(@"has been bound")];
                            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
                            [av speakUtterance:utterance];
                        }
                    } else if ([responseBody[@"Message"] hasPrefix:@"设备未"]) {
                        [self showErrorHUD:[NSString stringWithFormat:@"%@ %@",stringValue,WSY(@"din't join the travel agency")]];
                        self.hitLabel.text = [NSString stringWithFormat:@"%@ %@",stringValue,WSY(@"din't join the travel agency")];
                        
                        if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[1]]) {
                            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:WSY(@"din't join the travel agency")];
                            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
                            [av speakUtterance:utterance];
                        } else {
                            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:WSY(@"din't join the travel agency")];
                            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
                            [av speakUtterance:utterance];
                        }
                    } else {
                        [self showErrorHUD:[NSString stringWithFormat:@"%@ %@",stringValue,WSY(@"It has exceeded the upper limit")]];
                        self.hitLabel.text = [NSString stringWithFormat:@"%@ %@",stringValue,WSY(@"It has exceeded the upper limit")];
                        
                        if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[1]]) {
                            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:WSY(@"It has exceeded the upper limit")];
                            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
                            [av speakUtterance:utterance];
                        } else {
                            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:WSY(@"It has exceeded the upper limit")];
                            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
                            [av speakUtterance:utterance];
                        }
                    }
                    
                    //                    [self.manager palySoundName:@"soundd.caf"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        _isfrishScan = YES;
                    });
                }
            } failure:^(NSError *error) {
                _isfrishScan = YES;
            }];
        }
    } else {
        NSLog(@"暂未识别出扫描的二维码");
    }
}


@end
    

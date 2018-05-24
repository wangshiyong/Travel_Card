//
//  WSYSettingViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/27.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYSettingViewController.h"

// Controllers
#import "WSYWorkModeViewController.h"
#import "WSYModifyPasswordViewController.h"
#import "WSYContactsViewController.h"
#import "WSYAboutViewController.h"

// Views
#import "WSYSettingCell.h"
#import "JPUSHService.h"
#import "WSYTabBarController.h"

#define WSYCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

typedef NS_ENUM(NSInteger, WSYSettingSection) {
    WSYSettingSectionContacts  = 0,
    WSYSettingSectionShutDown  = 1,
    WSYSettingSectionLanguage  = 2,
    WSYSettingSectionAbout     = 3,
    WSYSettingSectionLogout    = 4,
};

@interface WSYSettingViewController ()

@property (strong, nonatomic) NSMutableString *currentLanguage;

@end

@implementation WSYSettingViewController

static NSInteger seq = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kWebNotice object:nil]subscribeNext:^(id x){
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    _currentLanguage = [[WSYLanguageTool currentLanguageCode] mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ============点击事件============

/**
 设备关机
 */
- (void)powerOff {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    [alert addButton:WSY(@"OK") actionBlock:^(void) {
//        NSString *tsnStr = [WSYUserDataTool getUserData:kGuideID];
        @weakify(self);
        [self showStrHUD:WSY(@"Setting...")];
        NSDictionary *param = @{@"TravelGencyID": [WSYUserDataTool getUserData:kTravelGencyID],@"TouristTeamID":[WSYUserDataTool getUserData:kGuideID]};
        [[WSYNetworkTool sharedManager]post:WSY_ON_OFF params:param success:^(id responseBody) {
            @strongify(self);
            [self hideHUD];
            if ([responseBody[@"Code"] intValue] == 0 ){
                [self showSuccessHUD:WSY(@"Success ")];
            }else{
                [self showErrorHUD:WSY(@"Fail")];
            }
        } failure:^(NSError *error) {
            [self hideHUD];
        }];
    }];
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:[UIImage imageNamed:@"S_off"] color:kThemeRedColor title:WSY(@"Remote Shutdown") subTitle:WSY(@"Sure to remote shutdown all devices?") closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}

/**
 清理缓存
 */
-(void)cleanCaches:(NSIndexPath *)indexPath{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    [alert addButton:WSY(@"OK") actionBlock:^(void) {
        [self cleanHUD];
        NSString *path = WSYCachesPath;
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            NSArray *childerFiles=[fileManager subpathsAtPath:path];
            for (NSString *fileName in childerFiles) {
                NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
                [fileManager removeItemAtPath:absolutePath error:nil];
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showSuccessHUD:WSY(@"Complete")];
        });
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:self image:[UIImage imageNamed:@"S_clean"] color:kThemeRedColor title:WSY(@"Cache cleaning") subTitle:[NSString stringWithFormat:@"%@%.2fM,%@",WSY(@"The cache size is "), [self getCashes],WSY(@"Sure to clean up cache?")] closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}

-(float)getCashes{
    NSString *path = WSYCachesPath;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    float folderSize = 0.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *fullPath = [path stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:fullPath];
        }
    }
    return folderSize;
}

-(float)fileSizeAtPath:(NSString *)path{
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:path]){
        
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}

/**
 退出
 */
-(void)logout
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    [alert addButton:WSY(@"OK") actionBlock:^(void) {
        [self teamLogout];
    }];
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:self image:[UIImage imageNamed:@"S_logout"] color:kThemeRedColor title:WSY(@"Determine to log out?") subTitle:nil closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}

- (NSInteger)seq {
    return ++ seq;
}

-(void)teamLogout
{
    @weakify(self);
//    [self showStrHUD:WSY(@"Log Out")];
    [self showStrHUD:WSY(@"Log Out")];
    NSDictionary *param = @{@"TouristTeamID": [WSYUserDataTool getUserData:kGuideID]};
    [[WSYNetworkTool sharedManager]post:WSY_TEAM_LOGOUT params:param success:^(id responseBody) {
        @strongify(self);
        [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
            NSLog(@"%ld====%@=====%ld",(long)iResCode,iAlias,(long)seq);
        } seq:[self seq]];
        [WSYUserDataTool removeUserData:kGuideIsLogin];
        [WSYUserDataTool removeUserData:kLogoutLanguage];
        [self dismissViewControllerAnimated:YES completion:nil];
//        [self hideHUDWindow];
        [self hideHUD];
    } failure:^(NSError *error) {
        
    }];
}
/**
 切换语言
 */
-(void)changeLanguage{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//    [alert setHorizontalButtons:YES];
//    [alert setShouldDismissOnTapOutside:YES];
    if ([_currentLanguage isEqualToString:LanguageCode[0]]) {
        [alert addButton:@"中文" actionBlock:^(void) {
            _currentLanguage = LanguageCode[1];
            [WSYLanguageTool userSelectedLanguage:_currentLanguage];
            [[NSNotificationCenter defaultCenter]postNotificationName:kchangeLanguage object:nil];
            [WSYUserDataTool removeUserData:kLanguage];
            [WSYUserDataTool setUserData:_currentLanguage forKey:kLanguage];
            [WSYUserDataTool setUserData:@"changeLanguage" forKey:kLogoutLanguage];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } else {
        [alert addButton:@"English" actionBlock:^(void) {
            _currentLanguage = LanguageCode[0];
            [WSYLanguageTool userSelectedLanguage:_currentLanguage];
            [[NSNotificationCenter defaultCenter]postNotificationName:kchangeLanguage object:nil];
            [WSYUserDataTool removeUserData:kLanguage];
            [WSYUserDataTool setUserData:_currentLanguage forKey:kLanguage];
            [WSYUserDataTool setUserData:@"changeLanguage" forKey:kLogoutLanguage];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:[UIImage imageNamed:@"S_language"] color:kThemeRedColor title:WSY(@" Language ") subTitle:nil closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}

/**
 切换地图
 */
-(void)changeMaps{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    if ([[WSYUserDataTool getUserData:kForeign] isEqualToString:@"Foreign"]) {
        [alert addButton:@"高德地图" actionBlock:^(void) {
            [WSYUserDataTool removeUserData:kForeign];
            [WSYUserDataTool setUserData:@"Maps" forKey:kMaps];
            [WSYUserDataTool setUserData:@"changeLanguage" forKey:kLogoutLanguage];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } else {
        [alert addButton:@"Google Maps" actionBlock:^(void) {
            [WSYUserDataTool setUserData:@"Foreign" forKey:kForeign];
            [WSYUserDataTool setUserData:@"Maps" forKey:kMaps];
            [WSYUserDataTool setUserData:@"changeLanguage" forKey:kLogoutLanguage];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:[UIImage imageNamed:@"S_Maps"] color:kThemeRedColor title:WSY(@"Maps") subTitle:nil closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}


#pragma mark ============Table view data source／delegate============

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == WSYSettingSectionContacts) {
        return 3;
    } else if (section == WSYSettingSectionShutDown) {
        return 2;
    } else if (section == WSYSettingSectionLanguage) {
        return 2;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == WSYSettingSectionAbout) {
        return 20;
    }
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    WSYSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[WSYSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.rippleColor = kThemeRedColor;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.section == WSYSettingSectionContacts) {
        if (indexPath.row == 0) {
            cell.textLabel.text = WSY(@"Emergency Contacts");
            cell.imageView.image = [UIImage imageNamed:@"M_SOS"];
        }else if (indexPath.row == 1) {
            cell.textLabel.text = WSY(@"Work Mode");
            cell.imageView.image = [UIImage imageNamed:@"M_WorkMode"];
        }else {
            cell.textLabel.text = WSY(@"Change Password");
            cell.imageView.image = [UIImage imageNamed:@"M_Modify"];
        }
    } else if (indexPath.section == WSYSettingSectionShutDown) {
        if (indexPath.row == 1) {
            cell.textLabel.text = WSY(@"Clean Cache");
            cell.imageView.image = [UIImage imageNamed:@"M_Clear"];
//            cell.rightLab.text = [NSString stringWithFormat:@"%.2fMB",[self getCashes]];
        }else {
            cell.textLabel.text = WSY(@"Remote Shutdown");
            cell.imageView.image = [UIImage imageNamed:@"M_Off"];
        }
    } else if (indexPath.section == WSYSettingSectionAbout){
        cell.textLabel.text = WSY(@"About");
        cell.imageView.image = [UIImage imageNamed:@"M_About"];
    } else if (indexPath.section == WSYSettingSectionLanguage){
        if (indexPath.row == 0) {
            cell.textLabel.text = WSY(@"Language");
            cell.imageView.image = [UIImage imageNamed:@"M_Language"];
        } else {
            cell.textLabel.text = WSY(@"Maps");
            cell.imageView.image = [UIImage imageNamed:@"M_Maps"];
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = WSY(@"Log Out");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = kThemeRedColor;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == WSYSettingSectionContacts) {
        if (indexPath.row == 0) {
            WSYContactsViewController *contactsVc = [WSYContactsViewController new];
            [self.navigationController pushViewController:contactsVc animated:YES];
        }else if (indexPath.row == 1) {
            WSYWorkModeViewController *workVc = [WSYWorkModeViewController new];
            [self.navigationController pushViewController:workVc animated:YES];
        }else{
            WSYModifyPasswordViewController *pwdView = [WSYModifyPasswordViewController new];
            [self.navigationController pushViewController:pwdView animated:YES];
        }
    }else if (indexPath.section == WSYSettingSectionShutDown) {
        if (indexPath.row == 0) {
            [self powerOff];
        }else{
            if (!([[NSString stringWithFormat:@"%.2f",[self getCashes]] isEqualToString:@"0.00"])) {
                [self cleanCaches:indexPath];
            }
        }
    }else if (indexPath.section == WSYSettingSectionLogout) {
        [self logout];
    }else if (indexPath.section == WSYSettingSectionLanguage) {
        if (indexPath.row == 0) {
            [self changeLanguage];
        } else {
            [self changeMaps];
        }
    }else {
        WSYAboutViewController *aboutVc = [WSYAboutViewController new];
        [self.navigationController pushViewController:aboutVc animated:YES];
    }
}

@end


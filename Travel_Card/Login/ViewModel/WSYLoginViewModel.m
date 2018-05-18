//
//  WSYLoginViewModel.m
//  Travel_Card
//
//  Created by 王世勇 on 2017/2/13.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYLoginViewModel.h"
#import "WSYUserDataTool.h"
#import "JPUSHService.h"

@interface WSYLoginViewModel ()

@property (nonatomic, strong) RACSignal *userNameSignal;
@property (nonatomic, strong) RACSignal *passwordSignal;
@property (nonatomic, strong) RACSignal *loginSignal;

@end

@implementation WSYLoginViewModel

static NSInteger seq = 0;

-(instancetype)init{
    if (self = [super init]) {
        _userNameSignal = RACObserve(self, userName);
        _passwordSignal = RACObserve(self, password);
        _successSubject = [RACSubject subject];
        _failureSubject = [RACSubject subject];
        _errorSubject   = [RACSubject subject];
    }
    return self;
}

- (RACSignal *)validSignal {
    RACSignal *validSignal = [RACSignal combineLatest:@[_userNameSignal, _passwordSignal] reduce:^id(NSString *userName, NSString *password){
        return @(userName.length >= 5 && password.length >= 6);
    }];
    return validSignal;
}

- (void)loginBtn{
    if (self.isGuide == YES) {
        NSLog(@"1=====");
        NSDictionary *param = @{@"UserName":_userName, @"UserPwd":_password};
        [[WSYNetworkTool sharedManager]post:WSY_TEAM_LOGIN params:param success:^(id responseBody){
            NSString *codeStr = [NSString stringWithFormat:@"%@",responseBody[@"Code"]];
            if ([codeStr isEqualToString:@"0"]) {
                [_successSubject sendNext:WSY(@"Success")];
                NSString *ids = [NSString stringWithFormat:@"%@",responseBody[@"Data"][@"ID"]];
                [JPUSHService setAlias:ids completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    NSLog(@"%ld====%@=====%ld",(long)iResCode,iAlias,(long)seq);
                } seq:[self seq]];
//                [WSYUserDataTool removeUserData:kTravelGencyID];
                [WSYUserDataTool setUserData:responseBody[@"Data"][@"TravelGencyID"] forKey:kTravelGencyID];
                [WSYUserDataTool setUserData:responseBody[@"Data"][@"ID"] forKey:kGuideID];
                [WSYUserDataTool saveOwnGuideAccount:_userName andPassword:_password forKey:kGuideTsn];
            } else {
                [_failureSubject sendNext:WSY(@"User name or password error")];
            }
        }failure:^(NSError *error){
            [_errorSubject sendNext:error];
        }];
    } else {
        NSLog(@"2=====");
        NSDictionary *param = @{@"UserName":_userName, @"UserPwd":_password};
        [[WSYNetworkTool sharedManager]post:WSY_MANAGE_LOGIN params:param success:^(id responseBody){
            NSString *codeStr = [NSString stringWithFormat:@"%@",responseBody[@"Code"]];
            if ([codeStr isEqualToString:@"0"]) {
//                [WSYUserDataTool removeUserData:kTravelGencyID];
                [WSYUserDataTool setUserData:responseBody[@"Data"][@"TravelAgecncyID"] forKey:kTravelGencyID];
                [WSYUserDataTool saveOwnManageAccount:_userName andPassword:_password forKey:kManageTsn];
                [_successSubject sendNext:WSY(@"Success")];
            } else {
                [_failureSubject sendNext:WSY(@"User name or password error")];
            }
        }failure:^(NSError *error){
            [_errorSubject sendNext:error];
        }];
    }
    
}

- (NSInteger)seq {
    return ++ seq;
}

@end

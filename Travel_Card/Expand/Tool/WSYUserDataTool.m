//
//  WSYUserDataTool.m
//  Travel_Card
//
//  Created by 王世勇 on 2017/3/1.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYUserDataTool.h"
#import <SAMKeychain/SAMKeychain.h>

@implementation WSYUserDataTool

+ (BOOL)isUserExist{
    NSString *uid = [self getUserData:@"uid"];
    return uid != nil;
}

+ (BOOL)isUserExist:(NSString*)key
{
    NSString *value = [self getUserData:key];
    return value != nil;
}


+ (void)setUserData:(id)value forKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

+ (id)getUserData:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
}

+ (void)removeUserData:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}

+(void)deletePasswordKtsn{
//    [SSKeychain deletePasswordForService:kService account:kTsn];
}

+ (void)saveOwnManageAccount:(NSString *)account andPassword:(NSString *)password forKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account forKey:key];
    [userDefaults synchronize];
    
    [SAMKeychain setPassword:password forService:kManageService account:account];
}

+ (void)saveOwnGuideAccount:(NSString *)account andPassword:(NSString *)password forKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account forKey:key];
    [userDefaults synchronize];
    
    [SAMKeychain setPassword:password forService:kGuideService account:account];
}

+ (NSArray *)getkManageAccountAndPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [userDefaults objectForKey:kManageTsn];
    NSString *password = [SAMKeychain passwordForService:kManageService account:account];
    
    if (account) {return @[account, password];}
    return nil;
}

+ (NSArray *)getkGuideAccountAndPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [userDefaults objectForKey:kGuideTsn];
    NSString *password = [SAMKeychain passwordForService:kGuideService account:account];
    
    if (account) {return @[account, password];}
    return nil;
}

@end

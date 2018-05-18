//
//  WSYUserDataTool.h
//  Travel_Card
//
//  Created by 王世勇 on 2017/3/1.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSYUserDataTool : NSObject

//判断用户是否存在
+ (BOOL)isUserExist;

+ (BOOL)isUserExist:(NSString*)key;

//存储用户信息（持久化）
+ (void)setUserData:(id)value forKey:(NSString*)key;

//获取用户信息
+ (id)getUserData:(NSString*)key;

//删除用户信息
+ (void)removeUserData:(NSString*)key;

+(void)deletePasswordKtsn;

+ (void)saveOwnManageAccount:(NSString *)account andPassword:(NSString *)password forKey:(NSString *)key;

+ (void)saveOwnGuideAccount:(NSString *)account andPassword:(NSString *)password forKey:(NSString *)key;

+ (NSArray *)getkManageAccountAndPassword;

+ (NSArray *)getkGuideAccountAndPassword;

@end

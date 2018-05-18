//
//  WSYLanguageTool.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/6/19.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYLanguageTool.h"

@implementation WSYLanguageTool

static NSBundle *bundle = nil;

NSString *const LanguageCodeIdIndentifier = @"LanguageCodeIdIndentifier";

+ (void)initialize {
    NSString * current = [[NSUserDefaults standardUserDefaults]objectForKey:LanguageCodeIdIndentifier];
    //
    //    if (!([current isEqualToString:@"en"] || [current isEqualToString:@"zh-Hans"])) {
    //        current = @"zh-Hans";
    //    }
    [self setLanguage:current];
}

+ (void)setLanguage:(NSString *)language {
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
    bundle = [NSBundle bundleWithPath:path];
}

+ (NSString *)currentLanguageCode {
    NSString *userSelectedLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageCodeIdIndentifier];
    if (userSelectedLanguage) {
        // Store selected language in local
        
        return userSelectedLanguage;
    }
    
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *systemLanguage = [appLanguages objectAtIndex:0];
    NSLog(@"%@=====",systemLanguage);
    
    if ([systemLanguage hasPrefix:@"zh"]) {
        [WSYUserDataTool setUserData:LanguageCode[1] forKey:kLanguage];
        [WSYLanguageTool userSelectedLanguage:LanguageCode[1]];
    } else {
        [WSYUserDataTool setUserData:LanguageCode[0] forKey:kLanguage];
        [WSYLanguageTool userSelectedLanguage:LanguageCode[0]];
    }
    
    return systemLanguage;
}

+ (void)userSelectedLanguage:(NSString *)selectedLanguage {
    // Store the data
    // Store selected language in local
    
    [[NSUserDefaults standardUserDefaults] setObject:selectedLanguage forKey:LanguageCodeIdIndentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Set global language
    [WSYLanguageTool setLanguage:selectedLanguage];
    
}

+ (NSString *)get:(NSString *)key alter:(NSString *)alternate {
    return [bundle localizedStringForKey:key value:alternate table:nil];
}

@end

//
//  WSYLanguageTool.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/6/19.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

// replace the NSLocalizedString() in run time
#define WSY(key) [WSYLanguageTool get:key alter:nil]
#define LanguageCode @[@"en", @"zh-Hans"]

@interface WSYLanguageTool : NSObject

+ (void)initialize;
+ (void)setLanguage:(NSString *)language;
+ (NSString*)currentLanguageCode;
+ (void)userSelectedLanguage:(NSString *)selectedLanguage;
+ (NSString *)get:(NSString *)key alter:(NSString *)alternate;

@end

//
//  WSYNSDateHelper.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/7/18.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSYNSDateHelper : NSObject

+(NSString*)isOnlineOffline:(NSString*)time;

/** 时间戳转换 */
+(NSString *)transformation:(NSString *)time;

+(NSString*)transformationGMTDate:(NSString*)date;

+(NSString*)serviceTime:(NSString*)time isOnlineOffline:(NSString*)timee;

//将本地日期字符串转为UTC日期字符串
//本地日期格式:2013-08-03 12:53:51
//可自行指定输入输出格式
+(NSString *)getUTCFormateLocalDate:(NSString *)localDatel;

//将UTC日期字符串转为本地时间字符串
//输入的UTC日期格式2013-08-03T04:53:51+0000
+(NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate;

@end

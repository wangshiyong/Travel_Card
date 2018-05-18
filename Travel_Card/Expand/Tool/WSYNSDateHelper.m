//
//  WSYNSDateHelper.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/7/18.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYNSDateHelper.h"

@implementation WSYNSDateHelper

+(NSString*)isOnlineOffline:(NSString*)time{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *old=[date dateFromString:time];
    
    NSTimeInterval late=[old timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    
    NSTimeInterval interval = now-late;
    
    return interval > 120 ? @"离线" : @"在线";
}

+(NSString *)transformation:(NSString *)time{
    CFStringRef str = (__bridge CFStringRef)(time);
    NSString *test = [(__bridge NSString*)str substringWithRange:NSMakeRange(6, 13)];
    long long intString = [test longLongValue];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:intString/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:confromTimesp];
    return currentDateStr;
}

+ (NSString*)transformationGMTDate:(NSString*)date{
    NSDateFormatter *iosDateFormater=[[NSDateFormatter alloc]init];
    iosDateFormater.dateFormat=@"EEE, dd MMM yyyy HH:mm:ss z";
    iosDateFormater.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    NSDate *datee=[iosDateFormater dateFromString:date];
    NSDateFormatter *resultFormatter=[[NSDateFormatter alloc]init];
    [resultFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [resultFormatter stringFromDate:datee];
    return currentDateStr;
}

+(NSString*)serviceTime:(NSString*)time isOnlineOffline:(NSString*)timee{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *old=[date dateFromString:time];
    NSDate *new=[date dateFromString:timee];
    
    NSTimeInterval late=[old timeIntervalSince1970]*1;
    NSTimeInterval now=[new timeIntervalSince1970]*1;
    
    NSTimeInterval interval = late-now;
//    NSLog(@"%f----",interval);
    return interval > 120 ? @"离线" : @"在线";
}

+(NSString *)getUTCFormateLocalDate:(NSString *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:localDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];

    return dateString;
}

+(NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];

    return dateString;
}

@end

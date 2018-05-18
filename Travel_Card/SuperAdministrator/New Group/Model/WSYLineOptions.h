//
//  WSYLineOptions.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/13.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOS-Echarts.h"

@interface WSYLineOptions : NSObject

+ (PYOption *)standardLineOption;
+ (PYOption *)standardLineOptionWithSubtitle:(NSString *)subtitle
                               withTimeArray:(NSArray *)timeArray
                              withTotalArray:(NSArray *)totalArray
                             withOnlineArray:(NSArray *)onlineArray
                            withOfflineArray:(NSArray *)offlineArray
                                withEndEqual:(NSNumber *)value;

@end

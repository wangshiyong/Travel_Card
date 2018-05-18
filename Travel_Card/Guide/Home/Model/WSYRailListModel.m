//
//  WSYRailListModel.m
//  Travel_Card
//
//  Created by 王世勇 on 2017/3/7.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYRailListModel.h"

@implementation WSYRailListModel

+(NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"name" : @"Name",
             @"type" : @"Type",
             @"ids" : @"ID",
             @"enabled" : @"Enabled"
             };
}

@end

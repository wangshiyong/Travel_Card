//
//  WSYAnnotation.m
//  Travel_Card
//
//  Created by 王世勇 on 2017/2/23.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYAnnotation.h"

@implementation WSYAnnotation

@synthesize coordinate = _coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self = [super init])
    {
        self.coordinate = coordinate;
    }
    return self;
}

@end

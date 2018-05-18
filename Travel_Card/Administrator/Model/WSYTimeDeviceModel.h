//
//  WSYTimeDeviceModel.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/12/5.
//  Copyright © 2017年 王世勇. All rights reserved.
//

@interface WSYTimeDeviceModel : NSObject

@property (nonatomic, strong) NSNumber *TotalCount;
@property (nonatomic, strong) NSNumber *OnlineCount;
@property (nonatomic, strong) NSNumber *OfflineCount;
@property (nonatomic, copy) NSString *DateTime;

@end

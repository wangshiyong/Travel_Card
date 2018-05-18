//
//  WSYTravelListModel.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/12/1.
//  Copyright © 2017年 王世勇. All rights reserved.
//

@interface WSYTravelListModel : NSObject

@property (nonatomic, copy) NSString *TravelGencyName;
@property (nonatomic, copy) NSString *UserAccount;
@property (nonatomic, copy) NSString *Address;
@property (nonatomic, copy) NSString *DutyPhone;
@property (nonatomic, copy) NSString *DutyName;
@property (nonatomic, strong) NSNumber *TravelGencyID;
@property (nonatomic, strong) NSNumber *TotalCount;
@property (nonatomic, strong) NSNumber *OnlineCount;
@property (nonatomic, strong) NSNumber *OfflineCount;


@end

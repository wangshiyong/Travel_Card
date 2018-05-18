//
//  WSYLocationListModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2017/3/8.
//  Copyright © 2017年 王世勇. All rights reserved.
//

@interface WSYLocationListModel : NSObject

@property (nonatomic, copy) NSString *MemberName;
@property (nonatomic, copy) NSString *GpsState;
@property (nonatomic, copy) NSString *Tel;
@property (nonatomic, copy) NSString *OnlineTime;
@property (nonatomic, copy) NSString *Geo;
@property (nonatomic, copy) NSString *GpsTime;
@property (nonatomic, strong) NSNumber *Lng;
@property (nonatomic, strong) NSNumber *Lat;
@property (nonatomic, strong) NSNumber *State;
@property (nonatomic, strong) NSNumber *MemberID;
@property (nonatomic, strong) NSNumber *Battery;

@end

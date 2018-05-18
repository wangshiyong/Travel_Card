//
//  WSYTeamListModel.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/12/4.
//  Copyright © 2017年 王世勇. All rights reserved.
//

@interface WSYTeamListModel : NSObject

@property (nonatomic, copy) NSString *TouristTeamName;
@property (nonatomic, copy) NSString *UserAccount;
@property (nonatomic, copy) NSString *UserPwd;
@property (nonatomic, copy) NSString *GuidPhone;
@property (nonatomic, copy) NSString *GuidName;
@property (nonatomic, strong) NSNumber *TotalCount;
@property (nonatomic, strong) NSNumber *OnlineCount;
@property (nonatomic, strong) NSNumber *OfflineCount;

@end

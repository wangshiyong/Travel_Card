//
//  WSYAlarmListModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2017/3/7.
//  Copyright © 2017年 王世勇. All rights reserved.
//

@interface WSYAlarmListModel : NSObject

@property (nonatomic, copy) NSString *CodeMachine;
@property (nonatomic, copy) NSString *Content;
@property (nonatomic, copy) NSString *CreateTime;
@property (nonatomic, strong) NSNumber *Type;
@property (nonatomic, strong) NSNumber *MemberID;


@end

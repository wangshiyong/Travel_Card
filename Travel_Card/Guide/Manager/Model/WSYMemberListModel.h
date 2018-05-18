//
//  AourMemberListModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2017/3/7.
//  Copyright © 2017年 王世勇. All rights reserved.
//

@interface WSYMemberListModel : NSObject

@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *CodeMachine;
@property (nonatomic, copy) NSString *Sex;
@property (nonatomic, copy) NSString *Phone;
@property (nonatomic, copy) NSString *OnlineTime;
@property (nonatomic, strong) NSNumber *IsOnline;
@property (nonatomic, strong) NSNumber *MemberID;
@property (nonatomic, strong) NSNumber *TerminalID;

@end

//
//  WSYAPI.h
//  Travel_Card
//
//  Created by 王世勇 on 2017/2/15.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#ifndef WSYAPI_h
#define WSYAPI_h

#define kHTTPMethodPost @"POST"

#define WSY_SERVICE  @"http://appdy.zhihuiquanyu.com/WebAppService.asmx"
//#define WSY_SERVICE  @"http://192.168.1.49:8014/WebAppService.asmx"

//============导游端============
//导游登录
#define WSY_TEAM_LOGIN [NSString stringWithFormat:@"%@/TouristTeamLogin", WSY_SERVICE]
//获取行程列表
#define WSY_GET_TRIP [NSString stringWithFormat:@"%@/GetTripToTimeSpan", WSY_SERVICE]
//获取游客列表
#define WSY_GET_TOURIST [NSString stringWithFormat:@"%@/GetAllTourist", WSY_SERVICE]
//获取围栏列表
#define WSY_GET_FENCE [NSString stringWithFormat:@"%@/GetTouristTeamElectronicFence", WSY_SERVICE]
//获取围栏列表
#define WSY_GET_FENCE_COORDINATE [NSString stringWithFormat:@"%@/GetElectronicFenceCoordinate", WSY_SERVICE]
//获取报警列表
#define WSY_GET_ALARM [NSString stringWithFormat:@"%@/GetTouristTeamAlarm", WSY_SERVICE]
//获取紧急联系人姓名和电话
#define WSY_GET_SOS_NAME [NSString stringWithFormat:@"%@/GetTouristTeamSOSName", WSY_SERVICE]
//设置紧急联系人姓名
#define WSY_SET_SOS_NAME [NSString stringWithFormat:@"%@/SetTouristTeamSOSName", WSY_SERVICE]
//设置紧急联系人电话
#define WSY_SET_SOS_PHONE [NSString stringWithFormat:@"%@/SetTouristTeamSOSPhone", WSY_SERVICE]
//设置工作模式
#define WSY_SET_WORK_MODEL [NSString stringWithFormat:@"%@/SetTouristTeamWorkModel", WSY_SERVICE]
//修改导游登录密码
#define WSY_UPDATE_PASSWORD [NSString stringWithFormat:@"%@/UpdateTouristTeamAccount", WSY_SERVICE]
//发布行程信息
#define WSY_CREATE_TRIP [NSString stringWithFormat:@"%@/CreateTouristTeamTrip", WSY_SERVICE]
//删除单条行程信息
#define WSY_DELETE_TRIP [NSString stringWithFormat:@"%@/DeleteTrip", WSY_SERVICE]
//清空行程信息
#define WSY_DELETE_TEAM_TRIP [NSString stringWithFormat:@"%@/ClearTouristTeamAllTrip", WSY_SERVICE]
//删除所有游客
#define WSY_DELETE_ALL_TOURIST [NSString stringWithFormat:@"%@/DeleteAllTourist", WSY_SERVICE]
//删除单个游客
#define WSY_DELETE_TOURIST [NSString stringWithFormat:@"%@/DeleteOneTourist", WSY_SERVICE]
//添加游客
#define WSY_ADD_TOURIST [NSString stringWithFormat:@"%@/AddTourist", WSY_SERVICE]
//设备关机
#define WSY_ON_OFF [NSString stringWithFormat:@"%@/SetTerminalONAndOFF", WSY_SERVICE]
//获取设备详细信息
#define WSY_GET_INFO [NSString stringWithFormat:@"%@/GetTouristDetails", WSY_SERVICE]
//设置电子围栏开启和关闭
#define WSY_SET_FENCE_STATE [NSString stringWithFormat:@"%@/SetElectronicFenceState", WSY_SERVICE]
//获取单个定位信息
#define WSY_GET_LOCATION [NSString stringWithFormat:@"%@/GetMenberLocation", WSY_SERVICE]
//获取历史轨迹
#define WSY_GET_TRACE [NSString stringWithFormat:@"%@/GetMemberHistoryTrace", WSY_SERVICE]
//获取工作模式
#define WSY_GET_WORK_MODE [NSString stringWithFormat:@"%@/GetTouristTeamWorkMode", WSY_SERVICE]
//获取全团定位
#define WSY_GET_TEAM_LOCATION [NSString stringWithFormat:@"%@/GetTouristTeamLocation", WSY_SERVICE]
//设置自定义模式时间间隔
#define WSY_SET_CUSTOM_TIME [NSString stringWithFormat:@"%@/SetTouristTeamCustomModel", WSY_SERVICE]
//获取自定义模式时间间隔
#define WSY_GET_CUSTOM_TIME [NSString stringWithFormat:@"%@/GetTouristTeamCustomModelTime", WSY_SERVICE]
//设置全团手动定位
#define WSY_GET_TEAM_HAND [NSString stringWithFormat:@"%@/GetTouristTeamHandLocation", WSY_SERVICE]
//设置单个手动定位
#define WSY_GET_HAND_LOCATION [NSString stringWithFormat:@"%@/GetOneHandLocation", WSY_SERVICE]
//单个行程发布
#define WSY_TRIP_MEMBER [NSString stringWithFormat:@"%@/CreatTripToMember", WSY_SERVICE]
//退出登录
#define WSY_TEAM_LOGOUT [NSString stringWithFormat:@"%@/TouristTeamLogout", WSY_SERVICE]

//============管理端============
//管理登录
#define WSY_MANAGE_LOGIN [NSString stringWithFormat:@"%@/TravelAgecncyLogin", WSY_SERVICE]
//获取导游列表
#define WSY_GUIDE_LIST [NSString stringWithFormat:@"%@/GetAllGuidList", WSY_SERVICE]
//获取旅行社列表
#define WSY_TRAVEL_LIST [NSString stringWithFormat:@"%@/GetAllTravelAgencyDetail", WSY_SERVICE]
//获取总账号全部旅行社使用次数
#define WSY_GET_ACCOUNT_LIST [NSString stringWithFormat:@"%@/GetAgencyDeviceUseAccountList", WSY_SERVICE]
//获取总账号设备总使用次数
#define WSY_TRAVEL_USE_ACCOUNT [NSString stringWithFormat:@"%@/GetAllTravelAgencyDeviceUseAccount", WSY_SERVICE]
//获取旅游团列表
#define WSY_TOURIST_LIST [NSString stringWithFormat:@"%@/GetTouristTeamList", WSY_SERVICE]
//总账号获取时间段设备使用状况
#define WSY_TRAVEL_TIME_SPAN [NSString stringWithFormat:@"%@/GetAllTravelAgencyDeviceTimeSpan", WSY_SERVICE]
//旅行社获取全部设备使用状态
#define WSY_TRAVEL_AGENCY_COUNT [NSString stringWithFormat:@"%@/GetTravelAgencyUseCount", WSY_SERVICE]
//旅行社获取时间段设备使用状况
#define WSY_GET_TEAM_ACCOUNT [NSString stringWithFormat:@"%@/GetTravelAgencyAllDevice", WSY_SERVICE]


#endif /* WSYAPI_h */

//
//  WSYNetworkTool.m
//  Travel_Card
//
//  Created by 王世勇 on 2017/2/15.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYNetworkTool.h"
#import "MBProgressHUD.h"
#import "UIImage+Tint.h"
#import "WSYNSDateHelper.h"
#import "XMLDictionary.h"

@implementation WSYNetworkTool

static id _instance = nil;
static AFHTTPSessionManager *manager;
static AFHTTPSessionManager *managerr;

+ (instancetype)sharedManager {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}


- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
        /*枚举里面四个状态  分别对应 未知 无网络 数据 WiFi
         typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
         AFNetworkReachabilityStatusUnknown          = -1,      未知
         AFNetworkReachabilityStatusNotReachable     = 0,       无网络
         AFNetworkReachabilityStatusReachableViaWWAN = 1,       蜂窝数据网络
         AFNetworkReachabilityStatusReachableViaWiFi = 2,       WiFi
         };
         */
        [manager startMonitoring];
        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                {
                    // 位置网络
                    NSLog(@"位置网络");
                }
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                {
                    // 无法联网
                    NSLog(@"无法联网");
                }
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                {
                    // 手机自带网络
                    NSLog(@"当前在WIFI网络下");
                }
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                {
                    // WIFI
                    NSLog(@"当前使用的是2G/3G/4G网络");
                }
            }
        }];
    });
    return _instance;
}

-(AFHTTPSessionManager *)baseHttpRequest{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setTimeoutInterval:TIMEOUT];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain", @"text/html",  @"text/xml" ,nil];
    });
    return manager;
}

-(AFHTTPSessionManager *)baseHttpRequestt{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        managerr = [AFHTTPSessionManager manager];
        [managerr.requestSerializer setTimeoutInterval:TIMEOUT];
        managerr.requestSerializer = [AFJSONRequestSerializer serializer];
        managerr.responseSerializer = [AFJSONResponseSerializer serializer];
        managerr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain", @"text/html",  @"text/xml",@"text/javascript",nil];
    });
    return managerr;
}

- (void)post:(NSString *)url params:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure{
    AFHTTPSessionManager *manager = [self baseHttpRequest];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask *_Nonnull task,id _Nonnull responseObject){
        if(success){
            NSDictionary *dict = [NSDictionary dictionaryWithXMLParser:responseObject];
            NSDictionary *dictt = [self dictionaryWithJsonString:dict[@"__text"]];
            NSLog(@"%@%@\n%@",url,params,dictt);
            success(dictt);
        }
    }failure:^(NSURLSessionDataTask *_Nonnull task,NSError *_Nonnull error){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        
        // Set the custom view mode to show any view.
        hud.mode = MBProgressHUDModeCustomView;
        // Set an image view with a checkmark.
        UIImage *image = [[UIImage imageNamed:@"N_error"] imageWithTintColor:[UIColor whiteColor]];
        hud.customView = [[UIImageView alloc] initWithImage:image];
        // Looks a bit nicer if we make it square.
        hud.square = YES;
        // Optional label text.
        if (failure) {
            if (error.code == -1009) {
                hud.labelText = @"网络未连接";
            }else{
                NSLog(@"%ld===",(long)error.code);
                hud.labelText = @"网络异常";
            }
            [hud hide:YES afterDelay:2.f];
            failure(error);
        }
    }];
}

- (void)post:(NSString *)url params:(NSDictionary *)params successs:(SuccessBlock)success failure:(FailureBlock)failure{
    AFHTTPSessionManager *manager = [self baseHttpRequestt];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask *_Nonnull task,id _Nonnull responseObject){
        if(success){
//            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
//            NSDictionary *allHeaders = response.allHeaderFields;
//
//            NSString *time = [WSYNSDateHelper transformationGMTDate:allHeaders[@"Date"]];
//            NSLog(@"%@",allHeaders);
//            NSLog(@"%@%@\n%@",url,params,responseObject[@"d"]);
//            success(responseObject,time);
            success(responseObject);
        }
    }failure:^(NSURLSessionDataTask *_Nonnull task,NSError *_Nonnull error){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        
        // Set the custom view mode to show any view.
        hud.mode = MBProgressHUDModeCustomView;
        // Set an image view with a checkmark.
        UIImage *image = [[UIImage imageNamed:@"error"] imageWithTintColor:[UIColor whiteColor]];
        hud.customView = [[UIImageView alloc] initWithImage:image];
        // Looks a bit nicer if we make it square.
        hud.square = YES;
        // Optional label text.
        if (failure) {
            if (error.code == -1009) {
                hud.labelText = @"网络未连接";
            }else{
                hud.labelText = @"网络异常";
            }
            [hud hide:YES afterDelay:2.f];
            failure(error);
        }
        
    }];
}

- (void)get:(NSString *)url params:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure{
    AFHTTPSessionManager *manager = [self baseHttpRequestt];
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask *_Nonnull task,id _Nonnull responseObject){
        if(success){
            //            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            //            NSDictionary *allHeaders = response.allHeaderFields;
            //
            //            NSString *time = [WSYNSDateHelper transformationGMTDate:allHeaders[@"Date"]];
            //            NSLog(@"%@",allHeaders);
            //            NSLog(@"%@%@\n%@",url,params,responseObject[@"d"]);
            //            success(responseObject,time);
            success(responseObject);
        }
    }failure:^(NSURLSessionDataTask *_Nonnull task,NSError *_Nonnull error){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        
        // Set the custom view mode to show any view.
        hud.mode = MBProgressHUDModeCustomView;
        // Set an image view with a checkmark.
        UIImage *image = [[UIImage imageNamed:@"error"] imageWithTintColor:[UIColor whiteColor]];
        hud.customView = [[UIImageView alloc] initWithImage:image];
        // Looks a bit nicer if we make it square.
        hud.square = YES;
        // Optional label text.
        if (failure) {
            if (error.code == -1009) {
                hud.labelText = @"网络未连接";
            }else{
                hud.labelText = @"网络异常";
            }
            [hud hide:YES afterDelay:2.f];
            failure(error);
        }
        
    }];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
    
}


@end

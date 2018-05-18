//
//  WSYNetworkTool.h
//  Travel_Card
//
//  Created by 王世勇 on 2017/2/15.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define TIMEOUT 40

typedef void(^SuccessBlockk)(id response,NSString *headTime);
typedef void(^SuccessBlock)(id response);
typedef void(^FailureBlock)(NSError *error);

@interface WSYNetworkTool : NSObject

+(WSYNetworkTool *)sharedManager;
-(AFHTTPSessionManager *)baseHttpRequest;
-(AFHTTPSessionManager *)baseHttpRequestt;

- (void)post:(NSString *)url params:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure;
- (void)get:(NSString *)url params:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure;
- (void)post:(NSString *)url params:(NSDictionary *)params successs:(SuccessBlock)success failure:(FailureBlock)failure;


@end

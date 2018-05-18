//
//  WSYLoginViewModel.h
//  Travel_Card
//
//  Created by 王世勇 on 2017/2/13.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSYLoginViewModel : NSObject

@property (nonatomic, strong) NSString   *userName;
@property (nonatomic, strong) NSString   *password;

@property (nonatomic, assign) BOOL       isGuide;

@property (nonatomic, strong) RACSubject *successSubject;
@property (nonatomic, strong) RACSubject *failureSubject;
@property (nonatomic, strong) RACSubject *errorSubject;

/**
 *  按钮是否可点信息
 */
- (RACSignal *)validSignal;

- (void)loginBtn;

@end

//
//  WSYSuperHeadView.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/13.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYText.h"

@protocol WSYButtonDelegete <NSObject>

@optional

- (void)startBtnBeTouched:(id)sender;
- (void)endBtnBeTouched:(id)sender;

@end

@interface WSYSuperHeadView : UIView


@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UIButton *endBtn;
@property (nonatomic, strong) YYLabel *useNumLab;
@property (nonatomic, strong) UILabel *startLab;
@property (nonatomic, strong) UILabel *endLab;
@property (nonatomic, weak) id <WSYButtonDelegete> delegate;

@end

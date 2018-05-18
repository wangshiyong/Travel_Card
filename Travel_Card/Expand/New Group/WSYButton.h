//
//  WSYButton.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/24.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WSYButtonType) {
    PositionedButtonTypeTitleRight,
    PositionedButtonTypeTitleLeft,
    PositionedButtonTypeTitleTop,
    PositionedButtonTypeTitleBottom,
};

@interface WSYButton : UIButton

///titleLabel和imageView摆放位置
@property (nonatomic, assign) WSYButtonType buttonPosition;

///titleLabel和imageView的间距
@property (nonatomic, assign) CGFloat imageTitleSpacing;

@end

//
//  WSYtextView.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/9.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSYtextView : UITextView

/** 占位文字 */
@property(nonatomic, copy) NSString *placeholder;
/** 占位文字颜色 */
@property(nonatomic, strong) UIColor *placeholderColor;

@end

//
//  WSYTextField.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/26.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^WSYTapAcitonBlock)(void);
typedef void(^WSYEndEditBlock)(NSString *text);

@interface WSYTextField : UITextField
/** textField 的点击回调 */
@property (nonatomic, copy) WSYTapAcitonBlock tapAcitonBlock;
/** textField 结束编辑的回调 */
@property (nonatomic, copy) WSYEndEditBlock endEditBlock;

@end

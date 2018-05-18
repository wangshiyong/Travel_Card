//
//  WSYAboutFootView.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/29.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSYButtonDelegete <NSObject>

@optional

- (void)webClicked:(id)sender;

@end

@interface WSYAboutFootView : UIView

@property (nonatomic, strong) UILabel *companyLab;
@property (nonatomic, strong) UIButton *webBtn;
@property (nonatomic, weak) id <WSYButtonDelegete> delegate;

@end

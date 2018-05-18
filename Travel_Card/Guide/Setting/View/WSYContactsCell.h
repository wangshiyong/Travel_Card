//
//  WSYContactsCell.h
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/29.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSYContactsCell : UITableViewCell 

@property (nonatomic, strong) UIView *contactsView;
@property (nonatomic, strong) UIView *nameLine;
@property (nonatomic, strong) UIView *phoneLine;
@property (nonatomic, strong) UITextField *name;
@property (nonatomic, strong) UITextField *phone;
@property (nonatomic, strong) UIImageView *image;

@end

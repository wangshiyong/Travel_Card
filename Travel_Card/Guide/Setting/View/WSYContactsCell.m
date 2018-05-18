//
//  WSYContactsCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/29.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYContactsCell.h"
#import "UIImage+Tint.h"
#import "BaseTextField.h"

@implementation WSYContactsCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        self.contactsView = [[UIView alloc]init];
        self.contactsView.backgroundColor = [UIColor whiteColor];
        
        self.name                    = [[UITextField alloc]init];
        self.name.placeholder        = WSY(@"Name");
        self.name.textColor          = kThemeTextColor;
        self.name.clearButtonMode    = UITextFieldViewModeWhileEditing;
        
        self.phone                   = [[BaseTextField alloc]init];
        self.phone.placeholder       = WSY(@"Phone Number");
        self.phone.textColor         = kThemeTextColor;
        self.phone.keyboardType      = UIKeyboardTypeNumberPad;
        self.phone.clearButtonMode   = UITextFieldViewModeWhileEditing;
        
        self.image                   = [[UIImageView alloc]init];
        self.image.image             = [UIImage imageNamed:@"M_Contact"];
        
        self.nameLine                = [[UIView alloc]init];
        self.nameLine.backgroundColor = Color(225, 225, 225, 1);
        
        self.phoneLine               = [[UIView alloc]init];
        self.phoneLine.backgroundColor = Color(225, 225, 225, 1);
        
        [self.contentView addSubview:self.contactsView];
        [self.contentView addSubview:self.image];
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.phone];
        [self.contentView addSubview:self.nameLine];
        [self.contentView addSubview:self.phoneLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    @weakify(self);
    [self.contactsView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        if (IS_IPHONE_5) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 0, 0, 0));
        } else {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(20, 0, 0, 0));
        }
    }];
    
    [self.image mas_makeConstraints:^(MASConstraintMaker *make){
        @strongify(self);
        make.centerY.equalTo(self.contactsView);
        make.left.equalTo(self.contactsView).offset(20);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contactsView).offset(50);
        make.top.equalTo(self.contactsView.mas_top).offset(8);
        make.right.equalTo(self).offset(-25);
        make.height.mas_equalTo(30);
    }];
    
    [self.nameLine mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contactsView).offset(50);
        make.top.equalTo(self.name.mas_bottom);
        make.right.equalTo(self).offset(-25);
        make.height.mas_equalTo(1);
    }];

    [self.phone mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contactsView).offset(50);
        make.top.equalTo(self.name.mas_bottom).offset(10);
        make.right.equalTo(self).offset(-25);
        make.height.mas_equalTo(30);
    }];
    
    [self.phoneLine mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contactsView).offset(50);
        make.top.equalTo(self.phone.mas_bottom);
        make.right.equalTo(self).offset(-25);
        make.height.mas_equalTo(1);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//#pragma mark - MDTextFieldDelegate
//-(void)textFieldDidChange:(MDTextField *)textField{
//    if (textField.text.length > 11){
//        textField.text = [NSString stringWithFormat:@"%@",[textField.text substringToIndex:11]];
//    }
//}
//
//- (BOOL)textFieldShouldReturn:(MDTextField *)textField {
//    [textField resignFirstResponder];
//    return YES;
//}



@end

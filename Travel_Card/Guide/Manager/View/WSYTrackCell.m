//
//  WSYTrackCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/11.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYTrackCell.h"

@interface WSYTrackCell ()

@property(nonatomic, strong) UIImageView *startImage;
@property (nonatomic, strong) UIImageView *endImage;
@property (nonatomic, strong) UIImageView *forwardImage;
@property (nonatomic, strong) UIView *timeView;

@end

@implementation WSYTrackCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        self.timeView = [[UIView alloc]init];
        self.timeView.backgroundColor = [UIColor whiteColor];
        
        self.startImage = [[UIImageView alloc]init];
        self.startImage.image = [UIImage imageNamed:@"M_Start"];
        
        self.endImage = [[UIImageView alloc]init];
        self.endImage.image = [UIImage imageNamed:@"M_End"];
        
        self.forwardImage = [[UIImageView alloc]init];
        self.forwardImage.image = [UIImage imageNamed:@"M_Forward"];
        
        self.startLab = [[UILabel alloc]init];
        self.startLab.font = [UIFont systemFontOfSize:15.0];
        self.startLab.textColor = kThemeTextColor;
        
        self.endLab = [[UILabel alloc]init];
        self.endLab.font = [UIFont systemFontOfSize:15.0];
        self.endLab.textColor = kThemeTextColor;
        
        [self.contentView addSubview:self.timeView];
        [self.timeView addSubview:self.startImage];
        [self.timeView addSubview:self.startLab];
        [self.timeView addSubview:self.endImage];
        [self.timeView addSubview:self.endLab];
        [self.timeView addSubview:self.forwardImage];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 0, 0, 0));
    }];
    
    [self.startImage mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.timeView).offset(20);
        make.top.equalTo(self.timeView).offset(8);
        make.width.height.mas_equalTo(24);
    }];
    
    [self.forwardImage mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(self.timeView);
        make.width.height.mas_equalTo(14);
        make.right.equalTo(self.timeView).offset(-10);
    }];
    
    [self.startLab mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.startImage.mas_right).offset(10);
        make.top.equalTo(self.timeView).offset(5);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(30);
    }];
    
    [self.endImage mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.timeView).offset(20);
        make.top.equalTo(self.startImage.mas_bottom).offset(6);
        make.width.height.mas_equalTo(24);
    }];
    
    [self.endLab mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.startImage.mas_right).offset(10);
        make.top.equalTo(self.startLab.mas_bottom).offset(0);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(30);
    }];
    
}

@end

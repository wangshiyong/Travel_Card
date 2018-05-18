//
//  WSYGuideCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/19.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYGuideCell.h"
#import "MDRippleLayer.h"
#import "WSYGuideListModel.h"

@interface WSYGuideCell()<MDButtonDelegate>

@property MDRippleLayer *mdLayer;

@end

@implementation WSYGuideCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initLayer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initLayer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initLayer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initLayer];
    }
    return self;
}

- (void)initLayer {
    if (!_rippleColor)
        _rippleColor = kThemeRedColor;
    
    _mdLayer = [[MDRippleLayer alloc] initWithSuperLayer:self.layer];
    _mdLayer.effectColor = _rippleColor;
    _mdLayer.rippleScaleRatio = 1;
    _mdLayer.enableElevation = false;
    _mdLayer.effectSpeed = 300;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setRippleColor:(UIColor *)rippleColor {
    _rippleColor = rippleColor;
    [_mdLayer setEffectColor:rippleColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [touches.allObjects[0] locationInView:self];
    [_mdLayer startEffectsAtLocation:point];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [_mdLayer stopEffectsImmediately];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [_mdLayer stopEffects];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [_mdLayer stopEffects];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLab           = [[UILabel alloc]init];
        self.titleLab.textColor = [UIColor blackColor];
        self.titleLab.font      = [UIFont systemFontOfSize:17.0];
        
        self.userName           = [[UILabel alloc]init];
        self.userName.font      = [UIFont systemFontOfSize:14.0];
        self.userName.textColor = Color(104, 104, 104, 1.0);
        
        self.pwd           = [[UILabel alloc]init];
        self.pwd.font      = [UIFont systemFontOfSize:14.0];
        self.pwd.textColor = Color(104, 104, 104, 1.0);
        
        self.team           = [[UILabel alloc]init];
        self.team.font      = [UIFont systemFontOfSize:14.0];
        self.team.textColor = Color(104, 104, 104, 1.0);
        
        self.call = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.call setImage:[UIImage imageNamed:@"T_Call"] forState:UIControlStateNormal];

        
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.userName];
        [self.contentView addSubview:self.pwd];
        [self.contentView addSubview:self.team];
        [self.contentView addSubview:self.call];
        [self initLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    @weakify(self);
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.top.equalTo(self).offset(10);
        make.height.mas_equalTo(21);
    }];

    [self.userName mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self.titleLab.mas_bottom).offset(5);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(21);
    }];

    [self.pwd mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self.userName.mas_bottom).offset(5);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(21);
    }];
    
    [self.team mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView).offset(20);
        make.top.equalTo(self.pwd.mas_bottom).offset(5);
        make.right.equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(21);
    }];
    
    [self.call mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-20);
        make.size.mas_equalTo(40);
    }];
}

-(void)setModel:(WSYGuideListModel *)model{
    _model = model;
    _titleLab.text = [NSString stringWithFormat:@"%@: %@",model.Name,model.Phone];
    _userName.text = [NSString stringWithFormat:@"%@: %@",WSY(@"Account"),model.UserName];
    _pwd.text = [NSString stringWithFormat:@"%@: %@",WSY(@"Password"),model.UserPwd];
//    _team.text = model.touristTeamID;
    
}

@end

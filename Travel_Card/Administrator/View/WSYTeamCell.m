//
//  WSYTeamCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/17.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYTeamCell.h"
#import "MDRippleLayer.h"
#import "WSYTeamListModel.h"

@interface WSYTeamCell()<MDButtonDelegate>

@property MDRippleLayer *mdLayer;

@end

@implementation WSYTeamCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initLayer];
    self.totalLab.layer.cornerRadius = 5;
    self.totalLab.clipsToBounds = YES;
    self.onlineLab.layer.cornerRadius = 5;
    self.onlineLab.clipsToBounds = YES;
    self.offLineLab.layer.cornerRadius = 5;
    self.offLineLab.clipsToBounds = YES;
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

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
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

-(void)setModel:(WSYTeamListModel *)model{
    _model = model;
    _titleLab.text = model.TouristTeamName;
    _nameLab.text = [NSString stringWithFormat:@"%@: %@",model.GuidName,model.GuidPhone];
    _userName.text = [NSString stringWithFormat:@"%@: %@",WSY(@"Account"),model.UserAccount];
    _pwd.text = [NSString stringWithFormat:@"%@: %@",WSY(@"Password"),model.UserPwd];
    _onlineLab.text = [NSString stringWithFormat:@"%@%@",WSY(@"Online"),[self positiveNumber:[model.OnlineCount stringValue]]];
    _offLineLab.text = [NSString stringWithFormat:@"%@%@",WSY(@"Offline"),[self positiveNumber:[model.OfflineCount stringValue]]];
    _totalLab.text = [NSString stringWithFormat:@"%@%@",WSY(@"Total"),[self positiveNumber:[model.TotalCount stringValue]]];
}

- (NSString *)positiveNumber:(NSString *)str {
    if ([str hasPrefix:@"-"]) {
        str = [str substringFromIndex:1];
    }
    return str;
}

@end

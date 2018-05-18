//
//  WSYManagerCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/10.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYManagerCell.h"
#import "MDRippleLayer.h"
#import "WSYMemberListModel.h"

@interface WSYManagerCell()<MDButtonDelegate>

@property MDRippleLayer *mdLayer;

@end

@implementation WSYManagerCell

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

-(void)setModel:(WSYMemberListModel *)model{
    _model = model;
    [_tsn setTitle:model.CodeMachine forState:UIControlStateNormal];
    if ([self isNilOrEmpty:model.OnlineTime]) {
        _time.text = WSY(@"No online time");
    } else {
        _time.text = [WSYNSDateHelper getLocalDateFormateUTCDate:model.OnlineTime];
    }
    if ([model.IsOnline intValue] == 0) {
        _image.image = [UIImage imageNamed:@"M_Offline"];
    } else {
        _image.image = [UIImage imageNamed:@"M_Online"];
    }
    [_track setTitle:WSY(@"Travel path") forState:UIControlStateNormal];
}

- (BOOL)isNilOrEmpty:(NSString*)value {
    if(value != nil && ![value isKindOfClass:[NSNull class]])
    {
        return value.length == 0;
    }
    return YES;
}

@end

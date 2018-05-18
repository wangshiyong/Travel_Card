//
//  WSYItineraryCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/9.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYItineraryCell.h"
#import "MDRippleLayer.h"
#import "WSYItineraryModel.h"

@interface WSYItineraryCell()<MDButtonDelegate>

@property MDRippleLayer *mdLayer;

@end

@implementation WSYItineraryCell

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

-(void)setModel:(WSYItineraryModel *)model{
    _model = model;
    _contentLab.text = model.Content;
    if ([model.Subject isEqualToString:@"Itinerary"] || [model.Subject isEqualToString:@"团行程"]) {
        _titleLab.text = WSY(@"Itinerary");
    } else {
        _titleLab.text = model.Subject;
    }

    _timeLab.text = [WSYNSDateHelper getLocalDateFormateUTCDate:model.CreateTime];
//    _timeLab.text = [[model.addTime stringByReplacingOccurrencesOfString:@"T" withString:@" "]substringToIndex:19];

    if (![self isNilOrEmpty:_contentLab.text]) {
        NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:_contentLab.text];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        
        //    style.headIndent = 0;//缩进
        //    style.firstLineHeadIndent = 13;//首行缩进
        style.lineSpacing = 5;//行距
        [attributeText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributeText.length)];
        _contentLab.attributedText = attributeText;
    }
    
}

- (BOOL)isNilOrEmpty:(NSString*)value {
    if(value != nil && ![value isKindOfClass:[NSNull class]])
    {
        return value.length == 0;
    }
    return YES;
}

//-(NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate
//{
//    NSLog(@"%@====",utcDate);
//    NSString *date = @"2013-08-03T04:53:51+0000";
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //输入格式
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
//    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
//    [dateFormatter setTimeZone:localTimeZone];
//
//    NSDate *dateFormatted = [dateFormatter dateFromString:date];
//    //输出格式
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
//    NSLog(@"%@====",dateString);
//    return dateString;
//}

@end

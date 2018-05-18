//
//  WSYUseListCell.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/12/4.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYUseListCell.h"
#import "WSYUseListModel.h"

@implementation WSYUseListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _currentLanguage = [[WSYLanguageTool currentLanguageCode] mutableCopy];
}

//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        
//        self.rightLab = [[YYLabel alloc]init];
//        self.rightLab.font = [UIFont systemFontOfSize:15.0];
//        self.rightLab.textColor = [UIColor orangeColor];
//        self.rightLab.textAlignment = NSTextAlignmentRight;
//        
//        self.leftLab = [[UILabel alloc]init];
//        self.leftLab.font = [UIFont systemFontOfSize:15.0];
////        self.leftLab.textColor = [UIColor lightGrayColor];
//        self.leftLab.textAlignment = NSTextAlignmentLeft;
//        
//        [self.contentView addSubview:self.rightLab];
//        [self.contentView addSubview:self.leftLab];
//    }
//    return self;
//}
//
//-(void)layoutSubviews{
//    [super layoutSubviews];
//    
//    [self.rightLab mas_makeConstraints:^(MASConstraintMaker *make){
//        make.right.equalTo(self.contentView).offset(-20);
//        make.width.mas_equalTo(100);
//        make.height.mas_equalTo(30);
//        make.centerY.equalTo(self.contentView);
//    }];
//    
//    [self.leftLab mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.equalTo(self.contentView).offset(20);
//        make.width.mas_equalTo(kScreenWidth - 120);
//        make.height.mas_equalTo(30);
//        make.centerY.equalTo(self.contentView);
//    }];
//}

-(void)setModel:(WSYUseListModel *)model{
    _model = model;
    _leftLab.text = model.TravelAgencyName;
    
    NSString *str = [NSString stringWithFormat:@"%@%@",model.TotalCount,WSY(@"times")];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    text.yy_font = [UIFont systemFontOfSize:15.0f];
    text.yy_color = [UIColor lightGrayColor];
    if ([_currentLanguage isEqualToString:LanguageCode[0]]) {
        [text yy_setColor:kThemeOrangeColor range:NSMakeRange(0, (str.length - 5))];
        [text yy_setFont:[UIFont systemFontOfSize:18.0f] range:NSMakeRange(0, (str.length - 5))];
    } else {
        [text yy_setColor:kThemeOrangeColor range:NSMakeRange(0, (str.length - 1))];
        [text yy_setFont:[UIFont systemFontOfSize:18.0f] range:NSMakeRange(0, (str.length - 1))];
    }
    
    _rightLab.attributedText = text;
}

@end

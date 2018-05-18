//
//  UIImage+Tint.h
//  WSYTravelCard
//
//  Created by wang王世勇 on 2016/10/14.
//  Copyright © 2016年 王世勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WSYTint)

@property (nonatomic, strong) UIImage *imageForWhite;
@property (nonatomic, strong) UIImage *imageForDismissTheme;
@property (nonatomic, strong) UIImage *imageForRedTheme;

- (UIImage *)imageWithTintColor:(UIColor *)tintColor;

- (CGSize)fitWidth:(CGFloat)fitWidth;

@end

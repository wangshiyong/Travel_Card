//
//  UIImage+Tint.m
//  WSYTravelCard
//
//  Created by wang王世勇 on 2016/10/14.
//  Copyright © 2016年 王世勇. All rights reserved.
//

#import "UIImage+Tint.h"

@implementation UIImage (WSYTint)

@dynamic imageForWhite;
@dynamic imageForDismissTheme;
@dynamic imageForRedTheme;

- (UIImage *)imageForWhite {
    UIImage *image = self;
    image = [image imageWithTintColor:[UIColor whiteColor]];
    return image;
}

- (UIImage *)imageForDismissTheme {
    UIImage *image = self;
    image = [image imageWithTintColor:[UIColor grayColor]];
    return image;
}

- (UIImage *)imageForRedTheme {
    UIImage *image = self;
    image = [image imageWithTintColor:kThemeRedColor];
    return image;
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor;
{
    if (tintColor) {
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, self.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
        CGContextClipToMask(context, rect, self.CGImage);
        [tintColor setFill];
        CGContextFillRect(context, rect);
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
        
    }
    
    return self;
    
}

- (CGSize)fitWidth:(CGFloat)fitWidth {
    
    CGFloat height = self.size.height;
    CGFloat width = self.size.width;
    
    if (width > fitWidth) {
        height *= fitWidth/width;
        width = fitWidth;
    }
    
    return CGSizeMake(width, height);
}

@end

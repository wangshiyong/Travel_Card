//
//  WSYStringTool.m
//  Travel_Card
//
//  Created by 王世勇 on 2017/3/1.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYStringTool.h"
#import <CommonCrypto/CommonDigest.h>

#define DEFAULT_DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"

@implementation WSYStringTool

+(BOOL)isNilOrEmpty:(NSString*)value
{
    if(value != nil && ![value isKindOfClass:[NSNull class]])
    {
        return value.length == 0;
    }
    
    return YES;
}

+ (NSInteger)stringFromHexStr:(NSString*)str
{
    NSString *hexStr = [NSString string];
    for (NSInteger i =  str.length/2-1; i >= 0 ; i--) {
        hexStr = [hexStr stringByAppendingString:[str substringWithRange:NSMakeRange(i*2, 2)]];
        
    }
    
    NSLog(@"%@",hexStr);
    //先以16为参数告诉strtoul字符串参数表示16进制数字，然后使用0x%X转为数字类型
    unsigned long red = strtoull([hexStr UTF8String],0,16);
    //strtoul如果传入的字符开头是“0x”,那么第三个参数是0，也是会转为十六进制的,这样写也可以：
    //    unsigned long red = strtoul([@"0x6587" UTF8String],0,0);
    //    NSLog(@"转换完的数字为：%lx",red);
    return red;
}

+ (NSAttributedString *)setTextString:(NSString *)text {
    NSMutableAttributedString *mAbStr = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *npgStyle = [[NSMutableParagraphStyle alloc] init];
    npgStyle.alignment = NSTextAlignmentJustified;
    npgStyle.paragraphSpacing = 11.0;
    npgStyle.paragraphSpacingBefore = 10.0;
    npgStyle.firstLineHeadIndent = 0.0;
    npgStyle.headIndent = 0.0;
    NSDictionary *dic = @{
                          //                          NSForegroundColorAttributeName:[UIColor blackColor],
                          //                          NSFontAttributeName           :[UIFont systemFontOfSize:15.0],
                          NSParagraphStyleAttributeName :npgStyle,
                          NSUnderlineStyleAttributeName :[NSNumber numberWithInteger:NSUnderlineStyleNone]
                          };
    [mAbStr setAttributes:dic range:NSMakeRange(0, mAbStr.length)];
    NSAttributedString *attrString = [mAbStr copy];
    return attrString;
}

@end

@implementation NSString(Extend)

- (NSString*)trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)contains:(NSString*)subString
{
    if([WSYStringTool isNilOrEmpty:subString]) return NO;
    
    NSRange range = [self rangeOfString:subString];
    
    return range.location != NSNotFound;
}

- (BOOL)isUrl{
    return [self hasPrefix:@"http://"] || [self hasPrefix:@"https://"] || [self hasPrefix:@"local:"];
}

- (NSInteger)bytesCount{
    if([WSYStringTool isNilOrEmpty:self]) return 0;
    
    int count = 0;
    char *p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for ( NSInteger i=0 ; i<[self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) count++;
        
        p++;
    }
    return count;
}

- (NSDate*)dateWithFormat:(NSString*)format
{
    if([WSYStringTool isNilOrEmpty:format]) format = DEFAULT_DATE_FORMAT;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:format];
    
    return [formatter dateFromString:self];
}

- (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (BOOL)isNumber
{
    NSString *numberRegex = @"^[0-9].*$";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",numberRegex];
    return  [numberTest evaluateWithObject:self];
}

- (NSString*)removeLineBreak
{
    NSInteger x = self.length;
    NSRange range;
    range.location = x-1;
    range.length = 1;
    NSString *str = [self mutableCopy];
    while ([[str substringWithRange:range] isEqualToString:@"\n"]) {
        str = [str substringToIndex:x - 1];
        x = str.length;
        range.location = x-1;
        range.length = 1;
    }
    return str;
}


@end

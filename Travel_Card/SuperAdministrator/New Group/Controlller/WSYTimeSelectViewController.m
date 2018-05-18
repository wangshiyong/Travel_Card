//
//  WSYTimeSelectViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/14.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYTimeSelectViewController.h"
#import "FSCalendar.h"
#import "WSYLanguageTool.h"
#import "YYText.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSYTimeSelectViewController()<FSCalendarDataSource,FSCalendarDelegate>

@property (weak, nonatomic) FSCalendar *calendar;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDictionary<NSString *, UIImage *> *images;
@property (strong, nonatomic) NSMutableString *currentLanguage;

@end

NS_ASSUME_NONNULL_END

@implementation WSYTimeSelectViewController

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"FSCalendar";
//        self.images = @{@"2017/10/04":[UIImage imageNamed:@"icon_cat"],
//                        @"2017/10/05":[UIImage imageNamed:@"icon_footprint"],
//                        @"2017/10/12":[UIImage imageNamed:@"icon_cat"],
//                        @"2017/10/10":[UIImage imageNamed:@"icon_footprint"]};
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    _currentLanguage = [[WSYLanguageTool currentLanguageCode] mutableCopy];
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, self.view.bounds.size.height-64)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.scrollDirection = FSCalendarScrollDirectionHorizontal;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:_currentLanguage];
    
    
    [view addSubview:calendar];
    self.calendar = calendar;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    if (self.standardTime == YES) {
        self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    } else {
        self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    // [self.calendar selectDate:[self.dateFormatter dateFromString:@"2016/02/03"]];
    
    
//     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//     [self.calendar setScope:FSCalendarScopeWeek animated:YES];
//     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//     [self.calendar setScope:FSCalendarScopeMonth animated:YES];
//     });
//     });
    
    
    if (self.num == 0) {
//        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",WSY(@"Start"),self.startTimeStr]];
//        text.yy_font = [UIFont systemFontOfSize:16.0f];
//        text.yy_lineSpacing = 5.0;
//        //    text.yy_color = [UIColor lightGrayColor];
//        if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[1]]) {
//            [text yy_setColor:[UIColor lightGrayColor] range:NSMakeRange(6, 10)];
//            [text yy_setFont:[UIFont systemFontOfSize:12.0f] range:NSMakeRange(6, 10)];
//        } else {
//            [text yy_setColor:[UIColor lightGrayColor] range:NSMakeRange(6, 11)];
//            [text yy_setFont:[UIFont systemFontOfSize:12.0f] range:NSMakeRange(6, 11)];
//        }
        
        YYLabel *headLab = [YYLabel new];
        headLab.frame = (CGRect){0,0,100,44};
//        headLab.attributedText = text;
        headLab.text = WSY(@"Start");
        headLab.numberOfLines = 0;
        headLab.textAlignment = NSTextAlignmentCenter;
        
        UIView *textView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        [textView addSubview:headLab];
        self.navigationItem.titleView = textView;
    } else if (self.num == 1) {
//        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",WSY(@"End"),self.endTimeStr]];
//        text.yy_font = [UIFont systemFontOfSize:16.0f];
//        text.yy_lineSpacing = 5.0;
//        //    text.yy_color = [UIColor lightGrayColor];
//        if ([[WSYUserDataTool getUserData:kLanguage] isEqualToString:LanguageCode[1]]) {
//            [text yy_setColor:[UIColor lightGrayColor] range:NSMakeRange(6, 10)];
//            [text yy_setFont:[UIFont systemFontOfSize:12.0f] range:NSMakeRange(6, 10)];
//        } else {
//            [text yy_setColor:[UIColor lightGrayColor] range:NSMakeRange(8, 11)];
//            [text yy_setFont:[UIFont systemFontOfSize:12.0f] range:NSMakeRange(8, 11)];
//        }
        
        YYLabel *headLab = [YYLabel new];
        headLab.frame = (CGRect){0,0,100,44};
//        headLab.attributedText = text;
        headLab.text = WSY(@"End");
        headLab.numberOfLines = 0;
        headLab.textAlignment = NSTextAlignmentCenter;
        
        UIView *textView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        [textView addSubview:headLab];
        self.navigationItem.titleView = textView;
    } else {
        self.title = WSY(@"Choose Time");
    }
    
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - <FSCalendarDelegate>

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSLog(@"should select date %@",[self.dateFormatter stringFromDate:date]);
    return YES;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSLog(@"did select date %@",[self.dateFormatter stringFromDate:date]);
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
    if (self.delegateSignal) {
        [self.delegateSignal sendNext:[self.dateFormatter stringFromDate:date]];
    }
    
//    if (self.NextViewControllerBlock) {
//        self.NextViewControllerBlock([self.dateFormatter stringFromDate:date]);
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    NSLog(@"did change to page %@",[self.dateFormatter stringFromDate:calendar.currentPage]);
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
}

#pragma mark - <FSCalendarDataSource>


- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    if (self.num == 1) {
        return [self.dateFormatter dateFromString:self.startTimeStr];
    }
    return [self.dateFormatter dateFromString:@"2018-01-01"];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    if (self.num == 0) {
        return [self.dateFormatter dateFromString:self.endTimeStr];
    }
    NSDate *currentDate = [NSDate date];
    return currentDate;
}

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date
{
    if ([self.calendar isDateInToday:date]) {
        return WSY(@"Today");
    }
    return nil;
}

- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date
{
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    return self.images[dateString];
}

@end

//
//  WSYDataStatisticsViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/14.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYDataStatisticsViewController.h"
#import "WSYSuperOnlineViewController.h"
#import "WSYProviderListViewController.h"
#import "ZJScrollPageView.h"


@interface WSYDataStatisticsViewController ()<ZJScrollPageViewDelegate>

@property(strong, nonatomic)NSArray<NSString *> *titles;
@property(strong, nonatomic)NSArray<UIViewController<ZJScrollPageViewChildVcDelegate> *> *childVcs;
@property (weak, nonatomic) ZJScrollSegmentView *segmentView;
@property (weak, nonatomic) ZJContentView *contentView;

@end

@implementation WSYDataStatisticsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.childVcs = [self setupChildVc];
    // 初始化
    [self setupSegmentView];
    [self setupContentView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"N_Setting"] style:UIBarButtonItemStylePlain target:(WSYBaseNavigationViewController *)self.navigationController action:@selector(showMenu)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"M_Time"] style:UIBarButtonItemStylePlain target:self action:@selector(notice)];
}

- (void)setupSegmentView
{
    ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
    style.showCover = YES;
    // 不要滚动标题, 每个标题将平分宽度
    style.scrollTitle = NO;
    
    // 渐变
    style.gradualChangeTitleColor = YES;
    // 遮盖背景颜色
    style.coverBackgroundColor = kThemeRedColor;
    //标题一般状态颜色 --- 注意一定要使用RGB空间的颜色值
    style.normalTitleColor = kThemeRedColor;
    //标题选中状态颜色 --- 注意一定要使用RGB空间的颜色值
    style.selectedTitleColor = Color(255, 255, 255, 1);
    
    if (IS_IPHONE_5) {
        style.titleFont = [UIFont systemFontOfSize:12.0f];
    }
    
    self.titles = @[WSY(@"Online equipment"), WSY(@"Used")];
    
    // 注意: 一定要避免循环引用!!
    __weak typeof(self) weakSelf = self;
    ZJScrollSegmentView *segment = [[ZJScrollSegmentView alloc] initWithFrame:CGRectMake(0, 64.0, IS_IPHONE_5 ? 210.0 : 240.0, 28.0) segmentStyle:style delegate:self titles:self.titles titleDidClick:^(ZJTitleView *titleView, NSInteger index) {
        
        [weakSelf.contentView setContentOffSet:CGPointMake(weakSelf.contentView.bounds.size.width * index, 0.0) animated:YES];
        
    }];
    // 自定义标题的样式
    segment.layer.cornerRadius = 5.0;
//    segment.backgroundColor = kThemeRedColor;
    segment.layer.borderColor = kThemeRedColor.CGColor;
    segment.layer.borderWidth = 1.0;
    // 当然推荐直接设置背景图片的方式
    //    segment.backgroundImage = [UIImage imageNamed:@"extraBtnBackgroundImage"];
    
    self.segmentView = segment;
    self.navigationItem.titleView = self.segmentView;
    
}

- (void)setupContentView
{
    
    ZJContentView *content = [[ZJContentView alloc] initWithFrame:CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 113.0) segmentView:self.segmentView parentViewController:self delegate:self];
    self.contentView = content;
    [self.view addSubview:self.contentView];
    
}

- (NSArray *)setupChildVc
{
    
    NSArray *childVcs = [NSArray arrayWithObjects:[self.storyboard instantiateViewControllerWithIdentifier:@"WSYSuperOnlineViewController"], [self.storyboard instantiateViewControllerWithIdentifier:@"WSYProviderListViewController"], nil];
    return childVcs;
}

- (NSInteger)numberOfChildViewControllers
{
    return self.titles.count;
}



- (UIViewController<ZJScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<ZJScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index
{
    UIViewController<ZJScrollPageViewChildVcDelegate> *childVc = reuseViewController;
    
    if (!childVc) {
        childVc = self.childVcs[index];
    }
    
    if (index == 1) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"M_Time"] style:UIBarButtonItemStylePlain target:self action:@selector(notice)];
    }
    
    return childVc;
}

-(CGRect)frameOfChildControllerForContainer:(UIView *)containerView
{
    return  CGRectInset(containerView.bounds, 20, 20);
}

- (void)notice
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"timeSelect" object:nil];
}

@end

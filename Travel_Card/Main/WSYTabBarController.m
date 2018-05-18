//
//  WSYTabBarController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/25.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYTabBarController.h"
#import "WSYMapViewController.h"
#import "WSYSettingViewController.h"
#import "WSYItineraryViewController.h"
#import "WSYManagerViewController.h"
#import "WSYProviderListViewController.h"
#import "WSYSuperOnlineViewController.h"
#import "WSYReleaseViewController.h"
#import "WSYMessageViewController.h"
#import "WSYBaseNavigationViewController.h"
#import "WSYDataStatisticsViewController.h"
#import "WSYTravelAgencyViewController.h"
#import "WSYStatisticsViewController.h"
#import "WSYTeamViewController.h"
#import <pop/POP.h>

@interface WSYTabBarController ()

@property (nonatomic, assign) NSInteger indexFlag;

@end

@implementation WSYTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.tintColor = kThemeRedColor;
//    self.tabBar.shadowImage = [UIImage new];
//    self.tabBar.backgroundImage = [UIImage new];
//    [self dropShadowWithOffset:CGSizeMake(0, -5) radius:5 color:[UIColor grayColor] opacity:0.3];
    @weakify(self);
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kMemberRelease object:nil]subscribeNext:^(id x){
        @strongify(self);
        WSYReleaseViewController *vc = [[WSYReleaseViewController alloc]init];
        UINavigationController *naVc = [[UINavigationController alloc]initWithRootViewController:vc];
        vc.isMemberRelease = YES;
        vc.memberID = [x object][0];
        vc.deviceID = [x object][1];
        [self presentViewController:naVc animated:YES completion:nil];
    }];
    
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kNotice object:nil]subscribeNext:^(id x){
        @strongify(self);
        WSYMessageViewController *messageVc = [[WSYMessageViewController alloc]init];
        messageVc.isNoticeMessage = YES;
        UINavigationController *naVc = [[UINavigationController alloc]initWithRootViewController:messageVc];
        [self presentViewController:naVc animated:YES completion:nil];
    }];
    
    if ([[WSYUserDataTool getUserData:kGuideIsLogin]integerValue] == 1) {
        WSYMapViewController *mapVc = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYMapViewController"];
        [self addChildVc:mapVc title:WSY(@"Positioning ") image:@"T_Beidou_normal" selectedImage:@"T_Beidou_highlight"];
        
        WSYManagerViewController *managerVc = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYManagerViewController"];
        [self addChildVc:managerVc title:WSY(@"Management ") image:@"T_Manage_normal" selectedImage:@"T_Manage_highlight"];
        
        WSYItineraryViewController *itineraryVc = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYItineraryViewController"];
        [self addChildVc:itineraryVc title:WSY(@"Itinerary ") image:@"T_Itinerary_normal" selectedImage:@"T_Itinerary_highlight"];
        
        WSYSettingViewController *listVc = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYSettingViewController"];
        [self addChildVc:listVc title:WSY(@"Settings") image:@"T_Setting_normal" selectedImage:@"T_Setting_highlight"];
        
        if ([[WSYUserDataTool getUserData:kLogoutLanguage] isEqualToString:@"changeLanguage"]) {
            self.selectedIndex = 3;
        }
    } else if ([[WSYUserDataTool getUserData:kManageIsLogin]integerValue] == 1) {
        if ([[[WSYUserDataTool getUserData:kTravelGencyID] stringValue] isEqualToString:@"-1"]) {
            WSYDataStatisticsViewController *dataVc = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYDataStatisticsViewController"];
            [self addChildVc:dataVc title:WSY(@"Statistics") image:@"T_Statistics_normal" selectedImage:@"T_Statistics_highlight"];
            
            WSYTravelAgencyViewController *travelVc = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYTravelAgencyViewController"];
            [self addChildVc:travelVc title:WSY(@"Service provider") image:@"T_TravelAgency_normal" selectedImage:@"T_TravelAgency_highlight"];
        } else {
            WSYStatisticsViewController *statisticsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYStatisticsViewController"];
            [self addChildVc:statisticsVc title:WSY(@"Statistics") image:@"T_Statistics_normal" selectedImage:@"T_Statistics_highlight"];
            
            WSYTeamViewController *teamlVc = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYTeamViewController"];
            [self addChildVc:teamlVc title:WSY(@"Tour Group") image:@"T_Team_normal" selectedImage:@"T_Team_highlight"];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图片
 *  @param selectedImage 选中的图片
 */
- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    // 设置子控制器的文字
    childVc.title = title; // 同时设置tabbar和navigationBar的文字
    
    // 设置子控制器的图片
    childVc.tabBarItem.image = [UIImage imageNamed:image];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    NSShadow *shadow = [NSShadow.alloc init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(1, 0);
    NSDictionary *textAttrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:12.f],NSFontAttributeName ,shadow,NSShadowAttributeName ,nil];
    NSDictionary *selectTextAttrs = [NSDictionary dictionaryWithObjectsAndKeys:kThemeRedColor,NSForegroundColorAttributeName,[UIFont systemFontOfSize:12.f],NSFontAttributeName ,shadow,NSShadowAttributeName ,nil];
    
    
    // 设置文字的样式
    //    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    //    textAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    //    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    //    selectTextAttrs[NSForegroundColorAttributeName] = kAlertViewColor;
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    
    [childVc.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -2)];
    // 先给外面传进来的小控制器 包装 一个导航控制器
    WSYBaseNavigationViewController *nav = [[WSYBaseNavigationViewController alloc] initWithRootViewController:childVc];
    // 添加为子控制器
    [self addChildViewController:nav];
    
}


//加阴影
-(void)dropShadowWithOffset:(CGSize)offset radius:(CGFloat)radius color:(UIColor *)color opacity:(CGFloat)opacity{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.tabBar.bounds);
    self.tabBar.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.tabBar.layer.shadowColor = color.CGColor;
    self.tabBar.layer.shadowOffset = offset;
    self.tabBar.layer.shadowRadius = radius;
    self.tabBar.layer.shadowOpacity = opacity;
    
    self.tabBar.clipsToBounds = NO;
}

// 点击动画
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSInteger index = [self.tabBar.items indexOfObject:item];
    if (self.indexFlag != index) {
        [self animationWithIndex:index];
    }
}

// 动画
- (void)animationWithIndex:(NSInteger) index {
//    NSMutableArray * tabbarbuttonArray = [NSMutableArray array];
//    for (UIView *tabBarButton in self.tabBar.subviews) {
//        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
//            [tabbarbuttonArray addObject:tabBarButton];
//        }
//    }
    
    // Image动画
    NSMutableArray *tabbarbuttonArray = [NSMutableArray array];
    for (UIView *tabBarButton in self.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            for (UIImageView *imageV in tabBarButton.subviews) {
                if ([imageV isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                    [tabbarbuttonArray addObject:imageV];
                }
            }
        }
    }
    
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulse.duration = 0.15;
    pulse.repeatCount= 1;
    pulse.autoreverses= YES;
    pulse.fromValue= [NSNumber numberWithFloat:0.7];
    pulse.toValue= [NSNumber numberWithFloat:1.3];
    [[tabbarbuttonArray[index] layer]
     addAnimation:pulse forKey:nil];
    
//    [[tabbarbuttonArray[index] layer] pop_removeAllAnimations];
//
//    POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//
//    // 设置代理
//    spring.delegate            = self;
//
//    // 动画起始值 + 动画结束值
//    spring.fromValue           = [NSValue valueWithCGSize:CGSizeMake(0.5f, 0.5f)];
//    spring.toValue             = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
//
//    // 参数的设置
//    spring.springSpeed         = 12.0;
//    spring.springBounciness    = 4.0;
//    spring.dynamicsMass        = 1.0;
//    spring.dynamicsFriction    = 5.0;
//    spring.dynamicsTension     = 200.0;
//
//    // 执行动画
//    [[tabbarbuttonArray[index] layer]
//     pop_addAnimation:spring forKey:nil];
    self.indexFlag = index;
}

@end

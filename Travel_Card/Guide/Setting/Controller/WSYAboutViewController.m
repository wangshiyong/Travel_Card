//
//  WSYAboutViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/9/29.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYAboutViewController.h"
#import <EAIntroView/EAIntroView.h>
#import "AXWebViewController.h"
#import "WSYAboutHeadView.h"
#import "WSYAboutFootView.h"

@interface WSYAboutViewController ()<WSYButtonDelegete,EAIntroDelegate>{
    UIView *rootView;
}

@end

@implementation WSYAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = WSY(@"About");
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];

    WSYAboutHeadView *headVc = [[WSYAboutHeadView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 230)];
    headVc.iconImage.image = [UIImage imageNamed:@"S_logo"];
    headVc.versionLab.text = [NSString stringWithFormat:@"%@ %@",WSY(@"Smart Guide"),currentVersion];
    self.tableView.tableHeaderView = headVc;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    if (self.isShowLeftBtn == YES) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"N_Setting"] style:UIBarButtonItemStylePlain target:(WSYBaseNavigationViewController *)self.navigationController action:@selector(showMenu)];

        if (IS_IPHONE_X) {
            WSYAboutFootView *footVc = [[WSYAboutFootView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 446)];
            footVc.delegate = self;
            self.tableView.tableFooterView = footVc;
        } else {
            WSYAboutFootView *footVc = [[WSYAboutFootView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 406)];
            footVc.delegate = self;
            self.tableView.tableFooterView = footVc;
        }
    } else {
        if (IS_IPHONE_X) {
            WSYAboutFootView *footVc = [[WSYAboutFootView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 422)];
            footVc.delegate = self;
            self.tableView.tableFooterView = footVc;
        }else {
            WSYAboutFootView *footVc = [[WSYAboutFootView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 382)];
            footVc.delegate = self;
            self.tableView.tableFooterView = footVc;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 点击进入官网
 */
- (void)webClicked:(id)sender {
    AXWebViewController *webVC = [[AXWebViewController alloc] initWithAddress:@"http://www.zhihuiquanyu.com"];
    webVC.maxAllowedTitleLength = 12;
    [self.navigationController pushViewController:webVC animated:YES];
    webVC.navigationType = 1;
    [[NSNotificationCenter defaultCenter]postNotificationName:kWebNotice object:nil];
}

/** 引导页 */
-(void)showPageControl{
    rootView = self.navigationController.view;
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.bgImage = [UIImage imageNamed:WSY(@"M_BG1")];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:WSY(@"M_BG2")];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.bgImage = [UIImage imageNamed:WSY(@"M_BG3")];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.bgImage = [UIImage imageNamed:WSY(@"M_BG4")];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:rootView.bounds];
    intro.pageControl.currentPageIndicatorTintColor = kThemeRedColor;
    intro.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [intro setDelegate:self];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, kScreenWidth/2 , 70)];
    [btn setTitle:WSY(@"Use now") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:kThemeRedColor];
    btn.layer.borderWidth = 2.f;
    btn.layer.cornerRadius = 10;
    btn.layer.borderColor = [kThemeRedColor CGColor];
    intro.skipButton = btn;
    intro.skipButtonAlignment = EAViewAlignmentCenter;
    intro.skipButtonY = 140.f;
    intro.pageControlY = 62.f;
    intro.skipButton.enabled = NO;
    intro.skipButton.alpha = 0.f;
    
    page4.onPageDidAppear = ^{
        intro.skipButton.enabled = YES;
        intro.limitPageIndex = intro.visiblePageIndex;
        [UIView animateWithDuration:0.3f animations:^{
            intro.skipButton.alpha = 1.f;
        }];
    };
    
    page4.onPageDidDisappear = ^{
        intro.skipButton.enabled = NO;
        [intro setScrollingEnabled:YES];
        [UIView animateWithDuration:0.3f animations:^{
            intro.skipButton.alpha = 0.f;
        }];
    };
    
    [intro setPages:@[page1,page2,page3,page4]];
    
    [intro showInView:rootView animateDuration:0.3];
}

#pragma mark =============Table view data source／delegate=============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (self.isShowLeftBtn == YES) {
//        return 3;
//    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row == 0) {
        cell.textLabel.text = WSY(@"Welcome Page");
    } else {
//        if (self.isShowLeftBtn == YES) {
//            if (indexPath.row == 1) {
//                cell.textLabel.text = @"折线图说明";
//            } else {
//                cell.textLabel.text = @"给我们评分";
//            }
//        } else {
//            cell.textLabel.text = @"给我们评分";
//        }
        cell.textLabel.text = WSY(@"Rating");
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        //引导页
        [self showPageControl];
    } else {
        NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1217302886&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"];
        [[UIApplication sharedApplication]openURL:url];
//        if (self.isShowLeftBtn == YES) {
//            if (indexPath.row == 1) {
//                AXWebViewController *webVC = [[AXWebViewController alloc] initWithURL:[NSURL fileURLWithPath:[NSBundle.mainBundle pathForResource:@"WSYChart.pdf" ofType:nil]]];
//                webVC.title = @"折线图说明";
//                webVC.showsToolBar = NO;
//                webVC.navigationType = 1;
//                [self.navigationController pushViewController:webVC animated:YES];
//
//            } else {
//                NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1217302886&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"];
//                [[UIApplication sharedApplication]openURL:url];
//            }
//        } else {
//            NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1217302886&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"];
//            [[UIApplication sharedApplication]openURL:url];
//        }
    }
}

@end

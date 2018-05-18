//
//  WSYMenuViewController.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/18.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYMenuViewController.h"
#import "WSYAboutViewController.h"
#import "WSYTabBarController.h"
#import "iOS-Echarts.h"
#import "MTreeView.h"

#define DegreesToRadians(degrees) (degrees * M_PI / 180)
#define WSYCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
static NSString *const kCaches = @"Caches";

@interface WSYMenuViewController ()<MTreeViewDelegate>

@property (strong, nonatomic) IBOutlet MTreeView *treeView;

@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) NSArray *allSupportThemes;
@property (strong, nonatomic) NSMutableString *currentLanguage;

@end


@implementation WSYMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.treeView.separatorColor  = [UIColor groupTableViewBackgroundColor];
    self.treeView.opaque          = NO;
    self.treeView.backgroundColor = [UIColor clearColor];
    self.treeView.delegate        = self;
    self.treeView.dataSource      = self;
    self.treeView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.treeView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:(CGRect){0, 0, 0, 200}];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [UIImage imageNamed:@"S_logo"];
//        imageView.layer.masksToBounds = YES;
//        imageView.layer.cornerRadius = 50.0;
//        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
//        imageView.layer.borderWidth = 3.0f;
//        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        imageView.layer.shouldRasterize = YES;
//        imageView.clipsToBounds = YES;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        if ([[WSYUserDataTool getUserData:kMenu] isEqualToString:@"0"]) {
            label.text = WSY(@"Administrator");
        } else {
            label.text = WSY(@"Super Administrator");
        }
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

        [view addSubview:imageView];
        [view addSubview:label];
        view;
    });

    
    self.treeView.rootNode = [MTreeNode initWithParent:nil expand:NO];
    for (int i = 0; i < 6; i++) {
        MTreeNode *node = [MTreeNode initWithParent:self.treeView.rootNode expand:(0 == i)];
        if (i == 1) {
            for (int k = 0; k < 9; k++) {
                MTreeNode *subnode1 = [MTreeNode initWithParent:node expand:NO];
                [node.subNodes addObject:subnode1];
            }
            node.expand = NO;
        }
        [self.treeView.rootNode.subNodes addObject:node];
    }
    
    _currentLanguage = [[WSYLanguageTool currentLanguageCode] mutableCopy];
    
    @weakify(self);
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kWebNotice object:nil]subscribeNext:^(id x){
        @strongify(self);
        [self.tableView reloadData];
    }];
}

#pragma mark ============懒加载============

- (NSArray *)contents
{
    if (!_contents)
    {
        _contents = @[WSY(@"macarons"),WSY(@"macarons2"), WSY(@"shine"), WSY(@"blue"), WSY(@"green"), WSY(@"red"), WSY(@"helianthus"), WSY(@"sakura"), WSY(@"mint")];
    }
    return _contents;
}

- (NSArray *)allSupportThemes
{
    if (!_allSupportThemes)
    {
        _allSupportThemes = @[PYEchartThemeMacarons, PYEchartThemeMacarons2, PYEchartThemeShine, PYEchartThemeBlue, PYEchartThemeGreen, PYEchartThemeRed, PYEchartThemeHelianthus, PYEchartThemeSakura, PYEchartThemeMint];
    }
    
    return _allSupportThemes;
}

#pragma mark ============UITableView delegate============

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.treeView numberOfSectionsInTreeView:self.treeView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.treeView treeView:self.treeView numberOfRowsInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MTreeNode *subNode = [[self.treeView.rootNode subNodes] objectAtIndex:section];
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.bounds), 44)];
    {
        sectionView.tag = 1000 + section;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionTaped:)];
        [sectionView addGestureRecognizer:recognizer];
        sectionView.backgroundColor = [UIColor whiteColor];
//        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 0, CGRectGetMaxX(self.view.bounds), 0.5)];
//        line.backgroundColor = [UIColor lightGrayColor];
//        line.alpha = 0.5f;
//        [sectionView addSubview:line];
    }
    {
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){50, 0, 200, 44}];
        NSArray *array = @[WSY(@"Home Page"),WSY(@"Chart Theme"),WSY(@"Language"),WSY(@"About & Help"),WSY(@"Clean Cache"),WSY(@"Log Out")];
        label.text = [NSString stringWithFormat:@"%@",array[section]];
        
        [sectionView addSubview:label];
    }
    {
        UIImageView *image = [[UIImageView alloc]initWithFrame:(CGRect){16, 12, 20, 20}];
        NSArray *array = @[@"M_home",@"M_chartsTheme",@"M_language_2",@"M_about",@"M_clean",@"M_logout"];
        image.image = [UIImage imageNamed:array[section]];
        [sectionView addSubview:image];
    }
    
    if (sectionView.tag == 1001) {
        UIImageView *tipImageView = [[UIImageView alloc]init];
        tipImageView.image = [UIImage imageNamed:@"expandableImage"];
        tipImageView.tag = 10;
        [sectionView addSubview:tipImageView];
        [tipImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(sectionView).offset(-20);
            make.centerY.equalTo(sectionView);
            make.width.mas_equalTo(8);
            make.height.mas_equalTo(5);
        }];
        [self doTipImageView:tipImageView expand:subNode.expand];
    } else if (sectionView.tag == 1003) {
//        UILabel *lab = [[UILabel alloc]init];
//        lab.text = [NSString stringWithFormat:@"%.2fMB",[self getCashes]];
//        lab.textAlignment = NSTextAlignmentRight;
//        lab.font = [UIFont systemFontOfSize:15.0f];
//        lab.textColor = [UIColor lightGrayColor];
//        [sectionView addSubview:lab];
//        [lab mas_makeConstraints:^(MASConstraintMaker *make){
//            make.right.equalTo(sectionView).offset(-20);
//            make.centerY.equalTo(sectionView);
//            make.width.mas_equalTo(80);
//            make.height.mas_equalTo(30);
//        }];
//        [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kCaches object:nil]subscribeNext:^(id x){
//            lab.text = @"0.00MB";
//        }];
    }
    
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.contents[indexPath.row]];
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];

    NSString *numStr = [WSYUserDataTool getUserData:kThemeNumber];
    NSString *rowStr = [NSString stringWithFormat:@"%ld",(long)indexPath.row];

    if ([numStr isEqualToString:rowStr]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.treeView expandNodeAtIndexPath:indexPath];

    //折线图主题通知
    [[NSNotificationCenter defaultCenter]postNotificationName:@"theme" object:self.allSupportThemes[indexPath.row]];
    
    [WSYUserDataTool setUserData:self.allSupportThemes[indexPath.row] forKey:kTheme];
    [WSYUserDataTool setUserData:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:kThemeNumber];
    
    [self.treeView expandNodeAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:1]];
    
    [self.frostedViewController hideMenuViewController];
}

#pragma mark ============点击headSection============

- (void) doTipImageView:(UIImageView *)imageView expand:(BOOL) expand {
    [UIView animateWithDuration:0.2f animations:^{
        imageView.transform = (expand) ? CGAffineTransformMakeRotation(DegreesToRadians(180)) : CGAffineTransformIdentity;
    }];
}

- (void)sectionTaped:(UIGestureRecognizer *) recognizer {
    UIView *view = recognizer.view;
    NSUInteger tag = view.tag - 1000;
    
    if (tag == 0) {
        [self homeVc];
    } else if (tag == 1) {
        [self expandView:view withTag:tag];
    } else if (tag == 2) {
        [self changeLanguage];
    } else if (tag == 3) {
        [self aboutVc];
    } else if (tag == 4) {
        if (!([[NSString stringWithFormat:@"%.2f",[self getCashes]] isEqualToString:@"0.00"])) {
            [self cleanCaches:tag];
        }
    } else {
        [self logout];
    }
    
}

/**
 进入主界面
 */
- (void)homeVc {
    if ([[WSYUserDataTool getUserData:kMenu] isEqualToString:@"0"]) {
        WSYTabBarController *tabBarVc = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYTabBarController"];
        self.frostedViewController.contentViewController = tabBarVc;
    }else {
        WSYTabBarController *tabBarVc = [self.storyboard instantiateViewControllerWithIdentifier:@"WSYTabBarController"];
        self.frostedViewController.contentViewController = tabBarVc;
    }
    [self.frostedViewController hideMenuViewController];
}

/**
 展开缩进
 */
- (void)expandView:(UIView *)view withTag:(NSUInteger)tag {
    UIImageView *tipImageView = [view viewWithTag:10];
    MTreeNode *subNode = [self.treeView nodeAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:tag]];
    [self.treeView expandNodeAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:tag]];
    [self doTipImageView:tipImageView expand:subNode.expand];
}

/**
 进入关于界面
 */
- (void)aboutVc {
    WSYAboutViewController *aboutVc = [[WSYAboutViewController alloc]init];
    aboutVc.isShowLeftBtn = YES;
    WSYBaseNavigationViewController *naVc = [[WSYBaseNavigationViewController alloc]initWithRootViewController:aboutVc];
    self.frostedViewController.contentViewController = naVc;
    [self.frostedViewController hideMenuViewController];
}

/**
 切换语言
 */
-(void)changeLanguage{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    //    [alert setHorizontalButtons:YES];
    //    [alert setShouldDismissOnTapOutside:YES];
    if ([_currentLanguage isEqualToString:LanguageCode[0]]) {
        [alert addButton:@"中文" actionBlock:^(void) {
            _currentLanguage = LanguageCode[1];
            [WSYLanguageTool userSelectedLanguage:_currentLanguage];
            [[NSNotificationCenter defaultCenter]postNotificationName:kchangeLanguage object:nil];
            [WSYUserDataTool removeUserData:kLanguage];
            [WSYUserDataTool setUserData:_currentLanguage forKey:kLanguage];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } else {
        [alert addButton:@"English" actionBlock:^(void) {
            _currentLanguage = LanguageCode[0];
            [WSYLanguageTool userSelectedLanguage:_currentLanguage];
            [[NSNotificationCenter defaultCenter]postNotificationName:kchangeLanguage object:nil];
            [WSYUserDataTool removeUserData:kLanguage];
            [WSYUserDataTool setUserData:_currentLanguage forKey:kLanguage];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:[UIImage imageNamed:@"S_language"] color:kThemeRedColor title:WSY(@" Language ") subTitle:nil closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}

/**
 清理缓存
 */
-(void)cleanCaches:(NSUInteger)indexPath{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    [alert addButton:WSY(@"OK") actionBlock:^(void) {
        NSString *path = WSYCachesPath;
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            NSArray *childerFiles=[fileManager subpathsAtPath:path];
            for (NSString *fileName in childerFiles) {
                NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
                [fileManager removeItemAtPath:absolutePath error:nil];
            }
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:kCaches object:nil];
        [self cleanHUD];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showSuccessHUDWindow:WSY(@"Complete")];
        });
    }];
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:self image:[UIImage imageNamed:@"S_clean"] color:kThemeRedColor title:WSY(@"Clean Cache") subTitle:[NSString stringWithFormat:@"%@%.2fM,%@",WSY(@"The cache size is "),[self getCashes],WSY(@"Sure to clean up cache?")] closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}

-(float)getCashes{
    NSString *path = WSYCachesPath;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    float folderSize = 0.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *fullPath = [path stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:fullPath];
        }
    }
    return folderSize;
}

-(float)fileSizeAtPath:(NSString *)path{
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:path]){
        
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}

/**
 退出
 */
- (void)logout {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert setHorizontalButtons:YES];
    [alert addButton:WSY(@"OK") actionBlock:^(void) {
        [WSYUserDataTool removeUserData:kManageIsLogin];
        [self showHUDWindow:WSY(@"Log Out")];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor lightGrayColor];
        return buttonConfig;
    };
    [alert showCustom:self image:[UIImage imageNamed:@"S_logout"] color:kThemeRedColor title:WSY(@"Determine to log out?") subTitle:nil closeButtonTitle:WSY(@"Cancel") duration:0.0f];
}

@end

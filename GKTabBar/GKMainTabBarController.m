//
//  ViewController.m
//  GKTabBar
//
//  Created by QuintGao on 2017/12/26.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKMainTabBarController.h"
#import "GKTestViewController.h"
#import "GKTabBar.h"
#import "GKPlayerButton.h"

@interface GKMainTabBarController ()

@property (nonatomic, assign) BOOL isRotation;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat progress;

@end

@implementation GKMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加子控制器
    [self addChildVCs];
    
    // 替换系统tabbar为自定义tabbar
    [self setValue:[GKTabBar new] forKey:@"tabBar"];
    
    [[GKPlayerButton sharedInstance] setNoHistoryData];
    [[GKPlayerButton sharedInstance] setImageUrl:nil];
    
    [GKPlayerButton sharedInstance].btnClickBlock = ^{
        if (self.isRotation) {
            [self pause];
            self.isRotation = NO;
        }else {
            [self play];
            self.isRotation = YES;
        }
    };
}

- (void)play {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

- (void)pause {
    [self.timer invalidate];
    self.timer = nil;
    
    [[GKPlayerButton sharedInstance] setProgress:self.progress animated:NO];
}

- (void)timerAction {
    self.progress += 0.01;
    
    if (self.progress >= 1.0) {
        [self.timer invalidate];
        self.timer = nil;
        [[GKPlayerButton sharedInstance] setProgress:self.progress animated:NO];;
    }else {
        [[GKPlayerButton sharedInstance] setProgress:self.progress animated:YES];
    }
}

/**
 添加子控制器
 */
- (void)addChildVCs {
    // 首页
    [self addChildVC:[GKTestViewController new] title:@"首页" imageName:@"tabbar_rootvc"];
    
    // 相对论
    [self addChildVC:[GKTestViewController new] title:@"相对论" imageName:@"tabbar_relativity"];
    
    // 订阅听
    [self addChildVC:[GKTestViewController new] title:@"订阅听" imageName:@"tabbar_rss"];
    
    // 我的
    [self addChildVC:[GKTestViewController new] title:@"我的" imageName:@"tabbar_membercenter"];
}

/**
 添加一个子控制器
 
 @param childVC 子控制器
 @param title tabbar标题
 @param imageName tabbar图片名称
 */
- (void)addChildVC:(UIViewController *)childVC title:(NSString *)title imageName:(NSString *)imageName {
    
    NSString *normalImage = [imageName stringByAppendingString:@"_normal"];
    NSString *selectedImage = [imageName stringByAppendingString:@"_selected"];
    
    childVC.title = title;
    childVC.tabBarItem.image = [UIImage imageNamed:normalImage];
    childVC.tabBarItem.selectedImage = [UIImage imageNamed:selectedImage];
    
    [childVC.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor]} forState:UIControlStateNormal];
    [childVC.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor redColor]} forState:UIControlStateSelected];
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:childVC];
    
    [self addChildViewController:navVC];
}


@end

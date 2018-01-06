//
//  GKPlayerButton.h
//  GKTabBar
//
//  Created by QuintGao on 2017/12/26.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKPlayerButton : UIButton

+ (instancetype)sharedInstance;

/** 半径 */
@property (nonatomic, assign) CGFloat radius;

/** 线宽度 */
@property (nonatomic, assign) CGFloat lineWidth;

/** 线颜色 */
@property (nonatomic, strong) UIColor *strokeColor;

@property (nonatomic, copy) void (^btnClickBlock)(void);

- (void)setNoHistoryData;

- (void)setImageUrl:(NSString *)imgUrl;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end

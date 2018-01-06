//
//  GKTabBar.m
//  GKTabBar
//
//  Created by QuintGao on 2017/12/26.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKTabBar.h"
#import "GKPlayerButton.h"

@interface GKTabBar()

@property (nonatomic, strong) GKPlayerButton *playerButton;

@end

@implementation GKTabBar

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.playerButton];
        
        // 设置背景颜色
        self.barTintColor = [UIColor whiteColor];
        self.translucent  = NO;
        // 隐藏分割线
        self.shadowImage     = [UIImage new];
        self.backgroundImage = [UIImage new];
        
        // 添加自定义带layer的视图
        [self insertSubview:[self layerView] atIndex:0];
    }
    return self;
}

- (UIView *)layerView {
    
    // 凸起的高度 ((按钮高度 - tabbar高度) / 2 - 15.0)
    CGFloat bulgeHeight = 16.0f;
    // tabbar高度
    CGFloat tabbarH     = kTabBarHeight;
    
    // 圆半径
    CGFloat radius = 68.0f * 0.5;
    
    // 计算凸起半圆的宽度的一半
    CGFloat bulgeSquare = (pow(radius, 2) - pow((radius - bulgeHeight), 2)); // 平方
    CGFloat bulgeWidth = sqrtf(bulgeSquare); // 开平方
    
    UIView *layerView = [[UIView alloc] initWithFrame:CGRectMake(0, -bulgeHeight, kScreenW, tabbarH + bulgeHeight)];
    CGSize size = layerView.frame.size;
    
    // 创建layer
    CAShapeLayer *layer = [CAShapeLayer layer];
    // 创建路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(size.width * 0.5 - bulgeWidth, bulgeHeight)];
    
    CGFloat angleH = (radius - bulgeHeight) / radius * 0.5;
    
    CGFloat startAngle = (1 + angleH) * ((float)M_PI);  // 开始弧度
    CGFloat endAngle   = (2 - angleH) * ((float)M_PI);  // 结束弧度
    
    [path addArcWithCenter:CGPointMake(size.width * 0.5, radius) radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    // 圆弧以外的部分
    [path addLineToPoint:CGPointMake(size.width * 0.5 + bulgeWidth, bulgeHeight)];
    [path addLineToPoint:CGPointMake(size.width, bulgeHeight)];
    [path addLineToPoint:CGPointMake(size.width, size.height)];
    [path addLineToPoint:CGPointMake(0, size.height)];
    [path addLineToPoint:CGPointMake(0, bulgeHeight)];
    
    [path addLineToPoint:CGPointMake(size.width * 0.5 - bulgeWidth, bulgeHeight)];
    
    layer.path = path.CGPath;
    layer.fillColor = [UIColor whiteColor].CGColor;
    
    // 设置layer投影
    layer.shadowRadius  = 8.0f;
    layer.shadowColor   = [[UIColor blackColor] colorWithAlphaComponent:0.3f].CGColor;
    layer.shadowOpacity = 1.0f;
    layer.shadowOffset  = CGSizeMake(0, 0);
    
    [layerView.layer addSublayer:layer];
    
    return layerView;
}

// 重新hitTest方法，扩大播放器按钮的点击范围
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    //这一个判断是关键，不判断的话push到其他页面，点击发布按钮的位置也是会有反应的，这样就不好了
    //self.isHidden == NO 说明当前页面是有tabbar的，那么肯定是在导航控制器的根控制器页面
    //在导航控制器根控制器页面，那么我们就需要判断手指点击的位置是否在发布按钮身上
    //是的话让发布按钮自己处理点击事件，不是的话让系统去处理点击事件就可以了
    if (self.isHidden == NO) {
        
        //将当前tabbar的触摸点转换坐标系，转换到发布按钮的身上，生成一个新的点
        CGPoint newP = [self convertPoint:point toView:self.playerButton];
        
        //判断如果这个新的点是在发布按钮身上，那么处理点击事件最合适的view就是发布按钮
        if ( [self.playerButton pointInside:newP withEvent:event]) {
            return self.playerButton;
        }else{//如果点不在发布按钮身上，直接让系统处理就可以了
            return [super hitTest:point withEvent:event];
        }
    }
    else {//tabbar隐藏了，那么说明已经push到其他的页面了，这个时候还是让系统去判断最合适的view处理就好了
        return [super hitTest:point withEvent:event];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width  = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat offsetCenterY = IS_58INCH ? 7.5f + 20 : kAdaptationRation * 7.5f;
    
    self.playerButton.center = CGPointMake(width * 0.5, height * 0.5 - offsetCenterY);
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = width / 5;
    
    NSInteger index = 0;
    
    for (UIControl *button in self.subviews) {
        if (![button isKindOfClass:[UIControl class]] || button == self.playerButton) {
            continue;
        }
        // 计算btnX
        btnX = btnW * (index > 1 ? index + 1 : index);
        
        // 重新设置frame
        button.frame = CGRectMake(btnX, btnY, btnW, button.frame.size.height);
        
        // 索引增加
        index++;
    }
}

#pragma mark - 懒加载
- (GKPlayerButton *)playerButton {
    if (!_playerButton) {
        _playerButton = [GKPlayerButton sharedInstance];
    }
    return _playerButton;
}

@end

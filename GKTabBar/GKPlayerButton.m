//
//  GKPlayerButton.m
//  GKTabBar
//
//  Created by QuintGao on 2017/12/26.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKPlayerButton.h"

@interface GKPlayerButton()

@property (nonatomic, strong) CAShapeLayer *animatedLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) BOOL isRotation;

@property (nonatomic, strong) UIImageView *coverImgView;
@property (nonatomic, strong) UIImageView *playImgView;

@end

@implementation GKPlayerButton

+ (instancetype)sharedInstance {
    static GKPlayerButton *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GKPlayerButton new];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.coverImgView];
        [self addSubview:self.playImgView];
        
        // 设置背景图片
        [self setBackgroundImage:[UIImage imageNamed:@"tabbar_player_bg"] forState:UIControlStateNormal];
        // 设置默认图片
        [self setImage:[UIImage imageNamed:@"tabbar_player_normal"] forState:UIControlStateNormal];
        
        [self addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 设置frame
        self.frame = CGRectMake(0, 0, 68.0f, 68.0f);
        
        self.playImgView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
        self.coverImgView.center = self.playImgView.center;
        
        self.radius      = 25.0f;
        self.lineWidth   = 3.0f;
        self.strokeColor = [UIColor redColor];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    if (!CGRectEqualToRect(frame, super.frame)) {
        [super setFrame:frame];
        
        if (self.superview) {
            [self layoutAnimatedLayer];
        }
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self layoutAnimatedLayer];
    }else {
        [self.animatedLayer removeFromSuperlayer];
        self.animatedLayer = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imgWH = self.radius * 2 - self.lineWidth - 1;
    
    self.imageView.bounds = CGRectMake(0, 0, imgWH, imgWH);
    self.imageView.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
    
    self.coverImgView.bounds = self.imageView.bounds;
    self.coverImgView.center = self.imageView.center;
    
    self.imageView.layer.cornerRadius  = imgWH * 0.5;
    self.imageView.layer.masksToBounds = YES;
    
    self.coverImgView.layer.cornerRadius = imgWH * 0.5;
    self.coverImgView.layer.masksToBounds = YES;
    
    self.playImgView.bounds = self.imageView.bounds;
    self.playImgView.center = self.imageView.center;
    
    self.playImgView.layer.cornerRadius = imgWH * 0.5;
    self.playImgView.layer.masksToBounds = YES;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat wh = (self.radius + self.lineWidth * 0.5 + 5) * 2;
    return CGSizeMake(wh, wh);
}

// 取消按钮高亮
- (void)setHighlighted:(BOOL)highlighted {}

- (void)layoutAnimatedLayer {
    CALayer *layer = self.animatedLayer;
    [self.layer addSublayer:layer];
    
    CGFloat viewW  = CGRectGetWidth(self.bounds);
    CGFloat viewH  = CGRectGetHeight(self.bounds);
    CGFloat layerW = CGRectGetWidth(layer.bounds);
    CGFloat layerH = CGRectGetHeight(layer.bounds);
    
    CGFloat widthDiff  = viewW - layerW;
    CGFloat heightDiff = viewH - layerH;
    CGFloat positionX = viewW - layerW * 0.5 - widthDiff * 0.5;
    CGFloat positionY = viewH - layerH * 0.5 - heightDiff * 0.5;
    layer.position = CGPointMake(positionX, positionY);
}

- (void)btnClick:(id)sender {
    !self.btnClickBlock ? : self.btnClickBlock();
}

#pragma mark - Public Methods
/**
 没有历史播放数据时调用
 */
- (void)setNoHistoryData {
    self.coverImgView.hidden = YES;
    self.playImgView.hidden  = YES;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.animatedLayer.strokeEnd = progress;
    [CATransaction commit];
    
    if (animated) {
        if (self.isRotation) return;
        
        self.isRotation = YES;
        self.playImgView.hidden = YES;
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(rotationAnimation)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }else {
        if (!self.isRotation) return;
        
        self.isRotation = NO;
        
        self.playImgView.hidden = NO;
        
        [self.displayLink invalidate];
        self.displayLink = nil;
        
        // 恢复图片位置
        self.imageView.transform = CGAffineTransformIdentity;
    }
}

- (void)setImageUrl:(NSString *)imgUrl {
    self.coverImgView.hidden = NO;
    
    [self setImage:[UIImage imageNamed:@"dzq"] forState:UIControlStateNormal];
}

- (void)rotationAnimation {
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI_4 / 100.0f);
}

#pragma mark - setter
- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    
    self.animatedLayer.lineWidth = lineWidth;
    
    [self layoutIfNeeded];
}

- (void)setRadius:(CGFloat)radius {
    if (radius != _radius) {
        _radius = radius;
        
        [self.animatedLayer removeFromSuperlayer];
        self.animatedLayer = nil;
        
        if (self.superview) {
            [self layoutAnimatedLayer];
        }
    }
    [self layoutIfNeeded];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    
    self.animatedLayer.strokeColor = strokeColor.CGColor;
}

#pragma mark - 懒加载
- (CAShapeLayer *)animatedLayer {
    if (!_animatedLayer) {
        CGFloat xy = self.radius + self.lineWidth * 0.5 + 5;
        CGPoint arcCenter = CGPointMake(xy, xy);
        
        
        _animatedLayer = [CAShapeLayer new];
        _animatedLayer.contentsScale = [UIScreen mainScreen].scale;
        _animatedLayer.frame       = CGRectMake(0, 0, arcCenter.x * 2, arcCenter.y * 2);
        _animatedLayer.fillColor   = [UIColor clearColor].CGColor;
        _animatedLayer.strokeColor = self.strokeColor.CGColor;
        _animatedLayer.lineWidth   = self.lineWidth;
        _animatedLayer.lineCap     = kCALineCapRound;
        _animatedLayer.lineJoin    = kCALineJoinBevel;
        
        UIBezierPath *smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                    radius:self.radius
                                                                startAngle:-M_PI_2
                                                                  endAngle:M_PI + M_PI_2
                                                                 clockwise:YES];
        _animatedLayer.path = smoothedPath.CGPath;
        
        _animatedLayer.strokeEnd = 0.0f;
    }
    return _animatedLayer;
}

- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [UIImageView new];
        _coverImgView.image = [UIImage imageNamed:@"tabbar_player_cover"];
    }
    return _coverImgView;
}

- (UIImageView *)playImgView {
    if (!_playImgView) {
        _playImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_player_paused"]];
        [_playImgView sizeToFit];
    }
    return _playImgView;
}

@end

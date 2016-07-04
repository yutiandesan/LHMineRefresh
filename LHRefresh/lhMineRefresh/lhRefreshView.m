//
//  lhRefreshView.m
//  SCFinance
//
//  Created by bosheng on 16/6/20.
//  Copyright © 2016年 liuhuan. All rights reserved.
//

#import "lhRefreshView.h"
#import "UIImage+GIF.h"
#import "UIColor+lhColor.h"
#import <objc/message.h>

@interface lhRefreshView()<UIScrollViewDelegate>

@end

@implementation lhRefreshView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.state = lhRefreshStateNormal;
    
    //动图
    _refreshImgView = [UIImageView new];
    [self addSubview:_refreshImgView];
    
    NSString * path = [[NSBundle mainBundle]pathForResource:@"refreshImage" ofType:@"gif"];;
    NSData * picData = [[NSData alloc]initWithContentsOfFile:path];
    if (picData) {
        UIImage * img = [UIImage sd_animatedGIFWithData:picData];//可自己控制执行时间
        dispatch_async(dispatch_get_main_queue(), ^{
            _refreshImgView.image = img;
        });
    }
    
    //状态
    _sLabel = [UILabel new];
    _sLabel.text = @"下拉即可刷新";
    _sLabel.textAlignment = NSTextAlignmentCenter;
    _sLabel.font = [UIFont systemFontOfSize:12];
    _sLabel.textColor = [UIColor colorFromHexRGB:@"979797"];
    [self addSubview:_sLabel];
    
    _sLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 20);
    _refreshImgView.frame = CGRectMake((CGRectGetWidth(self.bounds)-57)/2, 0, 57, 45);

    _refreshImgView.hidden = YES;
    _sLabel.hidden = YES;
    
    return self;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    if (_heih <= 0) {//上滑，偏移量为正则隐藏刷新控件
        _refreshImgView.hidden = YES;
        _sLabel.hidden = YES;
        
        _heih = 0;
    }
    else{//下拉
        _refreshImgView.hidden = NO;
        _sLabel.hidden = NO;
        if (_heih > totalHeih) {
            _heih = totalHeih;
        }
    }
    
    if (_heih >= refreshHeih) {//达到可刷新区域
        if (self.state != lhRefreshStateRefreshing) {//当前状态不是正在刷新
            self.state = lhRefreshStateWillRefreshing;
            self.refreshOriginY = _heih;
            
            _sLabel.text = @"释放即可刷新";
        }
    }
    else{//未达到可刷新区域
        self.state = lhRefreshStateNormal;
        
        _sLabel.text = @"下拉即可刷新";
    }
    
    UIColor * color = [UIColor colorFromHexRGB:@"edeeef"];//椭圆颜色
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    CGContextAddEllipseInRect(context, CGRectMake(0, -_heih, self.bounds.size.width, 2*_heih)); //椭圆
    CGContextDrawPath(context, kCGPathFill);
    
    //更新动图和状态字frame
    [self updateGifAndStatusFrame];
}

#pragma mark - _scrollView的contentOffset变化检测相当于scrollViewDidScroll
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    if ([@"contentOffset"isEqualToString:keyPath]) {

        if (_scrollView.isDragging) {//拖动中
            
            if (self.state == lhRefreshStateNormal && _scrollView.contentOffset.y < -refreshHeih) {
                // 转为即将刷新状态
                self.state = lhRefreshStateWillRefreshing;
                
            }
            else if (self.state == lhRefreshStateWillRefreshing && _scrollView.contentOffset.y >= -refreshHeih) {
                // 转为普通状态
                self.isRefreshing = 2;
                self.state = lhRefreshStateNormal;
                
            }
            else if(self.state == lhRefreshStateRefreshing && _scrollView.contentOffset.y >= -refreshHeih){
                // 转为普通状态
                self.isRefreshing = 2;
                self.state = lhRefreshStateNormal;
                
            }
        } else if ((self.state == lhRefreshStateWillRefreshing) && (self.isRefreshing != 1)) {// 即将刷新 && 手松开
            
            [self refresh];
        }
        
        if (-_scrollView.contentOffset.y <= 0) {
            UIEdgeInsets inset = _scrollView.contentInset;
            inset.top = 0;
            _scrollView.contentInset = inset;
            self.isRefreshing = 0;
            
            self.heih = 0;
        }
        else if (-_scrollView.contentOffset.y > totalHeih) {
            self.heih = totalHeih;
        }
        else{
            self.heih = -_scrollView.contentOffset.y;
        }
        self.frame = CGRectMake(0, 0, self.bounds.size.width, self.heih);
        
        [self setNeedsDisplay];
    }
}

//刷新，回调
- (void)refresh
{
    // 开始刷新
    self.state = lhRefreshStateRefreshing;
    self.isRefreshing = 1;
    
    _sLabel.text = @"正在刷新";
    
    //设置滚动位置
    _scrollView.contentOffset = CGPointMake(0, -self.refreshOriginY);
    [UIView animateWithDuration:0.2 animations:^{
        UIEdgeInsets inset = _scrollView.contentInset;
        inset.top = self.refreshOriginY;
        _scrollView.contentInset = inset;
        
    }];
    
    // 回调
    if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
        
        objc_msgSend(self.beginRefreshingTaget, self.beginRefreshingAction, self);//该方法报错，请尝试选中项目 - Project - Build Settings - ENABLE_STRICT_OBJC_MSGSEND 将其设置为 NO
    }
}

//拖动结束
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.isRefreshing == 2) {
        
        [self endRefresh1];
    }
}

#pragma mark - 开始刷新
- (void)beginRefreshing
{
    NSLog(@"开始刷新");
    
    self.isRefreshing = 0;

    [self beginRefresh1];
    
}

- (void)beginRefresh1
{
    [UIView animateWithDuration:0.0001 animations:^{
        self.heih += 4;
        
        _scrollView.contentOffset = CGPointMake(0, self.heih>refreshHeih?-refreshHeih:-self.heih);
    }completion:^(BOOL finished) {

        if (self.heih < refreshHeih) {
            [self beginRefresh1];
        }
        else{
            [self refresh];
        }
    }];
}

#pragma mark - 结束刷新
- (void)endRefreshing
{
    if(self.isRefreshing == 1){
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        __weak typeof(self) wSelf = self;
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            wSelf.state = lhRefreshStateNormal;
            
            [wSelf endRefresh1];
        });
    }
}

- (void)endRefresh1
{
    
    [UIView animateWithDuration:0.0005 animations:^{
        self.heih -= 8;

        _scrollView.contentOffset = CGPointMake(0, -self.heih>0?0:-self.heih);
    }completion:^(BOOL finished) {
        if (self.heih > 0) {
            [self endRefresh1];
        }
        else{
            UIEdgeInsets inset = _scrollView.contentInset;
            inset.top = 0;
            _scrollView.contentInset = inset;
            
            _scrollView.contentOffset = CGPointMake(0, 0);
        }
    }];
}

#pragma mark - 更新动图和状态字frame
- (void)updateGifAndStatusFrame
{
    CGRect statusRect = _sLabel.frame;
    statusRect.origin.y = CGRectGetHeight(self.bounds)-25;
    _sLabel.frame = statusRect;
    
    CGRect imgRect = _refreshImgView.frame;
    imgRect.origin.y = statusRect.origin.y-50;
    _refreshImgView.frame = imgRect;
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    
}

@end

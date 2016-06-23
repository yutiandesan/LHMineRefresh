//
//  UIScrollView+lhMineRefresh.m
//  SCFinance
//
//  Created by bosheng on 16/6/20.
//  Copyright © 2016年 liuhuan. All rights reserved.
//

#import "UIScrollView+lhMineRefresh.h"
#import "lhRefreshView.h"
#import <objc/runtime.h>

@interface UIScrollView()
@property (weak, nonatomic)lhRefreshView *header;

@end

@implementation UIScrollView (lhMineRefresh)

#pragma mark - 运行时相关
static char lhRefreshViewKey;

- (void)setHeader:(lhRefreshView *)header {

    objc_setAssociatedObject(self, &lhRefreshViewKey,
                             header,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (lhRefreshView *)header {
    return objc_getAssociatedObject(self, &lhRefreshViewKey);
}

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addHeaderWithTarget:(id)target action:(SEL)action
{
    // 1.创建新的header
    if (!self.header) {
        lhRefreshView *header = [[lhRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)];
        header.backgroundColor = self.backgroundColor;
        [self.superview addSubview:header];
        
        header.scrollView = self;
        
        self.header = header;
    }
    
    // 2.设置目标和回调方法
    self.header.beginRefreshingTaget = target;
    self.header.beginRefreshingAction = action;
}

/**
 *  主动让下拉刷新头部控件进入刷新状态
 */
- (void)headerBeginRefreshing
{
    [self.header beginRefreshing];
}

/**
 *  让下拉刷新头部控件停止刷新状态
 */
- (void)headerEndRefreshing
{
    [self.header endRefreshing];
}

@end

//
//  lhRefreshView.h
//  SCFinance
//
//  Created by bosheng on 16/6/20.
//  Copyright © 2016年 liuhuan. All rights reserved.
//

#import <UIKit/UIKit.h>

//刷新状态
typedef NS_ENUM(NSUInteger) {
    lhRefreshStateNormal = 1,
    lhRefreshStateWillRefreshing,
    lhRefreshStateRefreshing
}lhRefreshState;

const static CGFloat refreshHeih = 90.0;//松开即可刷新的高度
const static CGFloat totalHeih = 100.0;//最大高度

@interface lhRefreshView : UIView

#pragma mark - 父控件
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic,strong)UIImageView * refreshImgView;//动图
@property (nonatomic,strong)UILabel * sLabel;//状态显示

@property (nonatomic,assign)CGFloat heih;//当前scrollView偏移量取反，即self高度

@property (nonatomic,assign)CGFloat refreshOriginY;//刷新时Y值
@property (nonatomic,assign)lhRefreshState state;

@property (nonatomic,assign)NSInteger isRefreshing;//0表示未刷新，1表示正在刷新，2表示正在刷新时，手动拖动至普通状态

#pragma mark - 回调
/**
 *  开始进入刷新状态的监听器
 */
@property (weak, nonatomic) id beginRefreshingTaget;
/**
 *  开始进入刷新状态的监听方法
 */
@property (assign, nonatomic) SEL beginRefreshingAction;

/**
 *  开始刷新
 */
- (void)beginRefreshing;
/**
 *  结束刷新
 */
- (void)endRefreshing;

@end

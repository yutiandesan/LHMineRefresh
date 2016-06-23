//
//  ViewController.m
//  LHRefresh
//
//  Created by bosheng on 16/6/21.
//  Copyright © 2016年 liuhuan. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+lhMineRefresh.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * refreshTableView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    refreshTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    refreshTableView.showsVerticalScrollIndicator = NO;
    refreshTableView.delegate = self;
    refreshTableView.dataSource = self;
    refreshTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:refreshTableView];
    
    [refreshTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    
    
//    [refreshTableView headerBeginRefreshing];//手动调用下拉刷新

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 下拉刷新
- (void)headerRefresh
{
    NSLog(@"刷新...");
    
    [refreshTableView headerEndRefreshing];

}

#pragma mark - UITabelViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * tifier = @"rCell";
    
    UITableViewCell * rCell = [tableView dequeueReusableCellWithIdentifier:tifier];
    
    if (rCell == nil) {
        rCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tifier];
    }
    
    rCell.textLabel.text = [NSString stringWithFormat:@"string%ld",(long)indexPath.row];
    
    return rCell;
}


@end

//
//  YHBaseViewController.m
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import "YHBaseViewController.h"

@interface YHBaseViewController ()

@end

@implementation YHBaseViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_configBaseData];
}

-(void)p_configBaseData{
    self.view.backgroundColor = [UIColor whiteColor];
}


-(void)setupTableViewWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self.tableView = [[UITableView alloc]initWithFrame:frame
                                             style:style];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

@end

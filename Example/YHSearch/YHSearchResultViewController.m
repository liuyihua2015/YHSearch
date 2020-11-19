//
//  YHSearchResultViewController.m
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/19.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import "YHSearchResultViewController.h"

@interface YHSearchResultViewController ()

@end

@implementation YHSearchResultViewController


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = YES;

    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * button = [[UIButton alloc]init];
    [button setTitle:@"back" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(searchClick) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(100, 100, 100, 50);
    
    [self.view addSubview:button];
    
}
-(void)searchClick{
    
    [self.navigationController popViewControllerAnimated:NO];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

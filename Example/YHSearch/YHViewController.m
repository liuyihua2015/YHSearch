//
//  YHViewController.m
//  YHSearch
//
//  Created by liuyihua2015@sina.com on 11/18/2020.
//  Copyright (c) 2020 liuyihua2015@sina.com. All rights reserved.
//

#import "YHViewController.h"
#import "YHSearch.h"
#import "YHSearchResultViewController.h"
#import "YHExampleSearchViewController.h"

@interface YHViewController ()

@end

@implementation YHViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIButton * button = [[UIButton alloc]init];
    [button setTitle:@"search" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(searchClick) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(100, 100, 100, 50);
    
    [self.view addSubview:button];
    
}
-(void)searchClick{
    
    NSLog(@"搜索按钮点击");
    
//    YHSearchViewController *searchViewController = [YHSearchViewController searchViewControllerWithHotSearches:@[@"热门词1",@"热门词2",@"热门词3",@"热门词4",@"热门词5",@"热门词6"] searchTextFieldPlaceholder:@"搜索你的内容" didSearchBlock:^(YHSearchViewController *searchViewController, UITextField *searchTextField, NSString *searchText) {
//
//        NSLog(@"%@",searchText);
//
//        YHSearchResultViewController * vc = [[YHSearchResultViewController alloc]init];
//        vc.title = searchText;
//        vc.view.backgroundColor = [UIColor whiteColor];
//        [self.navigationController pushViewController:vc animated:NO];
//
//    }];
    
    //创建子控制器
    YHExampleSearchViewController *searchViewController = [YHExampleSearchViewController searchViewControllerWithHotSearches:@[@"热门词1",@"热门词2",@"热门词3",@"热门词4",@"热门词5",@"热门词6热门词6热门词6??"] searchTextFieldPlaceholder:@"搜索你的内容" didSearchBlock:^(YHSearchViewController *searchViewController, UITextField *searchTextField, NSString *searchText) {
        
        NSLog(@"%@",searchText);
        
        YHSearchResultViewController * vc = [[YHSearchResultViewController alloc]init];
        vc.title = searchText;
        vc.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:vc animated:NO];
        
    }];
    
    //tag设置属性修改（可选）
    YHSearchTagConfigure * configure = searchViewController.searchTagConfigure;
    configure.tagTextDisplayLength = 10;
    configure.tagHotImageDisplayLength = 3;
    
//    configure.tagHotImage = [UIImage imageNamed:@"hot"];
//    configure.tagHotImage = [UIImage imageNamed:@""];
//    configure.tagBorderColor = [UIColor redColor];
//    configure.tagBorderWidth = 1;
//    configure.tagCornerRadius = 10;
//    configure.tagFont = [UIFont systemFontOfSize:12];
//    configure.tagTitleColor = [UIColor blackColor];
//    configure.tagBackgroundColor = [UIColor whiteColor];
//
    searchViewController.searchTagConfigure = configure;
    
    //位置设置
    searchViewController.hotSearchPositionIsUp = NO;

    //标题和按钮设置
    searchViewController.searchHistoryHeader.yh_width = 200;
    searchViewController.searchHistoryHeader.font = [UIFont systemFontOfSize:15];
    searchViewController.searchHistoryHeader.textColor = [UIColor yh_colorWithHexString:@"#333333"];
    
    searchViewController.hotSearchHeader.yh_width = 200;
    searchViewController.hotSearchHeader.font = [UIFont systemFontOfSize:15];
    searchViewController.hotSearchHeader.textColor = [UIColor yh_colorWithHexString:@"#333333"];

   [self.navigationController pushViewController:searchViewController animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

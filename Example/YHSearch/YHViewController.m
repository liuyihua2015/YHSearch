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

@interface YHViewController ()<YHSearchViewControllerDelegate>

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

    NSMutableArray * arrM = [NSMutableArray array];
//
//    for (int i = 0; i<10; i++) {
//
//        YHSearchHotWordsModel * model = [[YHSearchHotWordsModel alloc]init];
//        model.title = [NSString stringWithFormat:@"热么词%d",i];
//        if (i < 5) {
//            model.isShowHot = YES;
//        }
//        [arrM addObject:model];
//    }
    
    
    //创建子控制器
    YHExampleSearchViewController *searchViewController = [YHExampleSearchViewController searchViewControllerWithHotSearches:arrM searchTextFieldPlaceholder:@"搜索你的内容" didSearchBlock:^(YHSearchViewController *searchViewController, UITextField *searchTextField, NSString *searchText) {
        
        NSLog(@"%@",searchText);
        
        YHSearchResultViewController * vc = [[YHSearchResultViewController alloc]init];
        vc.title = searchText;
        vc.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:vc animated:NO];
        
    }];
    

    //tag设置属性修改（可选）
    YHSearchTagConfigure * configure = searchViewController.searchTagConfigure;
    configure.historytTagTextDisplayLength = 10;
    
//    configure.tagHotImage = [UIImage imageNamed:@"hot"];
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

    //个数不做控制
    searchViewController.searchHistoriesCount = 99;

    //标题和按钮设置
    searchViewController.searchHistoryHeader.yh_width = 200;
    searchViewController.searchHistoryHeader.font = [UIFont systemFontOfSize:15];
    searchViewController.searchHistoryHeader.textColor = [UIColor blackColor];
    
    searchViewController.hotSearchHeader.yh_width = 200;
    searchViewController.hotSearchHeader.font = [UIFont systemFontOfSize:15];
    searchViewController.hotSearchHeader.textColor = [UIColor blackColor];
    
    
    searchViewController.delegate = self;
    
    
   [self.navigationController pushViewController:searchViewController animated:NO];
    
}

#pragma mark - YHSearchViewControllerDelegate
- (void)searchViewController:(YHSearchViewController *)searchViewController
         searchTextDidChange:(UITextField *)searchTextField
                  searchText:(NSString *)searchText{
    
    if (searchText.length) {
        // Simulate a send request to get a search suggestions
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMutableArray *searchSuggestionsM = [NSMutableArray array];
            for (int i = 0; i < arc4random_uniform(5) + 10; i++) {
                NSString *searchSuggestion = [NSString stringWithFormat:@"%@-%d", searchText,i];
                [searchSuggestionsM addObject:searchSuggestion];
            }
            // Refresh and display the search suggustions
            searchViewController.searchSuggestions = searchSuggestionsM;
        });
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

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
#import "SearchNavigationBarView.h"

@interface YHViewController ()<YHSearchViewControllerDelegate,SearchNavigaitonBarViewDelegate>
@property (nonatomic, strong) YHExampleSearchViewController *searchVC;
@property (nonatomic, strong) SearchNavigationBarView * searchNavView;

@end

@implementation YHViewController


//MARK: - Initializers
- (SearchNavigationBarView *)searchNavView{
    if (!_searchNavView) {
        _searchNavView = [[SearchNavigationBarView alloc]init];
        _searchNavView.backgroundColor = UIColor.redColor;
        _searchNavView.delegate = self;
    }
    return _searchNavView;
}

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
    YHExampleSearchViewController *searchViewController = [YHExampleSearchViewController searchViewControllerWithHotSearches:arrM
                                                                                                  searchTextFieldPlaceholder:@"搜索你的内容"
                                                                                                                    delegate:self
                                                                                                              didSearchBlock:^(YHSearchViewController *searchViewController, UITextField *searchTextField, NSString *searchText) {
        
        NSLog(@"结果页搜索 -- %@",searchText);
        
        YHSearchResultViewController * vc = [[YHSearchResultViewController alloc]init];
        vc.title = searchText;
        vc.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:vc animated:NO];
        
    }];

    searchViewController.delegate = self;
    
    //位置设置
    searchViewController.hotSearchPositionIsUp = NO;
    //样式设置
    searchViewController.hotSearchStyle = YHHotSearchStyleCell;
//    searchViewController.searchHistoryStyle = YHSearchHistoryStyleCell;
    
    //headerView 高度配置
//    searchViewController.hotSearchHeaderLabelLeft = 8;
//    searchViewController.historySearchHeaderLabelLeft = 8;
//    searchViewController.hotSearchHeaderViewHeight = 100;
//    searchViewController.historySearchHeaderViewHeight = 100;
   
    
    //热门搜索外边框设置
    searchViewController.hotSearchView.layer.borderColor = [UIColor colorWithRed:255/255.0 green:224/255.0 blue:228/255.0 alpha:1.0].CGColor;
    searchViewController.hotSearchView.layer.cornerRadius = 16;
    searchViewController.hotSearchView.layer.borderWidth = 1;
    searchViewController.hotSearchView.clipsToBounds = YES;
    
    //tag设置属性修改（可选）
    YHSearchTagConfigure * configure = searchViewController.searchTagConfigure;
    configure.historytTagTextDisplayLength = 10;
    
//    configure.emptyBtnStyle = EmptyBtnStyleTitle;
//    configure.searchHistoryDeleteTitle = @"删除";
    
//    configure.tagHeight = 44;
//    configure.tagLeftMargin = 8;
//    configure.tagLeftPanding = 0;
    
//    configure.tagBorderColor = [UIColor redColor];
//    configure.tagBorderWidth = 1;
//    configure.tagCornerRadius = 10;
//    configure.tagFont = [UIFont systemFontOfSize:12];
//    configure.tagTitleColor = [UIColor blackColor];
//    configure.tagBackgroundColor = [UIColor whiteColor];
//
    searchViewController.searchTagConfigure = configure;
    


    //个数不做控制
    searchViewController.searchHistoriesShowCount = 10;

    //标题和按钮设置
//    searchViewController.searchHistoryHeader.yh_width = 200;
//    searchViewController.searchHistoryHeader.font = [UIFont systemFontOfSize:15];
//    searchViewController.searchHistoryHeader.textColor = [UIColor blackColor];
    
//    searchViewController.hotSearchHeader.yh_width = 200;
//    searchViewController.hotSearchHeader.font = [UIFont systemFontOfSize:15];
//    searchViewController.hotSearchHeader.textColor = [UIColor blackColor];
    
    
    
   [self.navigationController pushViewController:searchViewController animated:YES];
    
    self.searchVC = searchViewController;
    
    [self.searchNavView searchBecomeFirstResponder];
    
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

- (BOOL)searchViewController:(YHSearchViewController *)searchViewController didSelectSearchSuggestionAtIndexPath:(NSIndexPath *)indexPath
                  searchText:(NSString *)searchText {
    self.searchNavView.searchTextField.text = searchText;
    return NO;
}

- (BOOL)searchViewController:(YHSearchViewController *)searchViewController didSelectHotSearchAtIndex:(NSInteger)index
                  searchText:(NSString *)searchText {
    self.searchNavView.searchTextField.text = searchText;
    return NO;
}


- (BOOL)searchViewController:(YHSearchViewController *)searchViewController didSelectSearchHistoryAtIndex:(NSInteger)index
                  searchText:(NSString *)searchText {
    self.searchNavView.searchTextField.text = searchText;
    return NO;
}
/// 自定义导航栏获取键盘焦点
- (void)customNavBarBecomeFirstResponder {
    [self.searchNavView searchBecomeFirstResponder];
}

/// 自定义导航栏
- (UIView *)customSearchNavigationBar {
    return self.searchNavView;
}

- (UIView *)customHotHeaderView {
    UIView * haederView = [[UIView alloc]init];
    
    //添加图片
    UIImageView * imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"icon_fire_ch"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [haederView addSubview:imageView];
    imageView.yh_y = 10;
    imageView.yh_x = 8;
    imageView.yh_size = CGSizeMake(105, 24);
    return haederView;
}

- (UIView *)customHotTagView {
    UIView * hotView = [[UIView alloc]init];
    return hotView;
}

- (UIView *)customHistoryTagView {
    UIView * historyView = [[UIView alloc]init];
    return historyView;
}

- (void)getCustomTagView:(UIView *)view title:(NSString *)title index:(NSInteger)index isHot:(BOOL)isHot {

    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.userInteractionEnabled = NO;
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [view addSubview:btn];
    [btn sizeToFit];
    btn.yh_width += 20;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickCancelButtonForSearchNavigaitonBarView:(nonnull SearchNavigationBarView *)searchNavigaitonBarView {
    self.searchNavView.searchTextField.text = @"";
    [self.navigationController popViewControllerAnimated:true];
}

/// TextField开始编辑
/// @param textField textField
-(BOOL)searchNavigaitonBarViewByTextFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

/// TextField监听键盘的输入
/// @param textField textField
-(void)searchNavigaitonBarViewByTextFieldDidChange:(UITextField *)textField {
    
    [self.searchVC searchNavigationBarSearchText:textField.text];
}

/// 开始搜索
/// @param textField textField
-(BOOL)searchNavigaitonBarViewByTextFieldShouldReturn:(UITextField *)textField {
    
    [self.searchVC searchNavigationBarStartSearch:textField.text];
    
    return YES;
}

/// TextField 清空
/// @param textField textField
-(BOOL)searchNavigaitonBarViewByTextFieldShouldClear:(UITextField *)textField {
    
    [self.searchVC searchNavigationBarClearText];
    
    return YES;
    
}



@end

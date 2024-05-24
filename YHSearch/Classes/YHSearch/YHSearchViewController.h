//
//  YHSearchViewController.h
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHSearchConst.h"
#import "YHBaseViewController.h"

@class YHSearchViewController;

typedef void(^PYDidSearchBlock)(YHSearchViewController *searchViewController, UITextField *searchTextField, NSString *searchText);

/**
 style of popular search
 */
typedef NS_ENUM(NSInteger, YHHotSearchStyle)  {
    YHHotSearchStyleNormalTag,
    YHHotSearchStyleCell,
    YHHotSearchStyleDefault = YHHotSearchStyleNormalTag // default is `YHHotSearchStyleNormalTag`
};

/**
 style of search history
 */
typedef NS_ENUM(NSInteger, YHSearchHistoryStyle) {
    YHSearchHistoryStyleNormalTag,
    YHSearchHistoryStyleCell,
    YHSearchHistoryStyleDefault = YHSearchHistoryStyleNormalTag // default is `YHSearchHistoryStyleNormalTag`
};


/**
 The protocol of delegate
 */
@protocol YHSearchViewControllerDelegate <NSObject, UITableViewDelegate>

@optional

/**
 搜索开始代理事件--回调后跳转至结果页面 与 PYDidSearchBlock 二选一 优先代理

 @param searchViewController    search view controller
 @param searchTextField               searchTextField
 @param searchText              text for search
 */
- (void)searchViewController:(YHSearchViewController *)searchViewController
didSearchWithSearchTextField:(UITextField *)searchTextField
                  searchText:(NSString *)searchText;

/**
 当热门搜索被选择时调用

 @param searchViewController    search view controller
 @param index                   index of tag
 @param searchText              text for search
 @return YES or NO              是否拦截显示建议数据视图,默认NO
 
 Note: `searchViewController:didSearchWithSearchTextField:searchText:` will not be called when this method is implemented.
 */
- (BOOL)searchViewController:(YHSearchViewController *)searchViewController 
   didSelectHotSearchAtIndex:(NSInteger)index
                  searchText:(NSString *)searchText;

/**
 当搜索历史记录被选中时调用

 @param searchViewController    search view controller
 @param index                   index of tag or row
 @param searchText              text for search
 @return YES or NO              是否拦截显示建议数据视图,默认NO
 
 Note: `searchViewController:didSearchWithSearchTextField:searchText:` will not be called when this method is implemented.
 */
- (BOOL)searchViewController:(YHSearchViewController *)searchViewController didSelectSearchHistoryAtIndex:(NSInteger)index
                  searchText:(NSString *)searchText;

/**
 当搜索文本发生变化时调用了该方法，您可以通过此方法重新加载（联系词建议）视图数据。

 @param searchViewController    search view controller
 @param searchTextField               searchTextField
 @param searchText              text for search
 */
- (void)searchViewController:(YHSearchViewController *)searchViewController
         searchTextDidChange:(UITextField *)searchTextField
                  searchText:(NSString *)searchText;

/**
 联系词建议视图数据cell点击

 @param searchViewController    search view controller
 @param indexPath               indexPath
 @param searchText              text for search
 @return YES or NO              是否拦截显示建议数据视图,默认NO
 
 Note: `searchViewController:didSearchWithSearchTextField:searchText:` will not be called when this method is implemented.

 */
- (BOOL)searchViewController:(YHSearchViewController *)searchViewController didSelectSearchSuggestionAtIndexPath:(NSIndexPath *)indexPath
                  searchText:(NSString *)searchText;

/**
 返回项目按下时调用, 默认执行 `[self.navigationController popViewControllerAnimated:YES]`.
 
 @param searchViewController search view controller
 */
- (void)didClickBack:(YHSearchViewController *)searchViewController;


/// 自定义导航栏
- (UIView *)customSearchNavigationBar;

/// 自定义导航栏获取键盘焦点
- (void)customNavBarBecomeFirstResponder;

/// 自定义热门搜索HeaderView StyleCell 有效
- (UIView *)customHotHeaderView;

/// 自定义热门搜索tagView StyleCell 有效
- (UIView *)customHotTagView;

/// 自定义历史搜索tagView
- (UIView *)customHistoryTagView;

/// 返回自定义热门搜索的tagView和内容 仅支持自定义TagView时有值
/// - Parameters:
///   - view: 自定义
///   - title: title
///   - index: index
///   - isHot: 是否是热门
- (void)getCustomTagView:(UIView *)view title:(NSString *)title index:(NSInteger)index isHot:(BOOL)isHot;


@end

@interface YHSearchViewController : YHBaseViewController

/**
 The delegate
 */
@property (nonatomic, weak) id<YHSearchViewControllerDelegate> delegate;

@property (nonatomic, assign) YHHotSearchStyle hotSearchStyle;

@property (nonatomic, assign) YHSearchHistoryStyle searchHistoryStyle;

/**
 搜索建议元素
 
 Note: 当“searchSuggestionHidden是NO或建议视图的单元格是自定义时，它是无效的。
 */
@property (nonatomic, copy) NSArray<NSString *> *searchSuggestions;

/**
 是否隐藏搜索建议视图，默认为NO。
 */
@property (nonatomic, assign) BOOL searchSuggestionHidden;

/**
 热门搜索 View
 */
@property (nonatomic, strong) UIView *hotSearchView;

/**
 历史搜索 View
 */
@property (nonatomic, strong) UIView *historySearchView;

/**
 热门搜索
 */
@property (nonatomic, strong) NSArray<NSString *> *hotSearches;

/**
 热门搜索的标签
 */
@property (nonatomic, strong) NSArray<UIView *> *hotSearchTags;

/**
 热门搜索的标签HeaderView
 */
@property (nonatomic, strong) UIView *hotSearchHeaderView;

/**
 热门搜索的标签Label
 */
@property (nonatomic, strong) UILabel *hotSearchLabel;

/**
 是否显示热门搜索，默认为YES.
 */
@property (nonatomic, assign) BOOL showHotSearch;


/**
 搜索历史的标签数组
 */
@property (nonatomic, strong) NSArray<UIView *> *searchHistoryTags;

/**
 搜索历史的标签HeaderView
 */
@property (nonatomic, strong) UIView *historySearchHeaderView;

/**
 搜索历史的标签 Label
 */
@property (nonatomic, strong) UILabel *historySearchLabel;


/**
 热门搜索的HeaderView的高度,默认44
 */
@property (nonatomic, assign) int hotSearchHeaderViewHeight;

/**
 搜索历史的HeaderView的高度,默认44
 */
@property (nonatomic, assign) int historySearchHeaderViewHeight;

/**
 热门搜索的标题左边间距,默认0 自定义时无效
 */
@property (nonatomic, assign) int hotSearchHeaderLabelLeft;

/**
 搜索历史的标题左边间距,默认0 自定义时无效
 */
@property (nonatomic, assign) int historySearchHeaderLabelLeft;


/**
 是否显示搜索历史，默认为YES.
 
 注意:当搜索记录为NO时，它不会缓存。
 */
@property (nonatomic, assign) BOOL showSearchHistory;

/**
 一般默认 缓存搜索记录的路径, default is `YHSEARCH_SEARCH_HISTORY_CACHE_PATH`.
 */
@property (nonatomic, copy) NSString *searchHistoriesCachePath;

/**
 展示的搜索记录的数量，默认为10条.
 */
@property (nonatomic, assign) NSUInteger searchHistoriesShowCount;

/**
 是否删除搜索字符串的空格，默认为YES.
 */
@property (nonatomic, assign) BOOL removeSpaceOnSearchString;

/**
 热门搜索是否在上面，默认为YES
 */
@property (nonatomic, assign) BOOL hotSearchPositionIsUp;


/**
 空搜索记录的按钮.
 */
@property (nonatomic, strong) UIButton *emptyButton;

/**
 搜索开始时调用的block.
 */
@property (nonatomic, copy) PYDidSearchBlock didSearchBlock;


/**
 返回搜索结果时是否显示键盘，默认为YES。
 */
@property (nonatomic, assign) BOOL showKeyboardWhenReturnSearchResult;

/**
 搜索标签配置属性
 */
@property (nonatomic, strong) YHSearchTagConfigure * searchTagConfigure;

/**
 取消按钮点击是否动画,默认NO
 */
@property (nonatomic, assign) BOOL cancelClickAnimated;

/**
 用热门搜索和搜索栏的占位符创建searchViewContoller实例。

 @param hotSearches     popular searchs
 @param placeholder     placeholder of search bar
 @return new instance of `YHSearchViewController` class
 */
+ (instancetype)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches
                         searchTextFieldPlaceholder:(NSString *)placeholder
                                           delegate:(id<YHSearchViewControllerDelegate>)delegate;

/**
 创建searchViewContoller的一个实例，包含热门搜索、搜索栏的占位符和搜索开始时调用的块。

 @param hotSearches     popular searchs
 @param placeholder     placeholder of search bar
 @param block           block which invoked when search begain
 @return new instance of `YHSearchViewController` class
 
 注意:' delegate '的优先级大于' block '，当' searchViewController:didSearchWithSearchTextField:searchText: '被实现时' block '是无效的。
 */
+ (instancetype)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches
                         searchTextFieldPlaceholder:(NSString *)placeholder
                                           delegate:(id<YHSearchViewControllerDelegate>)delegate
                                     didSearchBlock:(PYDidSearchBlock)block;

/// 为满足自定义导航栏对外提供的的几个方法
/// 1.文本输入值,实时变化
-(void)searchNavigationBarSearchText:(NSString *)searchText;
/// 2.清空文本功能
-(void)searchNavigationBarClearText;
/// 3.搜索功能
-(void)searchNavigationBarStartSearch:(NSString *)searchText;

@end

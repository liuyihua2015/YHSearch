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
#import "YHSearchHotWordsModel.h"

@class YHSearchViewController;

typedef void(^PYDidSearchBlock)(YHSearchViewController *searchViewController, UITextField *searchTextField, NSString *searchText);


/**
 The protocol of delegate
 */
@protocol YHSearchViewControllerDelegate <NSObject, UITableViewDelegate>

@optional

/**
 搜索开始代理事件

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
 
 Note: `searchViewController:didSearchWithSearchTextField:searchText:` will not be called when this method is implemented.
 */
- (void)searchViewController:(YHSearchViewController *)searchViewController
   didSelectHotSearchAtIndex:(NSInteger)index
                  searchText:(NSString *)searchText;

/**
 当搜索历史记录被选中时调用

 @param searchViewController    search view controller
 @param index                   index of tag or row
 @param searchText              text for search
 
 Note: `searchViewController:didSearchWithSearchTextField:searchText:` will not be called when this method is implemented.
 */
- (void)searchViewController:(YHSearchViewController *)searchViewController
didSelectSearchHistoryAtIndex:(NSInteger)index
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
 */
- (void)searchViewController:(YHSearchViewController *)searchViewController didSelectSearchSuggestionAtIndexPath:(NSIndexPath *)indexPath
                  searchText:(NSString *)searchText;

/**
 返回项目按下时调用, 默认执行 `[self.navigationController popViewControllerAnimated:YES]`.
 
 @param searchViewController search view controller
 */
- (void)didClickBack:(YHSearchViewController *)searchViewController;

@end

@interface YHSearchViewController : YHBaseViewController

/**
 The delegate
 */
@property (nonatomic, weak) id<YHSearchViewControllerDelegate> delegate;



/**
 The element of search suggestions
 
 Note: it is't effective when `searchSuggestionHidden` is NO or cell of suggestion view is custom.
 */
@property (nonatomic, copy) NSArray<NSString *> *searchSuggestions;

/**
 Whether hidden search suggstion view, default is NO.
 */
@property (nonatomic, assign) BOOL searchSuggestionHidden;


/**
 热门搜索
 */
@property (nonatomic, copy) NSArray<YHSearchHotWordsModel *> *hotSearches;

/**
 热门搜索的标签
 */
@property (nonatomic, copy) NSArray<UIButton *> *hotSearchTags;

/**
 热门搜索的标签Header
 */
@property (nonatomic, weak) UILabel *hotSearchHeader;

/**
 是否显示热门搜索，默认为YES.
 */
@property (nonatomic, assign) BOOL showHotSearch;

/**
 热门搜索的标题
 */
@property (nonatomic, copy) NSString *hotSearchTitle;

/**
 搜索历史的标签数组
 */
@property (nonatomic, copy) NSArray<UIButton *> *searchHistoryTags;

/**
 搜索历史的标签 Header
 */
@property (nonatomic, weak) UILabel *searchHistoryHeader;

/**
 搜索历史的标题
 */
@property (nonatomic, copy) NSString *searchHistoryTitle;

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
 缓存搜索记录的数量，默认为10条.
 */
@property (nonatomic, assign) NSUInteger searchHistoriesCount;

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
@property (nonatomic, weak) UIButton *emptyButton;

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
 用热门搜索和搜索栏的占位符创建searchViewContoller实例。

 @param hotSearches     popular searchs
 @param placeholder     placeholder of search bar
 @return new instance of `YHSearchViewController` class
 */
+ (instancetype)searchViewControllerWithHotSearches:(NSArray<YHSearchHotWordsModel *> *)hotSearches
                               searchTextFieldPlaceholder:(NSString *)placeholder;

/**
 创建searchViewContoller的一个实例，包含热门搜索、搜索栏的占位符和搜索开始时调用的块。

 @param hotSearches     popular searchs
 @param placeholder     placeholder of search bar
 @param block           block which invoked when search begain
 @return new instance of `YHSearchViewController` class
 
 注意:' delegate '的优先级大于' block '，当' searchViewController:didSearchWithSearchTextField:searchText: '被实现时' block '是无效的。
 */
+ (instancetype)searchViewControllerWithHotSearches:(NSArray<YHSearchHotWordsModel *> *)hotSearches
                               searchTextFieldPlaceholder:(NSString *)placeholder
                                     didSearchBlock:(PYDidSearchBlock)block;

@end

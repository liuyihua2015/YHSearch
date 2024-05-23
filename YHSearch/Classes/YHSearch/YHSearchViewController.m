//
//  YHSearchViewController.m
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import "YHSearchViewController.h"
#import "YHSearchConst.h"
#import "YHSearchNavigationBarView.h"
#import "YHSearchSuggestionViewController.h"

#define PYTextColor YHSEARCH_COLOR(113, 113, 113)

#define YHMethodParameterError() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"You must used NSArray<YHSearchHotWordsModel *> In the %@ ", NSStringFromSelector(_cmd)] \
                                 userInfo:nil]


@interface YHSearchViewController () <PPSearchNavigaitonBarViewDelegate,YHSearchSuggestionViewDataSource>

/**
 搜索导航栏 View
 */
@property(nonatomic,strong)YHSearchNavigationBarView * searchNavigaitonBarView;

/**
 搜索header View
 */
@property (nonatomic, strong) UIView *headerView;


/**
 搜索历史数组
 */
@property (nonatomic, strong) NSMutableArray *searchHistories;

/**
 是否显示键盘。
 */
@property (nonatomic, assign) BOOL keyboardShowing;

/**
 keyborad的高度
 */
@property (nonatomic, assign) CGFloat keyboardHeight;

/**
 热门搜索标签的内容视图
 */
@property (nonatomic, strong) UIView *hotSearchTagsContentView;

/**
 搜索历史标签的内容视图
 */
@property (nonatomic, strong) UIView *searchHistoryTagsContentView;

/**
 搜索框 Placeholder
 */
@property (copy   , nonatomic) NSString * kSearchTextFieldPlaceholder;

/**
 搜索建议视图控制器
 */
@property (nonatomic, weak) YHSearchSuggestionViewController *searchSuggestionVC;

/**
 搜索建议视图 tableView
 */
@property (nonatomic, weak, readonly) UITableView *searchSuggestionView;


@end

@implementation YHSearchViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.hotSearchHeaderViewHeight = 44;
        self.historySearchHeaderViewHeight = 44;
        
        YHSearchTagConfigure * configure = [[YHSearchTagConfigure alloc]init];
        configure.historytTagTextDisplayLength = 0;
     
        configure.tagLeftMargin = 8;
        configure.tagHeight = 32;
        configure.tagLeftPanding = 20;
        configure.tagBorderColor = [UIColor clearColor];
        configure.tagBorderWidth = 0;
        configure.tagCornerRadius = 5;
        configure.tagFont = [UIFont systemFontOfSize:12];
        configure.tagTitleColor = [UIColor yh_colorWithHexString:@"#999999"];
        configure.tagBackgroundColor = [UIColor yh_colorWithHexString:@"#F9F9F9"];
        
        configure.emptyBtnStyle = EmptyBtnStyleDefault;
        configure.searchHistoryDeleteImage = [NSBundle yh_imageNamed:@"empty"];
        configure.searchHistoryItemDeleteImage= [NSBundle yh_imageNamed:@"delete"];
        
        self.searchTagConfigure = configure;

        [self setup];
    }
    return self;
}


- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)fd_interactivePopDisabled {
    
    return YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    if (YES == self.showKeyboardWhenReturnSearchResult) {
        [self.searchNavigaitonBarView searchBecomeFirstResponder];
        if(_delegate && [_delegate respondsToSelector:@selector(customNavBarBecomeFirstResponder)]) {
            [_delegate customNavBarBecomeFirstResponder];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupHistorySearchNormalTags];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
   
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches 
                         searchTextFieldPlaceholder:(NSString *)placeholder
                                           delegate:(id<YHSearchViewControllerDelegate>)delegate
{
    YHSearchViewController *searchVC = [[self alloc] init];
    searchVC.hotSearches = hotSearches;
    searchVC.kSearchTextFieldPlaceholder = placeholder;
    searchVC.searchNavigaitonBarView.searchTextField.placeholder = placeholder;
    searchVC.delegate = delegate;
    [searchVC setupCustomViews];
    return searchVC;
}

+ (instancetype)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches 
                         searchTextFieldPlaceholder:(NSString *)placeholder
                                           delegate:(id<YHSearchViewControllerDelegate>)delegate
                                     didSearchBlock:(PYDidSearchBlock)block
{
    [hotSearches enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            YHMethodParameterError();
            *stop = YES;
        }
    }];
    
    YHSearchViewController *searchVC = [self searchViewControllerWithHotSearches:hotSearches searchTextFieldPlaceholder:placeholder delegate:delegate];
    searchVC.didSearchBlock = [block copy];
    return searchVC;
}


//MARK: - setupUI
- (void)setup
{
    self.navigationController.navigationBar.backIndicatorImage = nil;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.searchNavigaitonBarView];
    [self setupTableViewWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.searchNavigaitonBarView.frame), YHScreenW, YHScreenH - YH_NavgationFullHeight);
    self.tableView.tableFooterView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] init];;
    
    //基础配置
    self.searchHistoriesCachePath = YHSEARCH_SEARCH_HISTORY_CACHE_PATH;
    self.searchHistoriesShowCount = 10;
    self.showSearchHistory = YES;
    self.showHotSearch = YES;
    self.hotSearchPositionIsUp = YES;
    self.showKeyboardWhenReturnSearchResult = YES;
    self.removeSpaceOnSearchString = YES;
    
    //热门搜索
    [self.headerView addSubview:self.hotSearchView];
    [self.hotSearchView addSubview:self.hotSearchHeaderView];
    [self.hotSearchView addSubview:self.hotSearchTagsContentView];
    [self.hotSearchHeaderView addSubview:self.hotSearchLabel];
    self.hotSearches = nil;
    
    //历史搜索
    [self.headerView addSubview:self.historySearchView];
    [self.historySearchView addSubview:self.historySearchHeaderView];
    [self.historySearchHeaderView addSubview:self.historySearchLabel];
    [self.historySearchView addSubview:self.emptyButton];
    
    [self resetHotSearchHeaderViewFrame];
    [self resetHistorySearchHeaderViewFrame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

// 处理自定义热门搜索headerView
-(void)setupCustomViews {
    
    if(_delegate && [_delegate respondsToSelector:@selector(customSearchNavigationBar)]) {
        UIView *view = [self.delegate customSearchNavigationBar];
        view.frame = CGRectMake(0, 0,  self.searchNavigaitonBarView.yh_width,  self.searchNavigaitonBarView.yh_height);
        [self.view addSubview:view];
        self.searchNavigaitonBarView.alpha = 0;
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(customHotHeaderView)]) {
        UIView *view = [self.delegate customHotHeaderView];
        view.frame = CGRectMake(0, 0,  self.hotSearchHeaderView.yh_width,  self.hotSearchHeaderView.yh_height);
        [self.hotSearchView addSubview:view];
        self.hotSearchHeaderView.hidden = YES;
    }
}

//MARK: - 整个搜索视图
- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc]init];
        _headerView.yh_width = YHScreenW;
        _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _headerView;
}

//MARK: - 历史搜索视图

- (UIView *)historySearchView
{
    if (!_historySearchView) {
        _historySearchView = [[UIView alloc] init];
        _historySearchView.yh_x = self.hotSearchView.yh_x;
        _historySearchView.yh_y = self.hotSearchView.yh_y;
        _historySearchView.yh_width = self.headerView.yh_width - _historySearchView.yh_x * 2;
        _historySearchView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _historySearchView;
}

- (UIView *)historySearchHeaderView {
    if (!_historySearchHeaderView) {
        _historySearchHeaderView = [[UIView alloc]init];
       
    }
    return _historySearchHeaderView;
}

- (UILabel *)historySearchLabel {
    if (!_historySearchLabel) {
        _historySearchLabel = [self setupTitleLabel:[NSBundle yh_localizedStringForKey:YHSearchSearchHistoryText]];
    }
    return _historySearchLabel;
}


- (UIButton *)emptyButton
{
    if (!_emptyButton) {
        _emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _emptyButton.titleLabel.font = self.historySearchLabel.font;
        [_emptyButton setTitleColor:PYTextColor forState:UIControlStateNormal];
        [_emptyButton setImage:self.searchTagConfigure.searchHistoryDeleteImage forState:UIControlStateNormal];
        [_emptyButton addTarget:self action:@selector(emptySearchHistoryDidClick) forControlEvents:UIControlEventTouchUpInside];
        _emptyButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    return _emptyButton;
}

- (UIView *)searchHistoryTagsContentView
{
    if (!_searchHistoryTagsContentView) {
        _searchHistoryTagsContentView = [[UIView alloc] init];
        _searchHistoryTagsContentView.yh_width = self.historySearchView.yh_width;
        _searchHistoryTagsContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.historySearchView addSubview:_searchHistoryTagsContentView];
    }
    return _searchHistoryTagsContentView;
}



//MARK: - 热门搜索视图

- (UIView *)hotSearchView {
    if (!_hotSearchView) {
        _hotSearchView = [[UIView alloc] init];
        _hotSearchView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _hotSearchView.yh_x = YHSEARCH_MARGIN;
        _hotSearchView.yh_width = self.headerView.yh_width - self.hotSearchView.yh_x * 2;
    }
    return _hotSearchView;
}

- (UIView *)hotSearchHeaderView {
    if (!_hotSearchHeaderView) {
        _hotSearchHeaderView = [[UIView alloc]init];
    }
    return _hotSearchHeaderView;
}

- (UILabel *)hotSearchLabel {
    if (!_hotSearchLabel) {
        _hotSearchLabel = [self setupTitleLabel:[NSBundle yh_localizedStringForKey:YHSearchHotSearchText]];
    }
    return _hotSearchLabel;
}

- (UIView *)hotSearchTagsContentView {
    if (!_hotSearchTagsContentView) {
        _hotSearchTagsContentView = [[UIView alloc]init];
        _hotSearchTagsContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _hotSearchTagsContentView.yh_width = self.hotSearchView.yh_width;
    }
    return _hotSearchTagsContentView;
}



//MARK: - Initializers
- (YHSearchNavigationBarView *)searchNavigaitonBarView{
    if (!_searchNavigaitonBarView) {
        _searchNavigaitonBarView = [[YHSearchNavigationBarView alloc]initWithFrame:CGRectMake(0, 0, self.view.yh_width, YH_NavgationFullHeight)];
        _searchNavigaitonBarView.delegate = self;
    }
    return _searchNavigaitonBarView;
}

- (YHSearchSuggestionViewController *)searchSuggestionVC
{
    if (!_searchSuggestionVC) {
        YHSearchSuggestionViewController *searchSuggestionVC = [[YHSearchSuggestionViewController alloc] initWithStyle:UITableViewStyleGrouped];
        __weak typeof(self) _weakSelf = self;
        searchSuggestionVC.didSelectCellBlock = ^(UITableViewCell *didSelectCell) {
            
            __strong typeof(_weakSelf) _swSelf = _weakSelf;
            //TODO: ... 需要处理 ...
            _swSelf.searchNavigaitonBarView.searchTextField.text = didSelectCell.textLabel.text;
            NSIndexPath *indexPath = [_swSelf.searchSuggestionVC.tableView indexPathForCell:didSelectCell];
            
            if ([_swSelf.delegate respondsToSelector:@selector(searchViewController:didSelectSearchSuggestionAtIndexPath:searchText:)]) {
               BOOL isIntercept = [_swSelf.delegate searchViewController:_swSelf didSelectSearchSuggestionAtIndexPath:indexPath searchText:didSelectCell.textLabel.text];
                [_swSelf saveSearchCacheAndRefreshView:didSelectCell.textLabel.text];
                if (isIntercept) {
                    return;
                }
                [_swSelf searchNavigaitonBarViewByTextFieldShouldReturn:_swSelf.searchNavigaitonBarView.searchTextField];
            } else {
                [_swSelf searchNavigaitonBarViewByTextFieldShouldReturn:_swSelf.searchNavigaitonBarView.searchTextField];
            }
        };
        searchSuggestionVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.searchNavigaitonBarView.frame), YHScreenW, YHScreenH - CGRectGetMaxY(self.searchNavigaitonBarView.frame));
        searchSuggestionVC.view.backgroundColor = self.tableView.backgroundColor;
        searchSuggestionVC.view.hidden = YES;
        _searchSuggestionView = (UITableView *)searchSuggestionVC.view;
        searchSuggestionVC.dataSource = self;
        [self.view addSubview:searchSuggestionVC.view];
        [self addChildViewController:searchSuggestionVC];
        _searchSuggestionVC = searchSuggestionVC;
    }
    return _searchSuggestionVC;
}




- (NSMutableArray *)searchHistories
{
    if (!_searchHistories) {

         _searchHistories = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:self.searchHistoriesCachePath]];
    }
    return _searchHistories;
}

- (UILabel *)setupTitleLabel:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.tag = 1;
    titleLabel.textColor = PYTextColor;
    [titleLabel sizeToFit];
    titleLabel.yh_x = 0;
    titleLabel.yh_y = 0;
    return titleLabel;
}

//MARK: 一行多个形式cell
- (NSArray *)addAndLayoutTagsWithTagsContentView:(UIView *)contentView tagTexts:(NSArray<id> *)tagTexts isHot:(BOOL)isHot
{
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *tagsM = [NSMutableArray array];
    for (int i = 0; i < tagTexts.count; i++) {
        NSString * title = tagTexts[i];
        UIView *  view = [self createTagViewWithTitle:title tag:i isHot:isHot];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick:)];
        [view addGestureRecognizer:tap];
        
        [contentView addSubview:view];
        [tagsM addObject:view];
    }
    
    CGFloat currentX = 0;
    CGFloat currentY = 0;
    CGFloat countRow = 0;
    CGFloat countCol = 0;
    //最后一个view，用于计算整个区域高度
    UIView * lastView = nil;
    
    //显示行数控制
    int maxCount = 0;
    if (isHot) {
        maxCount = self.searchTagConfigure.searchHotMaxRows-1;
    }else{
        maxCount = self.searchTagConfigure.searchHistoryMaxRows-1;
    }
    
    for (int i = 0; i < contentView.subviews.count; i++) {
        UIButton *subView = contentView.subviews[i];
        
        //单独一行tag
        if (subView.yh_width > contentView.yh_width) {
            subView.yh_width = contentView.yh_width;
        }
        //一行的第一个tag
        if (currentX + subView.yh_width + YHSEARCH_MARGIN * countRow > contentView.yh_width) {
            subView.yh_x = self.searchTagConfigure.tagLeftMargin;
    
            countCol++;
            if ((maxCount >= 0) && (countCol > maxCount)) {
                subView.yh_y = YHSEARCH_MARGIN * 0.5;
                subView.yh_size = CGSizeZero;
            }else{
                subView.yh_y = (currentY += subView.yh_height) + YHSEARCH_MARGIN * 0.5 * countCol + YHSEARCH_MARGIN * 0.5;
                lastView = subView;
            }
            
            currentX = subView.yh_width;
            countRow = 1;
            
        } else {//其余的tag
            if ((maxCount >= 0) && (countCol > maxCount)) {
                subView.yh_x = self.searchTagConfigure.tagLeftMargin;
                subView.yh_y = YHSEARCH_MARGIN * 0.5;
                subView.yh_size = CGSizeZero;
            }else{
                subView.yh_x = (currentX += subView.yh_width) - subView.yh_width + YHSEARCH_MARGIN * countRow + self.searchTagConfigure.tagLeftMargin;
                subView.yh_y = currentY + YHSEARCH_MARGIN * 0.5 * countCol + YHSEARCH_MARGIN * 0.5;
                lastView = subView;
            }
            
            countRow ++;
           
        }
        
    }
    
        
    contentView.yh_height = CGRectGetMaxY(lastView.frame);
    if (self.hotSearchTagsContentView == contentView) { // popular search tag
        self.hotSearchView.yh_height = CGRectGetMaxY(contentView.frame) + YHSEARCH_MARGIN * 0.5;
    } else if (self.searchHistoryTagsContentView == contentView) { // search history tag
        self.historySearchView.yh_height = CGRectGetMaxY(contentView.frame) + YHSEARCH_MARGIN * 0.5;
        
    }
    
    [self layoutForDemand];
    
    CGFloat overallHeight = MAX(CGRectGetMaxY(self.hotSearchView.frame), CGRectGetMaxY(self.historySearchView.frame));
    
    self.tableView.tableHeaderView.yh_height = self.headerView.yh_height = overallHeight + YHSEARCH_MARGIN;
    self.tableView.tableHeaderView.hidden = NO;
    
    [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    return [tagsM copy];
}

//MARK: 独占一行形式cell
- (NSArray *)addAndLayoutTagsWithTagsContentView:(UIView *)contentView tagTexts:(NSArray<id> *)tagTexts isHot:(BOOL)isHot cellStyle:(BOOL)cellStyle
{
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *tagsM = [NSMutableArray array];
    for (int i = 0; i < tagTexts.count; i++) {
        NSString * title = tagTexts[i];
        UIView *  view = [self createTagViewWithTitle:title tag:i isHot:isHot];
                
        //view 添加tap点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick:)];
        [view addGestureRecognizer:tap];
        
        [contentView addSubview:view];
        [tagsM addObject:view];
    }
    

    //最后一个view，用于计算整个区域高度
    UIView * lastView = nil;
    
    for (int i = 0; i < contentView.subviews.count; i++) {
        UIView *subView = contentView.subviews[i];
        //单独一行tag
        subView.yh_width = contentView.yh_width - self.searchTagConfigure.tagLeftMargin * 2;
        subView.yh_height = self.searchTagConfigure.tagHeight;
        subView.yh_x = self.searchTagConfigure.tagLeftMargin;
        subView.yh_y = i == 0 ? YHSEARCH_MARGIN * 0.5 : CGRectGetMaxY(lastView.frame) + YHSEARCH_MARGIN * 0.5;
        lastView = subView;
    }
    
        
    contentView.yh_height = CGRectGetMaxY(lastView.frame);
    if (self.hotSearchTagsContentView == contentView) { // popular search tag
        self.hotSearchView.yh_height = CGRectGetMaxY(contentView.frame) + YHSEARCH_MARGIN * 0.5;
    } else if (self.searchHistoryTagsContentView == contentView) { // search history tag
        self.historySearchView.yh_height = CGRectGetMaxY(contentView.frame) + YHSEARCH_MARGIN * 0.5;
        
    }
    
    [self layoutForDemand];
    CGFloat overallHeight = MAX(CGRectGetMaxY(self.hotSearchView.frame), CGRectGetMaxY(self.historySearchView.frame));
    
    self.tableView.tableHeaderView.yh_height = self.headerView.yh_height = overallHeight + YHSEARCH_MARGIN;
    
    self.tableView.tableHeaderView.hidden = NO;
    
    [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    
    return [tagsM copy];
}

- (void)layoutForDemand {
    
    if (self.hotSearchPositionIsUp) {
        
        self.hotSearchView.yh_y = YHSEARCH_MARGIN;
        self.historySearchView.yh_y = self.hotSearches.count > 0 && self.showHotSearch ? CGRectGetMaxY(self.hotSearchView.frame)  + YHSEARCH_MARGIN : YHSEARCH_MARGIN;
       
    }else{
        
        self.historySearchView.yh_y = YHSEARCH_MARGIN;
        self.hotSearchView.yh_y = self.searchHistories.count > 0 && self.showSearchHistory ? CGRectGetMaxY(self.historySearchView.frame) + YHSEARCH_MARGIN : YHSEARCH_MARGIN;
    }
    
}

#pragma mark - setter


- (void)setHotSearchHeaderViewHeight:(int)hotSearchHeaderViewHeight {
    _hotSearchHeaderViewHeight = hotSearchHeaderViewHeight;
    [self resetHotSearchHeaderViewFrame];
}

- (void)setHistorySearchHeaderViewHeight:(int)historySearchHeaderViewHeight {
    _historySearchHeaderViewHeight = historySearchHeaderViewHeight;
    [self resetHistorySearchHeaderViewFrame];
}

- (void)setHotSearchHeaderLabelLeft:(int)hotSearchHeaderLabelLeft {
    _hotSearchHeaderLabelLeft = hotSearchHeaderLabelLeft;
    self.hotSearchLabel.frame = CGRectMake(hotSearchHeaderLabelLeft, 0, self.hotSearchView.yh_width - hotSearchHeaderLabelLeft * 2,  self.hotSearchHeaderViewHeight);

}

- (void)setHistorySearchHeaderLabelLeft:(int)historySearchHeaderLabelLeft {
    _historySearchHeaderLabelLeft = historySearchHeaderLabelLeft;
    self.historySearchLabel.frame = CGRectMake(historySearchHeaderLabelLeft, 0, self.historySearchHeaderView.yh_width - historySearchHeaderLabelLeft * 2, self.historySearchHeaderViewHeight);
}

-(void)resetHotSearchHeaderViewFrame {
    int headerHeight = self.hotSearchHeaderViewHeight;
    self.hotSearchHeaderView.frame = CGRectMake(0, 0, self.hotSearchView.yh_width, headerHeight);
    self.hotSearchLabel.frame = CGRectMake(self.hotSearchHeaderLabelLeft, 0, self.hotSearchView.yh_width - self.hotSearchHeaderLabelLeft * 2,  headerHeight);
    self.hotSearchTagsContentView.yh_y = CGRectGetMaxY(self.hotSearchHeaderView.frame);
}

-(void)resetHistorySearchHeaderViewFrame {
    int headerHeight = self.historySearchHeaderViewHeight;
    self.historySearchHeaderView.frame = CGRectMake(0, 0, self.historySearchView.yh_width, headerHeight);
    self.historySearchLabel.frame = CGRectMake(self.historySearchHeaderLabelLeft, 0, self.historySearchHeaderView.yh_width - self.historySearchHeaderLabelLeft * 2, headerHeight);
    self.emptyButton.frame = CGRectMake(self.historySearchView.yh_width - headerHeight, 0, headerHeight, headerHeight);
    self.emptyButton.yh_centerY = self.historySearchHeaderView.yh_centerY;
    self.searchHistoryTagsContentView.yh_y = self.historySearchHeaderViewHeight;
}


- (void)setShowHotSearch:(BOOL)showHotSearch
{
    _showHotSearch = showHotSearch;
    
    [self setHotSearches:self.hotSearches];
    [self setupHistorySearchNormalTags];
}

- (void)setShowSearchHistory:(BOOL)showSearchHistory
{
    _showSearchHistory = showSearchHistory;
    
    [self setHotSearches:self.hotSearches];
    [self setupHistorySearchNormalTags];
}

- (void)setSearchHistoriesCachePath:(NSString *)searchHistoriesCachePath
{
    _searchHistoriesCachePath = [searchHistoriesCachePath copy];
    
    self.searchHistories = nil;
    
    [self setupHistorySearchNormalTags];
    
}

- (void)setHotSearchTags:(NSArray<UIButton *> *)hotSearchTags
{
    
    for (int i = 0 ; i < hotSearchTags.count; i++) {
        UIButton *tagBtn = hotSearchTags[i];
        tagBtn.tag = 1000+i;
    }

    _hotSearchTags = hotSearchTags;
}


- (void)setHotSearches:(NSArray *)hotSearches
{
    
    [hotSearches enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            YHMethodParameterError();
            *stop = YES;
        }
    }];
    
    _hotSearches = hotSearches;
    if (0 == hotSearches.count || !self.showHotSearch) {
        self.hotSearchTagsContentView.hidden = YES;
        return;
    };
    
    self.tableView.tableHeaderView.hidden = NO;
    self.hotSearchTagsContentView.hidden = NO;
    [self setupHotSearchNormalTags];
}

-(void)setSearchTagConfigure:(YHSearchTagConfigure *)searchTagConfigure {
    
    _searchTagConfigure = searchTagConfigure;
    
    if (searchTagConfigure.textFieldCloseImage) {
        UIButton * button = [self.searchNavigaitonBarView.searchTextField valueForKey:@"_clearButton"];
        [button setImage:searchTagConfigure.textFieldCloseImage forState:UIControlStateNormal];
    }
    if (searchTagConfigure.searchIconImage) {
        self.searchNavigaitonBarView.searchIconImageView.image = searchTagConfigure.searchIconImage;
    }
    
    NSString * emptyBtnTitle = [NSBundle yh_localizedStringForKey:YHSearchEmptyButtonText];
    if (searchTagConfigure.searchHistoryDeleteTitle) {
        emptyBtnTitle = searchTagConfigure.searchHistoryDeleteTitle;
    }
    [_emptyButton setTitle:emptyBtnTitle forState:UIControlStateNormal];
    
    switch (self.searchTagConfigure.emptyBtnStyle) {
        case EmptyBtnStyleImage:
            [_emptyButton setImage:self.searchTagConfigure.searchHistoryDeleteImage forState:UIControlStateNormal];
            [_emptyButton setTitle:@"" forState:UIControlStateNormal];
            break;
        case EmptyBtnStyleTitle:
            [_emptyButton setTitle:emptyBtnTitle forState:UIControlStateNormal];
            [_emptyButton setImage:nil forState:UIControlStateNormal];
            break;
        case EmptyBtnStyleTitleImage:
            [_emptyButton setTitle:emptyBtnTitle forState:UIControlStateNormal];
            [_emptyButton setImage:self.searchTagConfigure.searchHistoryDeleteImage forState:UIControlStateNormal];
            break;
        default:
            [_emptyButton setImage:self.searchTagConfigure.searchHistoryDeleteImage forState:UIControlStateNormal];
            break;
    }
    
    
    [self setupHistorySearchNormalTags];
    
    [self setupHotSearchNormalTags];
    
}

- (void)setSearchSuggestions:(NSArray<NSString *> *)searchSuggestions
{
//    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:cellForRowAtIndexPath:)]) {
//        // set searchSuggestion is nil when cell of suggestion view is custom.
//        _searchSuggestions = nil;
//        return;
//    }
    
    _searchSuggestions = [searchSuggestions copy];
    self.searchSuggestionVC.searchSuggestions = [searchSuggestions copy];
    
    self.tableView.hidden = !self.searchSuggestionHidden && [self.searchSuggestionVC.tableView numberOfRowsInSection:0] && self.searchNavigaitonBarView.searchTextField.text.length!=0;
    self.searchSuggestionVC.view.hidden = self.searchSuggestionHidden || ![self.searchSuggestionVC.tableView numberOfRowsInSection:0] || self.searchNavigaitonBarView.searchTextField.text.length==0;
}


- (void)setupHistorySearchNormalTags
{
    if (!self.searchHistories.count || !self.showSearchHistory) {
        self.historySearchView.hidden = YES;
        self.searchHistoryTagsContentView.hidden = YES;
        self.historySearchView.hidden = YES;
        self.emptyButton.hidden = YES;
        return;
    };
    
    self.historySearchView.hidden = NO;
    self.searchHistoryTagsContentView.hidden = NO;
    self.historySearchView.hidden = NO;
    self.emptyButton.hidden = NO;
    
    
    NSMutableArray * tempArray = [self.searchHistories copy];
    
    if(tempArray.count > self.searchHistoriesShowCount) {
        tempArray = [tempArray subarrayWithRange:NSMakeRange(0, self.searchHistoriesShowCount)].mutableCopy;
    }
    
    if(self.searchHistoryStyle == YHSearchHistoryStyleCell) {
        self.searchHistoryTags = [self addAndLayoutTagsWithTagsContentView:self.searchHistoryTagsContentView tagTexts:tempArray isHot:NO cellStyle:YES];
    }else{
        self.searchHistoryTags = [self addAndLayoutTagsWithTagsContentView:self.searchHistoryTagsContentView tagTexts:tempArray isHot:NO];
    }
}


- (void)setupHotSearchNormalTags
{
    if(self.hotSearchStyle == YHHotSearchStyleCell) {
        self.hotSearchTags = [self addAndLayoutTagsWithTagsContentView:self.hotSearchTagsContentView tagTexts:[self.hotSearches copy] isHot:YES cellStyle:YES];
    }else{
        self.hotSearchTags = [self addAndLayoutTagsWithTagsContentView:self.hotSearchTagsContentView tagTexts:[self.hotSearches copy] isHot:YES];
    }
}

- (void)backDidClick
{
//    [self.searchNavigaitonBarView searchResignFirstResponder];
    [self.view endEditing:YES];
    
    if ([self.delegate respondsToSelector:@selector(didClickBack:)]) {
        [self.delegate didClickBack:self];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardDidShow:(NSNotification *)noti
{
    NSDictionary *info = noti.userInfo;
    self.keyboardHeight = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.keyboardShowing = YES;
}


- (void)emptySearchHistoryDidClick
{
    [self.searchHistories removeAllObjects];
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    [self setupHistorySearchNormalTags];
    [self setupHotSearchNormalTags];
}
//MARK: - tag标签点击
- (void)tagDidCLick:(UIGestureRecognizer * )tag
{
    UIView *tagView = (UIButton *)tag.view;
    
    if (tagView.tag == 0) {
        [self searchNavigaitonBarViewByTextFieldShouldReturn:self.searchNavigaitonBarView.searchTextField];
        return;
    }
    
    if (tagView.tag >= 1000) {//热门搜索
        
        NSInteger tag = tagView.tag - 1000;
        NSString * searchText = self.hotSearches[tag];
        self.searchNavigaitonBarView.searchTextField.text = searchText;
        
        if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectHotSearchAtIndex:searchText:)]) {
            BOOL isIntercept = [self.delegate searchViewController:self didSelectHotSearchAtIndex:[self.hotSearchTags indexOfObject:tagView] searchText:searchText];
            [self saveSearchCacheAndRefreshView:searchText];
            if (isIntercept) {
                return;
            }
            [self searchNavigaitonBarViewByTextFieldShouldReturn:self.searchNavigaitonBarView.searchTextField];
            
        } else {
            [self searchNavigaitonBarViewByTextFieldShouldReturn:self.searchNavigaitonBarView.searchTextField];
        }
        YHSEARCH_LOG(@"Hot Search text = %@", searchText);
        
    } else {
        
        NSString * searchText = self.searchHistories[tagView.tag];
        self.searchNavigaitonBarView.searchTextField.text = searchText;
        
        if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectSearchHistoryAtIndex:searchText:)]) {
            BOOL isIntercept = [self.delegate searchViewController:self didSelectSearchHistoryAtIndex:[self.searchHistoryTags indexOfObject:tagView] searchText:searchText];
            [self saveSearchCacheAndRefreshView:searchText];
            if (isIntercept) {
                return;
            }
            [self searchNavigaitonBarViewByTextFieldShouldReturn:self.searchNavigaitonBarView.searchTextField];
        } else {
            [self searchNavigaitonBarViewByTextFieldShouldReturn:self.searchNavigaitonBarView.searchTextField];
        }
        YHSEARCH_LOG(@"Histories Search text = %@", searchText);
    }
    
}
//MARK: - tag标签创建
/// 常见搜索btn
/// @param title 标题
/// @param tag tag值
/// @param isHot 区分历史搜索 和 热门搜索
- (UIView *)createTagViewWithTitle:(NSString *)title tag:(int)tag isHot:(BOOL)isHot
{
    NSString * subTitle = title;
    if (self.searchTagConfigure.historytTagTextDisplayLength && title.length > self.searchTagConfigure.historytTagTextDisplayLength && !isHot) {
        title = [title substringWithRange:NSMakeRange(0, self.searchTagConfigure.historytTagTextDisplayLength)];
        subTitle = [NSString stringWithFormat:@"%@...",title];
    }
    
    UIView *tagView = [[UIView alloc]init];
    tagView.tag = tag;
    tagView.userInteractionEnabled = YES;
    tagView.backgroundColor = self.searchTagConfigure.tagBackgroundColor;
    tagView.layer.cornerRadius = self.searchTagConfigure.tagCornerRadius;
    tagView.layer.borderWidth = self.searchTagConfigure.tagBorderWidth;
    tagView.layer.borderColor = self.searchTagConfigure.tagBorderColor.CGColor;
    tagView.clipsToBounds = YES;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.userInteractionEnabled = NO;
    btn.titleLabel.font = self.searchTagConfigure.tagFont;
    [btn setTitle:subTitle forState:UIControlStateNormal];
    [btn setTitleColor:self.searchTagConfigure.tagTitleColor forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [tagView addSubview:btn];
    [btn sizeToFit];
    btn.yh_width += self.searchTagConfigure.tagLeftPanding;
    btn.yh_height = self.searchTagConfigure.tagHeight;
    tagView.frame = btn.bounds;
    
    //删除按钮
    UIButton * clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn.tag = tag;
    clearBtn.userInteractionEnabled = YES;
    [clearBtn setImage:self.searchTagConfigure.searchHistoryItemDeleteImage forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    clearBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    //添加搜索历史单个删除按钮
    if(!isHot && self.searchHistoryStyle == YHSearchHistoryStyleCell 
       && !self.searchTagConfigure.searchHistoryItemDeleteImageNotShow) {
        [tagView addSubview:clearBtn];
        clearBtn.frame = CGRectMake(tagView.yh_width - self.searchTagConfigure.tagHeight, 0, self.searchTagConfigure.tagHeight, self.searchTagConfigure.tagHeight);
    }
    
    
    //自定义HotView
    if(isHot && self.hotSearchStyle == YHHotSearchStyleCell) {
        if (_delegate && [_delegate respondsToSelector:@selector(customHotTagView)]) {
            UIView *view = [self.delegate customHotTagView];
            view.tag = tag;
            view.userInteractionEnabled = YES;
            if (view) {
                if (_delegate && [_delegate respondsToSelector:@selector(getCustomTagView:title:index:isHot:)]) {
                    [_delegate getCustomTagView:view title:title index:tag isHot:isHot];
                }
                return view;
            }
        }
    }
    
    //自定义HistoryView
    if(!isHot && self.searchHistoryStyle == YHSearchHistoryStyleCell) {
        if (_delegate && [_delegate respondsToSelector:@selector(customHistoryTagView)]) {
            UIView *view = [self.delegate customHistoryTagView];
            view.tag = tag;
            view.userInteractionEnabled = YES;
            if (view) {
                if(!self.searchTagConfigure.searchHistoryItemDeleteImageNotShow) {
                    //添加搜索历史单个删除按钮
                    [view addSubview:clearBtn];
                    clearBtn.frame = CGRectMake(view.yh_width - self.searchTagConfigure.tagHeight, 0, self.searchTagConfigure.tagHeight, self.searchTagConfigure.tagHeight);
                }
                if (_delegate && [_delegate respondsToSelector:@selector(getCustomTagView:title:index:isHot:)]) {
                    [_delegate getCustomTagView:view title:title index:tag isHot:isHot];
                }
                return view;
            }
        }
    }
    

    
    return tagView;
}
//MARK: - 删除搜索历史
-(void)clearBtnClick:(UIButton *)sender
{
    if (self.searchHistories.count > sender.tag) {
        [self.searchHistories removeObjectAtIndex:sender.tag];
    }
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    [self setupHistorySearchNormalTags];
    
    if(self.searchHistories.count == 0) {
        [self setupHotSearchNormalTags];
    }
  
}
    
    
    
//MARK: - 保存搜索历史
- (void)saveSearchCacheAndRefreshView:(NSString * )searchText
{
//    [self.searchNavigaitonBarView searchResignFirstResponder];
    [self.view endEditing:YES];
    
//    NSString *searchText = self.searchNavigaitonBarView.searchTextField.text;
    if (self.removeSpaceOnSearchString) { // remove sapce on search string
        searchText = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    if (self.showSearchHistory) {
        if (searchText.length > 0) {
            [self.searchHistories removeObject:searchText];
            [self.searchHistories insertObject:searchText atIndex:0];
        }
        [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    }
}


- (void)closeDidClick:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    [self.searchHistories removeObject:cell.textLabel.text];
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"YHSEARCHHistoryCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.keyboardShowing) {
//        [self.searchNavigaitonBarView searchResignFirstResponder];
        [self.view endEditing:YES];
    }
}

//MARK: 自定义导航栏对外提供的的几个方法
//为满足自定义导航栏对外提供的的几个方法
/// 文本输入值,实时变化
-(void)searchNavigationBarSearchText:(NSString *)searchText {
    self.searchNavigaitonBarView.searchTextField.text = searchText;
    [self searchNavigaitonBarViewByTextFieldDidChange:self.searchNavigaitonBarView.searchTextField];
}
/// 清空文本功能
-(void)searchNavigationBarClearText {
    [self searchNavigaitonBarViewByTextFieldShouldClear:self.searchNavigaitonBarView.searchTextField];
}
/// 搜索功能
-(void)searchNavigationBarStartSearch:(NSString *)searchText {
    [self searchNavigaitonBarViewByTextFieldShouldReturn:self.searchNavigaitonBarView.searchTextField];
}

//MARK: - PPSearchNavigaitonBarViewDelegate

-(void)searchNavigaitonBarViewByTextFieldDidChange:(UITextField *)textField {
    
    NSLog(@"%@",textField.text);
    
    if (textField.text.length == 0) {
        self.searchNavigaitonBarView.searchTextField.placeholder = self.kSearchTextFieldPlaceholder;
    }
    
    self.tableView.hidden = textField.text.length && !self.searchSuggestionHidden && [self.searchSuggestionVC.tableView numberOfRowsInSection:0];
    self.searchSuggestionVC.view.hidden = self.searchSuggestionHidden || !textField.text.length || ![self.searchSuggestionVC.tableView numberOfRowsInSection:0];
    if (self.searchSuggestionVC.view.hidden) {
        self.searchSuggestions = nil;
    }
    [self.view bringSubviewToFront:self.searchSuggestionVC.view];
    
    
    if ([self.delegate respondsToSelector:@selector(searchViewController:searchTextDidChange:searchText:)]) {
        [self.delegate searchViewController:self searchTextDidChange:textField searchText:textField.text];
    }
    
    
    
}

-(BOOL)searchNavigaitonBarViewByTextFieldShouldReturn:(UITextField *)textField{
    
    //delegate 回调
    if ([self.delegate respondsToSelector:@selector(searchViewController:didSearchWithSearchTextField:searchText:)]) {
        [self.delegate searchViewController:self didSearchWithSearchTextField:textField searchText:textField.text];
        [self saveSearchCacheAndRefreshView:textField.text];
        return YES;
    }
    
    //block 回调
    if (![textField.text isEqualToString:@""]){
        self.searchNavigaitonBarView.searchTextField.placeholder = @"";
        if (self.didSearchBlock) self.didSearchBlock(self, textField, textField.text);
        [self saveSearchCacheAndRefreshView:textField.text];
        return YES;
    }

    return NO;
 
}

- (BOOL)searchNavigaitonBarViewByTextFieldShouldClear:(UITextField *)textField{
    
    self.searchNavigaitonBarView.searchTextField.placeholder = self.kSearchTextFieldPlaceholder;
    
    return YES;
     
    
}

-(void)onClickCancelButtonForSearchNavigaitonBarView:(YHSearchNavigationBarView *)searchNavigaitonBarView{
    
    [self.navigationController popViewControllerAnimated:NO];
    
}


#pragma mark - YHSearchSuggestionViewDataSource
- (NSInteger)numberOfSectionsInSearchSuggestionView:(UITableView *)searchSuggestionView
{
//    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInSearchSuggestionView:)]) {
//        return [self.dataSource numberOfSectionsInSearchSuggestionView:searchSuggestionView];
//    }
    return 1;
}

- (NSInteger)searchSuggestionView:(UITableView *)searchSuggestionView numberOfRowsInSection:(NSInteger)section
{
//    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:numberOfRowsInSection:)]) {
//        NSInteger numberOfRow = [self.dataSource searchSuggestionView:searchSuggestionView numberOfRowsInSection:section];
//        searchSuggestionView.hidden = self.searchSuggestionHidden || !self.searchBar.text.length || 0 == numberOfRow;
//        self.baseSearchTableView.hidden = !searchSuggestionView.hidden;
//        return numberOfRow;
//    }
    return self.searchSuggestions.count;
}

- (UITableViewCell *)searchSuggestionView:(UITableView *)searchSuggestionView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:cellForRowAtIndexPath:)]) {
//        return [self.dataSource searchSuggestionView:searchSuggestionView cellForRowAtIndexPath:indexPath];
//    }
    return nil;
}

- (CGFloat)searchSuggestionView:(UITableView *)searchSuggestionView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:heightForRowAtIndexPath:)]) {
//        return [self.dataSource searchSuggestionView:searchSuggestionView heightForRowAtIndexPath:indexPath];
//    }
    return 44.0;
}



@end


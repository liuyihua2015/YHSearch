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
 搜索历史 View
 */
@property (nonatomic, weak) UIView *headerView;

/**
 热门历史 View
 */
@property (nonatomic, weak) UIView *hotSearchView;

/**
  搜索历史 View
 */
@property (nonatomic, weak) UIView *searchHistoryView;

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
@property (nonatomic, weak) UIView *hotSearchTagsContentView;

/**
 搜索历史标签的内容视图
 */
@property (nonatomic, weak) UIView *searchHistoryTagsContentView;

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
        
        YHSearchTagConfigure * configure = [[YHSearchTagConfigure alloc]init];
        configure.historytTagTextDisplayLength = 0;
        configure.tagHotImage = [NSBundle yh_imageNamed:@"hot"];
        configure.tagBorderColor = [UIColor clearColor];
        configure.tagBorderWidth = 0;
        configure.tagCornerRadius = 5;
        configure.tagFont = [UIFont systemFontOfSize:12];
        configure.tagTitleColor = [UIColor yh_colorWithHexString:@"#999999"];
        configure.tagBackgroundColor = [UIColor yh_colorWithHexString:@"#F9F9F9"];
        
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
    
    [self.searchNavigaitonBarView.searchTextField resignFirstResponder];
    
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)searchViewControllerWithHotSearches:(NSArray<YHSearchHotWordsModel *> *)hotSearches searchTextFieldPlaceholder:(NSString *)placeholder
{
    YHSearchViewController *searchVC = [[self alloc] init];
    searchVC.hotSearches = hotSearches;
    searchVC.kSearchTextFieldPlaceholder = placeholder;
    searchVC.searchNavigaitonBarView.searchTextField.placeholder = placeholder;
    return searchVC;
}

+ (instancetype)searchViewControllerWithHotSearches:(NSArray<YHSearchHotWordsModel *> *)hotSearches searchTextFieldPlaceholder:(NSString *)placeholder didSearchBlock:(PYDidSearchBlock)block
{
    [hotSearches enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[YHSearchHotWordsModel class]]) {
            YHMethodParameterError();
            *stop = YES;
        }
    }];
    
    YHSearchViewController *searchVC = [self searchViewControllerWithHotSearches:hotSearches searchTextFieldPlaceholder:placeholder];
    searchVC.didSearchBlock = [block copy];
    return searchVC;
}


//MARK: - setupUI
- (void)setup
{

    [self.view addSubview:self.searchNavigaitonBarView];
    [self setupTableViewWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.searchNavigaitonBarView.frame), YHScreenW, YHScreenH - YH_NavgationFullHeight);
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationController.navigationBar.backIndicatorImage = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

    self.searchHistoriesCachePath = YHSEARCH_SEARCH_HISTORY_CACHE_PATH;
    self.searchHistoriesCount = 10;
    self.showSearchHistory = YES;
    self.showHotSearch = YES;
    self.hotSearchPositionIsUp = YES;
    self.showKeyboardWhenReturnSearchResult = YES;
    self.removeSpaceOnSearchString = YES;
    
    UIView *headerView = [[UIView alloc] init];
    headerView.yh_width = YHScreenW;
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIView *hotSearchView = [[UIView alloc] init];
    hotSearchView.yh_x = YHSEARCH_MARGIN;
    hotSearchView.yh_width = headerView.yh_width - hotSearchView.yh_x * 2;
    hotSearchView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UILabel *titleLabel = [self setupTitleLabel:[NSBundle yh_localizedStringForKey:YHSearchHotSearchText]];
    self.hotSearchHeader = titleLabel;
    [hotSearchView addSubview:titleLabel];
    UIView *hotSearchTagsContentView = [[UIView alloc] init];
    hotSearchTagsContentView.yh_width = hotSearchView.yh_width;
    hotSearchTagsContentView.yh_y = CGRectGetMaxY(titleLabel.frame) + YHSEARCH_MARGIN;
    hotSearchTagsContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [hotSearchView addSubview:hotSearchTagsContentView];
    [headerView addSubview:hotSearchView];
    self.hotSearchTagsContentView = hotSearchTagsContentView;
    self.hotSearchView = hotSearchView;
    self.headerView = headerView;
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] init];;
    
    self.hotSearches = nil;
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
            _swSelf.searchNavigaitonBarView.searchTextField.text = didSelectCell.textLabel.text;
            NSIndexPath *indexPath = [_swSelf.searchSuggestionVC.tableView indexPathForCell:didSelectCell];
            
            if ([_swSelf.delegate respondsToSelector:@selector(searchViewController:didSelectSearchSuggestionAtIndexPath:searchText:)]) {
                [_swSelf.delegate searchViewController:_swSelf didSelectSearchSuggestionAtIndexPath:indexPath searchText:didSelectCell.textLabel.text];
                [_swSelf saveSearchCacheAndRefreshView];
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


- (UIButton *)emptyButton
{
    if (!_emptyButton) {
        UIButton *emptyButton = [[UIButton alloc] init];
        emptyButton.titleLabel.font = self.searchHistoryHeader.font;
        [emptyButton setTitleColor:PYTextColor forState:UIControlStateNormal];
//        [emptyButton setTitle:[NSBundle yh_localizedStringForKey:YHSearchEmptyButtonText] forState:UIControlStateNormal];
        [emptyButton setImage:self.searchTagConfigure.searchHistoryDeleteImage forState:UIControlStateNormal];

        [emptyButton addTarget:self action:@selector(emptySearchHistoryDidClick) forControlEvents:UIControlEventTouchUpInside];
        [emptyButton sizeToFit];
        emptyButton.yh_width += YHSEARCH_MARGIN;
        emptyButton.yh_height += YHSEARCH_MARGIN;
        emptyButton.yh_centerY = self.searchHistoryHeader.yh_centerY;
        emptyButton.yh_x = self.searchHistoryView.yh_width - emptyButton.yh_width;
        emptyButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.searchHistoryView addSubview:emptyButton];
        _emptyButton = emptyButton;
    }
    return _emptyButton;
}

- (UIView *)searchHistoryTagsContentView
{
    if (!_searchHistoryTagsContentView) {
        UIView *searchHistoryTagsContentView = [[UIView alloc] init];
        searchHistoryTagsContentView.yh_width = self.searchHistoryView.yh_width;
        searchHistoryTagsContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        searchHistoryTagsContentView.yh_y = CGRectGetMaxY(self.hotSearchTagsContentView.frame) + YHSEARCH_MARGIN;
        [self.searchHistoryView addSubview:searchHistoryTagsContentView];
        _searchHistoryTagsContentView = searchHistoryTagsContentView;
    }
    return _searchHistoryTagsContentView;
}

- (UILabel *)searchHistoryHeader
{
    if (!_searchHistoryHeader) {
        UILabel *titleLabel = [self setupTitleLabel:[NSBundle yh_localizedStringForKey:YHSearchSearchHistoryText]];
        [self.searchHistoryView addSubview:titleLabel];
        _searchHistoryHeader = titleLabel;
    }
    return _searchHistoryHeader;
}

- (UIView *)searchHistoryView
{
    if (!_searchHistoryView) {
        UIView *searchHistoryView = [[UIView alloc] init];
        searchHistoryView.yh_x = self.hotSearchView.yh_x;
        searchHistoryView.yh_y = self.hotSearchView.yh_y;
        searchHistoryView.yh_width = self.headerView.yh_width - searchHistoryView.yh_x * 2;
        searchHistoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.headerView addSubview:searchHistoryView];
        _searchHistoryView = searchHistoryView;
    }
    return _searchHistoryView;
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

- (void)setupHotSearchNormalTags
{
    self.hotSearchTags = [self addAndLayoutTagsWithTagsContentView:self.hotSearchTagsContentView tagTexts:self.hotSearches isHotTag:YES];
}

- (void)setupSearchHistoryTags
{
    self.tableView.tableFooterView = nil;
    self.searchHistoryTagsContentView.yh_y = YHSEARCH_MARGIN;
    self.emptyButton.yh_y = self.searchHistoryHeader.yh_y - YHSEARCH_MARGIN * 0.5;
    self.searchHistoryTagsContentView.yh_y = CGRectGetMaxY(self.searchHistoryHeader.frame) + YHSEARCH_MARGIN;
    self.searchHistoryTags = [self addAndLayoutTagsWithTagsContentView:self.searchHistoryTagsContentView tagTexts:[self.searchHistories copy] isHotTag:NO];
}

- (NSArray *)addAndLayoutTagsWithTagsContentView:(UIView *)contentView tagTexts:(NSArray<id> *)tagTexts isHotTag:(BOOL)isHotTag
{
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *tagsM = [NSMutableArray array];
    for (int i = 0; i < tagTexts.count; i++) {
        UIButton * btn = nil;
        if (isHotTag) {
            YHSearchHotWordsModel * model = tagTexts[i];
            btn = [self tagBtnWithTitle:model.title tag:i isHotTag:isHotTag isShowHotImage:model.isShowHot];
        }else{
            btn = [self tagBtnWithTitle:tagTexts[i] tag:i isHotTag:isHotTag isShowHotImage:NO];
        }
       
        [btn addTarget:self action:@selector(tagDidCLick:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:btn];
        [tagsM addObject:btn];
    }
    
    CGFloat currentX = 0;
    CGFloat currentY = 0;
    CGFloat countRow = 0;
    CGFloat countCol = 0;
    //最后一个view，用于计算整个区域高度
    UIView * lastView = nil;
    
    //显示行数控制
    int maxCount = 0;
    if (isHotTag) {
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
            subView.yh_x = 0;
        
            countCol++;
            if ((maxCount >= 0) && (countCol > maxCount)) {
                subView.yh_y = 0;
                subView.yh_size = CGSizeZero;
            }else{
                subView.yh_y = (currentY += subView.yh_height) + YHSEARCH_MARGIN * countCol;
                lastView = subView;
            }
            
            currentX = subView.yh_width;
            countRow = 1;
            
        } else {//其余的tag
            if ((maxCount >= 0) && (countCol > maxCount)) {
                subView.yh_x = 0;
                subView.yh_y = 0;
                subView.yh_size = CGSizeZero;
            }else{
                subView.yh_x = (currentX += subView.yh_width) - subView.yh_width + YHSEARCH_MARGIN * countRow;
                subView.yh_y = currentY + YHSEARCH_MARGIN * countCol;
                lastView = subView;
            }
            
            countRow ++;
           
        }
        
    }
    
        
    contentView.yh_height = CGRectGetMaxY(lastView.frame);
    if (self.hotSearchTagsContentView == contentView) { // popular search tag
        self.hotSearchView.yh_height = CGRectGetMaxY(contentView.frame) + YHSEARCH_MARGIN * 2;
    } else if (self.searchHistoryTagsContentView == contentView) { // search history tag
        self.searchHistoryView.yh_height = CGRectGetMaxY(contentView.frame) + YHSEARCH_MARGIN * 2;
        
    }
    
    [self layoutForDemand];
    self.tableView.tableHeaderView.yh_height = self.headerView.yh_height = MAX(CGRectGetMaxY(self.hotSearchView.frame), CGRectGetMaxY(self.searchHistoryView.frame));
    self.tableView.tableHeaderView.hidden = NO;
    
    [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    return [tagsM copy];
}

- (void)layoutForDemand {
    
    if (self.hotSearchPositionIsUp) {
        
        self.hotSearchView.yh_y = YHSEARCH_MARGIN * 2;
        self.searchHistoryView.yh_y = self.hotSearches.count > 0 && self.showHotSearch ? CGRectGetMaxY(self.hotSearchView.frame) : YHSEARCH_MARGIN * 2;
       
    }else{
        
        self.searchHistoryView.yh_y = YHSEARCH_MARGIN * 2;
        self.hotSearchView.yh_y = self.searchHistories.count > 0 && self.showSearchHistory ? CGRectGetMaxY(self.searchHistoryView.frame) : YHSEARCH_MARGIN * 2;
    }
    
}

#pragma mark - setter

- (void)setHotSearchTitle:(NSString *)hotSearchTitle
{
    _hotSearchTitle = [hotSearchTitle copy];
    
    self.hotSearchHeader.text = _hotSearchTitle;
}

- (void)setSearchHistoryTitle:(NSString *)searchHistoryTitle
{
    _searchHistoryTitle = [searchHistoryTitle copy];
    self.searchHistoryHeader.text = _searchHistoryTitle;
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
        if (![obj isKindOfClass:[YHSearchHotWordsModel class]]) {
            YHMethodParameterError();
            *stop = YES;
        }
    }];
    
    _hotSearches = hotSearches;
    if (0 == hotSearches.count || !self.showHotSearch) {
        self.hotSearchHeader.hidden = YES;
        self.hotSearchTagsContentView.hidden = YES;
        
        return;
    };
    
    self.tableView.tableHeaderView.hidden = NO;
    self.hotSearchHeader.hidden = NO;
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
        self.searchHistoryHeader.hidden = YES;
        self.searchHistoryTagsContentView.hidden = YES;
        self.searchHistoryView.hidden = YES;
        self.emptyButton.hidden = YES;
        return;
    };
    
    self.searchHistoryHeader.hidden = NO;
    self.searchHistoryTagsContentView.hidden = NO;
    self.searchHistoryView.hidden = NO;
    self.emptyButton.hidden = NO;
    [self setupSearchHistoryTags];

}

- (void)backDidClick
{
    [self.searchNavigaitonBarView searchResignFirstResponder];
    
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
- (void)tagDidCLick:(UIButton *)tagBtn
{
        
    if (tagBtn.tag >= 1000) {//热门搜索
        
        NSInteger tag = tagBtn.tag - 1000;
        YHSearchHotWordsModel * model = self.hotSearches[tag];
        self.searchNavigaitonBarView.searchTextField.text = model.title;
        
        if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectHotSearchAtIndex:searchText:)]) {
            [self.delegate searchViewController:self didSelectHotSearchAtIndex:[self.hotSearchTags indexOfObject:tagBtn] searchText:model.title];
            [self saveSearchCacheAndRefreshView];
        } else {
            [self searchNavigaitonBarViewByTextFieldShouldReturn:self.searchNavigaitonBarView.searchTextField];
        }
        
        YHSEARCH_LOG(@"Hot Search text = %@", model.title);
        
    } else {
        
        NSString * searchText = self.searchHistories[tagBtn.tag];
        self.searchNavigaitonBarView.searchTextField.text = searchText;
        
        if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectSearchHistoryAtIndex:searchText:)]) {
            [self.delegate searchViewController:self didSelectSearchHistoryAtIndex:[self.searchHistoryTags indexOfObject:tagBtn] searchText:searchText];
            [self saveSearchCacheAndRefreshView];
        } else {
            [self searchNavigaitonBarViewByTextFieldShouldReturn:self.searchNavigaitonBarView.searchTextField];
        }
        YHSEARCH_LOG(@"Histories Search text = %@", searchText);
    }
    
}

/// 常见搜索btn
/// @param title 标题
/// @param tag tag值
/// @param isHotTag 区分历史搜索 和 热门搜索
/// @param isShowHotImage 热门搜索中的是否显示小的图标
- (UIButton *)tagBtnWithTitle:(NSString *)title tag:(int)tag isHotTag:(BOOL)isHotTag isShowHotImage:(BOOL)isShowHotImage
{
    
    if (self.searchTagConfigure.historytTagTextDisplayLength && title.length > self.searchTagConfigure.historytTagTextDisplayLength && !isHotTag) {
        title = [title substringWithRange:NSMakeRange(0, self.searchTagConfigure.historytTagTextDisplayLength)];
        title = [NSString stringWithFormat:@"%@...",title];
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    btn.userInteractionEnabled = YES;
    
    btn.titleLabel.font = self.searchTagConfigure.tagFont;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:self.searchTagConfigure.tagTitleColor forState:UIControlStateNormal];
    btn.backgroundColor = self.searchTagConfigure.tagBackgroundColor;
    btn.layer.cornerRadius = self.searchTagConfigure.tagCornerRadius;
    btn.layer.borderWidth = self.searchTagConfigure.tagBorderWidth;
    btn.layer.borderColor = self.searchTagConfigure.tagBorderColor.CGColor;
    btn.clipsToBounds = YES;
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [btn sizeToFit];
    
    if (isHotTag && isShowHotImage) {
    
        btn.yh_width += 52;
        [btn setImage:self.searchTagConfigure.tagHotImage forState:UIControlStateNormal];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
    
    }else{
        btn.yh_width += 30;
    }
    btn.yh_height = 30;
    
    return btn;
}
//MARK: - 保存搜索历史
- (void)saveSearchCacheAndRefreshView
{
    [self.searchNavigaitonBarView searchResignFirstResponder];
    
    NSString *searchText = self.searchNavigaitonBarView.searchTextField.text;
    if (self.removeSpaceOnSearchString) { // remove sapce on search string
        searchText = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    if (self.showSearchHistory && searchText.length > 0) {
        [self.searchHistories removeObject:searchText];
        [self.searchHistories insertObject:searchText atIndex:0];
        
        if (self.searchHistories.count > self.searchHistoriesCount) {
            [self.searchHistories removeLastObject];
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
        [self.searchNavigaitonBarView searchResignFirstResponder];
    }
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
        [self saveSearchCacheAndRefreshView];
        return YES;
    }
    
    //block 回调
    if (![textField.text isEqualToString:@""]){
        self.searchNavigaitonBarView.searchTextField.placeholder = @"";
        if (self.didSearchBlock) self.didSearchBlock(self, textField, textField.text);
        [self saveSearchCacheAndRefreshView];
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


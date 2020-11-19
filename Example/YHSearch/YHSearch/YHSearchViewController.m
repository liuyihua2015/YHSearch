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


#define PYRectangleTagMaxCol 3
#define PYTextColor YHSEARCH_COLOR(113, 113, 113)
#define YHSEARCH_COLORPolRandomColor self.colorPol[arc4random_uniform((uint32_t)self.colorPol.count)]

@interface YHSearchViewController () <PPSearchNavigaitonBarViewDelegate>

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

@end

@implementation YHSearchViewController

- (instancetype)init
{
    if (self = [super init]) {
        
        YHSearchTagConfigure * configure = [[YHSearchTagConfigure alloc]init];
        configure.tagTextDisplayLength = 0;
        configure.tagHotImageDisplayLength = 0;
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


- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(BOOL)fd_interactivePopDisabled{
    
    return YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
            
    
    // Adjust the view according to the `navigationBar.translucent`
    if (NO == self.navigationController.navigationBar.translucent) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.view.yh_y, 0);
        if (!self.navigationController.navigationBar.barTintColor) {
            self.navigationController.navigationBar.barTintColor = YHSEARCH_COLOR(249, 249, 249);
        }
    }
    
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

+ (instancetype)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches searchTextFieldPlaceholder:(NSString *)placeholder
{
    YHSearchViewController *searchVC = [[self alloc] init];
    searchVC.hotSearches = hotSearches;
    searchVC.kSearchTextFieldPlaceholder = placeholder;
    searchVC.searchNavigaitonBarView.searchTextField.placeholder = placeholder;
    return searchVC;
}

+ (instancetype)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches searchTextFieldPlaceholder:(NSString *)placeholder didSearchBlock:(PYDidSearchBlock)block
{
    YHSearchViewController *searchVC = [self searchViewControllerWithHotSearches:hotSearches searchTextFieldPlaceholder:placeholder];
    searchVC.didSearchBlock = [block copy];
    return searchVC;
}

//MARK: - PPSearchNavigaitonBarViewDelegate

-(BOOL)searchNavigaitonBarViewByTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
        
    NSLog(@"%@",textField.text);
    
    if (textField.text.length == 0) {
        self.searchNavigaitonBarView.searchTextField.placeholder = self.kSearchTextFieldPlaceholder;
    }

  
    if ([self.delegate respondsToSelector:@selector(searchViewController:searchTextDidChange:searchText:)]) {
        [self.delegate searchViewController:self searchTextDidChange:textField searchText:textField.text];
    }
    
    return YES;
 
    
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


//MARK: - setupUI
- (void)setup
{

    [self.view addSubview:self.searchNavigaitonBarView];
    [self setupTableViewWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.searchNavigaitonBarView.frame), YHScreenW, YHScreenH - 64);
    
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
    hotSearchView.yh_x = YHSEARCH_MARGIN * 1.5;
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
        _searchNavigaitonBarView = [[YHSearchNavigationBarView alloc]initWithFrame:CGRectMake(0, 0, self.view.yh_width, 64)];
        _searchNavigaitonBarView.delegate = self;
    }
    return _searchNavigaitonBarView;
}


- (UIButton *)emptyButton
{
    if (!_emptyButton) {
        UIButton *emptyButton = [[UIButton alloc] init];
        emptyButton.titleLabel.font = self.searchHistoryHeader.font;
        [emptyButton setTitleColor:PYTextColor forState:UIControlStateNormal];
//        [emptyButton setTitle:[NSBundle yh_localizedStringForKey:YHSearchEmptyButtonText] forState:UIControlStateNormal];
        [emptyButton setImage:[NSBundle yh_imageNamed:@"empty"] forState:UIControlStateNormal];
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

- (NSArray *)addAndLayoutTagsWithTagsContentView:(UIView *)contentView tagTexts:(NSArray<NSString *> *)tagTexts isHotTag:(BOOL)isHotTag;
{
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *tagsM = [NSMutableArray array];
    for (int i = 0; i < tagTexts.count; i++) {
        UIButton * btn = [self tagBtnWithTitle:tagTexts[i] tag:i isHotTag:isHotTag];
        [btn addTarget:self action:@selector(tagDidCLick:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:btn];
        [tagsM addObject:btn];
    }
    
    CGFloat currentX = 0;
    CGFloat currentY = 0;
    CGFloat countRow = 0;
    CGFloat countCol = 0;
    
    for (int i = 0; i < contentView.subviews.count; i++) {
        UILabel *subView = contentView.subviews[i];
        // When the number of search words is too large, the width is width of the contentView
        if (subView.yh_width > contentView.yh_width) subView.yh_width = contentView.yh_width;
        if (currentX + subView.yh_width + YHSEARCH_MARGIN * countRow > contentView.yh_width) {
            subView.yh_x = 0;
            subView.yh_y = (currentY += subView.yh_height) + YHSEARCH_MARGIN * ++countCol;
            currentX = subView.yh_width;
            countRow = 1;
        } else {
            subView.yh_x = (currentX += subView.yh_width) - subView.yh_width + YHSEARCH_MARGIN * countRow;
            subView.yh_y = currentY + YHSEARCH_MARGIN * countCol;
            countRow ++;
        }
    }
    
    contentView.yh_height = CGRectGetMaxY(contentView.subviews.lastObject.frame);
    if (self.hotSearchTagsContentView == contentView) { // popular search tag
        self.hotSearchView.yh_height = CGRectGetMaxY(contentView.frame) + YHSEARCH_MARGIN * 2;
    } else if (self.searchHistoryTagsContentView == contentView) { // search history tag
        self.searchHistoryView.yh_height = CGRectGetMaxY(contentView.frame) + YHSEARCH_MARGIN * 2;
    }
    
    [self layoutForDemand];
    self.tableView.tableHeaderView.yh_height = self.headerView.yh_height = MAX(CGRectGetMaxY(self.hotSearchView.frame), CGRectGetMaxY(self.searchHistoryView.frame));
    self.tableView.tableHeaderView.hidden = NO;
    
    // Note：When the operating system for the iOS 9.x series tableHeaderView height settings are invalid, you need to reset the tableHeaderView
    [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    return [tagsM copy];
}

- (void)layoutForDemand {
    
    if (self.hotSearchPositionIsUp) {
        
        self.hotSearchView.yh_y = YHSEARCH_MARGIN * 3;
        self.searchHistoryView.yh_y = self.hotSearches.count > 0 && self.showHotSearch ? CGRectGetMaxY(self.hotSearchView.frame) + YHSEARCH_MARGIN * 1.5 : YHSEARCH_MARGIN * 3;
       
    }else{
        
        self.searchHistoryView.yh_y = YHSEARCH_MARGIN * 3;
        self.hotSearchView.yh_y = self.searchHistories.count > 0 && self.showSearchHistory ? CGRectGetMaxY(self.searchHistoryView.frame) + YHSEARCH_MARGIN * 1.5 : YHSEARCH_MARGIN * 3;
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
    for (UIButton *tagBtn in hotSearchTags) {
        tagBtn.tag = 1;
    }
    _hotSearchTags = hotSearchTags;
}


- (void)setHotSearches:(NSArray *)hotSearches
{
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
    
    [self setupHistorySearchNormalTags];
    
    [self setupHotSearchNormalTags];
    
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
    self.searchNavigaitonBarView.searchTextField.text = tagBtn.titleLabel.text;
    if (1 == tagBtn.tag) {
        if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectHotSearchAtIndex:searchText:)]) {
            [self.delegate searchViewController:self didSelectHotSearchAtIndex:[self.hotSearchTags indexOfObject:tagBtn] searchText:tagBtn.titleLabel.text];
            [self saveSearchCacheAndRefreshView];
        } else {
            [self searchNavigaitonBarViewByTextFieldShouldReturn:self.searchNavigaitonBarView.searchTextField];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectSearchHistoryAtIndex:searchText:)]) {
            [self.delegate searchViewController:self didSelectSearchHistoryAtIndex:[self.searchHistoryTags indexOfObject:tagBtn] searchText:tagBtn.titleLabel.text];
            [self saveSearchCacheAndRefreshView];
        } else {
            [self searchNavigaitonBarViewByTextFieldShouldReturn:self.searchNavigaitonBarView.searchTextField];
        }
    }
    YHSEARCH_LOG(@"Search %@", tagBtn.titleLabel.text);
}

- (UIButton *)tagBtnWithTitle:(NSString *)title tag:(int)tag isHotTag:(BOOL)isHotTag
{
    
    if (self.searchTagConfigure.tagTextDisplayLength && title.length > self.searchTagConfigure.tagTextDisplayLength) {
        title = [title substringWithRange:NSMakeRange(0, self.searchTagConfigure.tagTextDisplayLength)];
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
    
    if (isHotTag && tag < self.searchTagConfigure.tagHotImageDisplayLength) {
    
        btn.yh_width += 40;
        [btn setImage:self.searchTagConfigure.tagHotImage forState:UIControlStateNormal];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0, 0)];
    
    }else{
        btn.yh_width += 30;
    }
    btn.yh_height += 8;
    
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


@end


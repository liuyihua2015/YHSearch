//
//  YHSearchViewController.m
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import "YHSearchViewController.h"
#import "YHSearchConst.h"
//#import "UINavigationController+FDFullscreenPopGesture.h"
//#import "XWMagicMoveAnimator.h"
//#import "UINavigationController+XWTransition.h"
//#import "UIViewController+XWTransition.h"


#define PYRectangleTagMaxCol 3
#define PYTextColor PYSEARCH_COLOR(113, 113, 113)
#define PYSEARCH_COLORPolRandomColor self.colorPol[arc4random_uniform((uint32_t)self.colorPol.count)]

@interface YHSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate,UITextFieldDelegate> {
    id <UIGestureRecognizerDelegate> _previousInteractivePopGestureRecognizerDelegate;
}

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
 The base table view  of search view controller
 */
@property (nonatomic, strong) UITableView *baseSearchTableView;
/**
 设备的当前方向
 */
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;
/**
 取消按钮的宽度
 */
@property (nonatomic, assign) CGFloat cancelButtonWidth;

/**
 搜索小按钮
 */
@property (strong , nonatomic) UIButton *searchButton;

/**
 自定义搜索框
 */
@property (strong , nonatomic) UITextField * kSearchTextField;

/**
 搜索框 Placeholder
 */
@property (copy   , nonatomic) NSString * kSearchTextFieldPlaceholder;

@end

@implementation YHSearchViewController

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self viewDidLayoutSubviews];
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
            
    if (self.cancelButtonWidth == 0) { // Just adapt iOS 11.2
        [self viewDidLayoutSubviews];
    }
    
    // Adjust the view according to the `navigationBar.translucent`
    if (NO == self.navigationController.navigationBar.translucent) {
        self.baseSearchTableView.contentInset = UIEdgeInsetsMake(0, 0, self.view.yh_y, 0);
        if (!self.navigationController.navigationBar.barTintColor) {
            self.navigationController.navigationBar.barTintColor = PYSEARCH_COLOR(249, 249, 249);
        }
    }
    
    if (YES == self.showKeyboardWhenReturnSearchResult) {
        [self.kSearchTextField becomeFirstResponder];
    }
    
    if (self.navigationController.viewControllers.count > 1) {
        _previousInteractivePopGestureRecognizerDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    
    //设置自定义导航栏
    [self setUpNav];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setSearchHistoryStyle];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.kSearchTextField resignFirstResponder];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = _previousInteractivePopGestureRecognizerDelegate;
    
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
    searchVC.kSearchTextField.placeholder = placeholder;
    return searchVC;
}

+ (instancetype)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches searchTextFieldPlaceholder:(NSString *)placeholder didSearchBlock:(PYDidSearchBlock)block
{
    YHSearchViewController *searchVC = [self searchViewControllerWithHotSearches:hotSearches searchTextFieldPlaceholder:placeholder];
    searchVC.didSearchBlock = [block copy];
    return searchVC;
}

#pragma mark - Lazy
-(UIButton *)searchButton{
    if (!_searchButton) {
         _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
           [_searchButton setImage:[UIImage imageNamed:@"group_home_search_gray"] forState:0];
           [_searchButton adjustsImageWhenHighlighted];
    }
    return _searchButton;
}
-(UITextField *)kSearchTextField{
    if (!_kSearchTextField) {
         _kSearchTextField= [[UITextField alloc]init];
         _kSearchTextField.placeholder = GetLocalResStr(@"home_store_product_search");
         _kSearchTextField.textColor = HZColorWithRGB(0x333333);
         _kSearchTextField.textAlignment = NSTextAlignmentLeft;
         //利用KVC更改textField站字符的颜色和大小
         [_kSearchTextField setValue:HZColorWithRGB(0x999999) forKeyPath:@"placeholderLabel.textColor"];
         [_kSearchTextField setValue:UIFont.pingFangFont(PPMainBodyFontValue) forKeyPath:@"placeholderLabel.font"];
         _kSearchTextField.font = UIFont.pingFangFont(PPMainBodyFontValue);
         _kSearchTextField.returnKeyType = UIReturnKeySearch;
         _kSearchTextField.delegate = self;
         _kSearchTextField.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _kSearchTextField;
}

//设置导航条
- (void)setUpNav
{
    self.baseNavigationView.dropShadow = NO;
    self.baseNavigationView.hiddenLeftBackBtn = YES;
    self.baseNavigationView.hiddenRightBtn = NO;
    [self.baseNavigationView.rightItemButton setTitle:GetLocalResStr(@"public_cancel") forState:UIControlStateNormal];
    self.baseNavigationView.rightItemButton.titleLabel.font = UIFont.pingFangFont(PPSubTitleFontValue);
    [self.baseNavigationView.rightItemButton setTitleColor: rgba(153, 153, 153, 1) forState:UIControlStateNormal];
    [self.baseNavigationView.rightItemButton setTitleColor: rgba(153, 153, 153, 1) forState:UIControlStateHighlighted];
        
    [DCSpeedy dc_chageControlCircularWith:self.baseNavigationView.topCenterView AndSetCornerRadius:15 SetBorderWidth:0.5 SetBorderColor:rgba(204, 204, 204, 1) canMasksToBounds:YES];
    
    [self.baseNavigationView.topCenterView addSubview:self.searchButton];
    [self.baseNavigationView.topCenterView addSubview:self.kSearchTextField];
    
    [self.baseNavigationView.topCenterView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15).priorityHigh();
        make.width.mas_equalTo(ScreenW - 15 - 60).priorityHigh();
    }];
    
     [_searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
         [make.left.mas_equalTo(self.baseNavigationView.topCenterView)setOffset:13];
         make.centerY.mas_equalTo(self.baseNavigationView.topCenterView);
         make.width.equalTo(@15);
         make.width.equalTo(@15);
     }];
         
     [_kSearchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
         [make.left.equalTo(_searchButton.mas_right)setOffset:9];
         make.top.mas_equalTo(self.baseNavigationView.topCenterView);
         make.height.mas_equalTo(self.baseNavigationView.topCenterView);
         make.right.mas_equalTo(self.baseNavigationView.topCenterView);
     }];
    
    __weak typeof(self) _weakSelf = self;
    self.baseNavigationView.rightItemClickBlock = ^{
        __strong typeof(_weakSelf) swSelf = _weakSelf;
        //取消点击
        [swSelf  backDidClick];
        
    };
    
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
     if (textField == self.kSearchTextField) {
        return YES;
     }
     return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField == self.kSearchTextField) {
        
        NSLog(@"%@",textField.text);
        
        if (textField.text.length == 0) {
            self.kSearchTextField.placeholder = self.kSearchTextFieldPlaceholder;
        }
    
      
        if ([self.delegate respondsToSelector:@selector(searchViewController:searchTextDidChange:searchText:)]) {
            [self.delegate searchViewController:self searchTextDidChange:self.kSearchTextField searchText:textField.text];
        }
        
        return YES;
    }
    
    return  NO;
    
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    if (textField == self.kSearchTextField) {

        if ([self.delegate respondsToSelector:@selector(searchViewController:didSearchWithSearchTextField:searchText:)]) {
            [self.delegate searchViewController:self didSearchWithSearchTextField:self.kSearchTextField searchText:textField.text];
            [self saveSearchCacheAndRefreshView];
            return YES;
        }
        
        if (![textField.text isEqualToString:@""]){
            self.kSearchTextField.placeholder = @"";
            if (self.didSearchBlock) self.didSearchBlock(self, self.kSearchTextField, textField.text);
            [self saveSearchCacheAndRefreshView];
            
        }
 
    }
    
   return  NO;
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    
    if (textField == self.kSearchTextField) {
        
         self.kSearchTextField.placeholder = self.kSearchTextFieldPlaceholder;
        
         return YES;
     }
     
    return   NO;
    
}

- (UITableView *)baseSearchTableView
{
    if (!_baseSearchTableView) {
        UITableView *baseSearchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kStatusBarAndNavigationBarHeight, ScreenW, ScreenH - kStatusBarAndNavigationBarHeight - kStatusBarHeight) style:UITableViewStyleGrouped];
        
        baseSearchTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if ([baseSearchTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) { // For the adapter iPad
//            baseSearchTableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        baseSearchTableView.backgroundColor = [UIColor whiteColor];
        baseSearchTableView.delegate = self;
        baseSearchTableView.dataSource = self;
        [self.view addSubview:baseSearchTableView];
        [self.view sendSubviewToBack:baseSearchTableView];
        _baseSearchTableView = baseSearchTableView;
    }
    return _baseSearchTableView;
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
        emptyButton.yh_width += PYSEARCH_MARGIN;
        emptyButton.yh_height += PYSEARCH_MARGIN;
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
        searchHistoryTagsContentView.yh_y = CGRectGetMaxY(self.hotSearchTagsContentView.frame) + PYSEARCH_MARGIN;
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
        
        if (self.isPostingSearch) {
             _searchHistories = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:self.searchPostingHistoriesCachePath]];
        }else{
             _searchHistories = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:self.searchHistoriesCachePath]];
        }
       
    }
    return _searchHistories;
}


- (void)setup
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.baseSearchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationController.navigationBar.backIndicatorImage = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    
    self.searchHistoriesCachePath = PYSEARCH_SEARCH_HISTORY_CACHE_PATH;
    self.searchPostingHistoriesCachePath = PYSEARCH_SEARCH_HISTORY_CACHE_PATH_POSTING;
    self.searchHistoriesCount = 20;
    self.showSearchHistory = YES;
    self.showHotSearch = YES;
    self.hotSearchPositionIsUp = YES;
    self.showKeyboardWhenReturnSearchResult = YES;
    self.removeSpaceOnSearchString = YES;
    
    UIView *headerView = [[UIView alloc] init];
    headerView.yh_width = PYScreenW;
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
 
    UIView *hotSearchView = [[UIView alloc] init];
    hotSearchView.yh_x = PYSEARCH_MARGIN * 1.5;
    hotSearchView.yh_width = headerView.yh_width - hotSearchView.yh_x * 2;
    hotSearchView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UILabel *titleLabel = [self setupTitleLabel:[NSBundle yh_localizedStringForKey:YHSearchHotSearchText]];
    self.hotSearchHeader = titleLabel;
    [hotSearchView addSubview:titleLabel];
    UIView *hotSearchTagsContentView = [[UIView alloc] init];
    hotSearchTagsContentView.yh_width = hotSearchView.yh_width;
    hotSearchTagsContentView.yh_y = CGRectGetMaxY(titleLabel.frame) + PYSEARCH_MARGIN;
    hotSearchTagsContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [hotSearchView addSubview:hotSearchTagsContentView];
    [headerView addSubview:hotSearchView];
    self.hotSearchTagsContentView = hotSearchTagsContentView;
    self.hotSearchView = hotSearchView;
    self.headerView = headerView;
    self.baseSearchTableView.tableHeaderView = headerView;
    self.baseSearchTableView.tableFooterView = [[UIView alloc] init];;
    
    self.hotSearches = nil;
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
    self.hotSearchTags = [self addAndLayoutTagsWithTagsContentView:self.hotSearchTagsContentView tagTexts:self.hotSearches];
}

- (void)setupSearchHistoryTags
{
    self.baseSearchTableView.tableFooterView = nil;
    self.searchHistoryTagsContentView.yh_y = PYSEARCH_MARGIN;
    self.emptyButton.yh_y = self.searchHistoryHeader.yh_y - PYSEARCH_MARGIN * 0.5;
    self.searchHistoryTagsContentView.yh_y = CGRectGetMaxY(self.emptyButton.frame) + PYSEARCH_MARGIN;
    self.searchHistoryTags = [self addAndLayoutTagsWithTagsContentView:self.searchHistoryTagsContentView tagTexts:[self.searchHistories copy]];
}

- (NSArray *)addAndLayoutTagsWithTagsContentView:(UIView *)contentView tagTexts:(NSArray<NSString *> *)tagTexts;
{
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *tagsM = [NSMutableArray array];
    for (int i = 0; i < tagTexts.count; i++) {
        UILabel *label = [self labelWithTitle:tagTexts[i]];
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick:)]];
        [contentView addSubview:label];
        [tagsM addObject:label];
    }
    
    CGFloat currentX = 0;
    CGFloat currentY = 0;
    CGFloat countRow = 0;
    CGFloat countCol = 0;
    
    for (int i = 0; i < contentView.subviews.count; i++) {
        UILabel *subView = contentView.subviews[i];
        // When the number of search words is too large, the width is width of the contentView
        if (subView.yh_width > contentView.yh_width) subView.yh_width = contentView.yh_width;
        if (currentX + subView.yh_width + PYSEARCH_MARGIN * countRow > contentView.yh_width) {
            subView.yh_x = 0;
            subView.yh_y = (currentY += subView.yh_height) + PYSEARCH_MARGIN * ++countCol;
            currentX = subView.yh_width;
            countRow = 1;
        } else {
            subView.yh_x = (currentX += subView.yh_width) - subView.yh_width + PYSEARCH_MARGIN * countRow;
            subView.yh_y = currentY + PYSEARCH_MARGIN * countCol;
            countRow ++;
        }
    }
    
    contentView.yh_height = CGRectGetMaxY(contentView.subviews.lastObject.frame);
    if (self.hotSearchTagsContentView == contentView) { // popular search tag
        self.hotSearchView.yh_height = CGRectGetMaxY(contentView.frame) + PYSEARCH_MARGIN * 2;
    } else if (self.searchHistoryTagsContentView == contentView) { // search history tag
        self.searchHistoryView.yh_height = CGRectGetMaxY(contentView.frame) + PYSEARCH_MARGIN * 2;
    }
    
    [self layoutForDemand];
    self.baseSearchTableView.tableHeaderView.yh_height = self.headerView.yh_height = MAX(CGRectGetMaxY(self.hotSearchView.frame), CGRectGetMaxY(self.searchHistoryView.frame));
    self.baseSearchTableView.tableHeaderView.hidden = NO;
    
    // Note：When the operating system for the iOS 9.x series tableHeaderView height settings are invalid, you need to reset the tableHeaderView
    [self.baseSearchTableView setTableHeaderView:self.baseSearchTableView.tableHeaderView];
    return [tagsM copy];
}

- (void)layoutForDemand {
    
    if (self.hotSearchPositionIsUp) {
        
        self.hotSearchView.yh_y = PYSEARCH_MARGIN * 3;
        self.searchHistoryView.yh_y = self.hotSearches.count > 0 && self.showHotSearch ? CGRectGetMaxY(self.hotSearchView.frame) + PYSEARCH_MARGIN * 1.5 : PYSEARCH_MARGIN * 3;
       
    }else{
        
        self.searchHistoryView.yh_y = PYSEARCH_MARGIN * 3;
        self.hotSearchView.yh_y = self.searchHistories.count > 0 && self.showSearchHistory ? CGRectGetMaxY(self.searchHistoryView.frame) + PYSEARCH_MARGIN * 1.5 : PYSEARCH_MARGIN * 3;
    }
    
   
}

#pragma mark - setter

-(void)setIsPostingSearch:(BOOL)isPostingSearch{
    
    _isPostingSearch = isPostingSearch;
    
     if (isPostingSearch) {
        self.searchHistories = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:self.searchPostingHistoriesCachePath]];
     }
    
    [self.baseSearchTableView reloadData];
}


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
    [self setSearchHistoryStyle];
}

- (void)setShowSearchHistory:(BOOL)showSearchHistory
{
    _showSearchHistory = showSearchHistory;
    
    [self setHotSearches:self.hotSearches];
    [self setSearchHistoryStyle];
}

- (void)setSearchHistoriesCachePath:(NSString *)searchHistoriesCachePath
{
    _searchHistoriesCachePath = [searchHistoriesCachePath copy];
    
    self.searchHistories = nil;
    
    [self setSearchHistoryStyle];
    
}
- (void)setSearchPostingHistoriesCachePath:(NSString *)searchPostingHistoriesCachePath
{
    _searchPostingHistoriesCachePath = [searchPostingHistoriesCachePath copy];
    
    self.searchHistories = nil;
    
    [self setSearchHistoryStyle];
    
}

- (void)setHotSearchTags:(NSArray<UILabel *> *)hotSearchTags
{
    for (UILabel *tagLabel in hotSearchTags) {
        tagLabel.tag = 1;
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
    
    self.baseSearchTableView.tableHeaderView.hidden = NO;
    self.hotSearchHeader.hidden = NO;
    self.hotSearchTagsContentView.hidden = NO;

    [self setupHotSearchNormalTags];

}

- (void)setSearchHistoryStyle
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
    [self.kSearchTextField resignFirstResponder];
    
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
    if (self.isPostingSearch) {
         [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchPostingHistoriesCachePath];
    }else{
         [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    }
   
    [self setSearchHistoryStyle];
    self.hotSearches = self.hotSearches;
    
}
//MARK: - tag标签点击
- (void)tagDidCLick:(UITapGestureRecognizer *)gr
{
    UILabel *label = (UILabel *)gr.view;
    self.kSearchTextField.text = label.text;
    if (1 == label.tag) {
        if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectHotSearchAtIndex:searchText:)]) {
            [self.delegate searchViewController:self didSelectHotSearchAtIndex:[self.hotSearchTags indexOfObject:label] searchText:label.text];
            [self saveSearchCacheAndRefreshView];
        } else {
            [self textFieldShouldReturn:self.kSearchTextField];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectSearchHistoryAtIndex:searchText:)]) {
            [self.delegate searchViewController:self didSelectSearchHistoryAtIndex:[self.searchHistoryTags indexOfObject:label] searchText:label.text];
            [self saveSearchCacheAndRefreshView];
        } else {
            [self textFieldShouldReturn:self.kSearchTextField];
        }
    }
    PYSEARCH_LOG(@"Search %@", label.text);
}

- (UILabel *)labelWithTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    label.userInteractionEnabled = YES;
    label.font = [UIFont systemFontOfSize:12];
    label.text = title;
    label.textColor = [UIColor yh_colorWithHexString:@"#999999"];
    label.backgroundColor = [UIColor yh_colorWithHexString:@"#F9F9F9"];
    label.layer.cornerRadius = 14;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.yh_width += 20;
    label.yh_height += 14;
    return label;
}
//MARK: - 保存搜索历史
- (void)saveSearchCacheAndRefreshView
{
    [self.kSearchTextField resignFirstResponder];
    NSString *searchText = self.kSearchTextField.text;
    if (self.removeSpaceOnSearchString) { // remove sapce on search string
        searchText = [self.kSearchTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    if (self.showSearchHistory && searchText.length > 0) {
        [self.searchHistories removeObject:searchText];
        [self.searchHistories insertObject:searchText atIndex:0];
        
        if (self.searchHistories.count > self.searchHistoriesCount) {
            [self.searchHistories removeLastObject];
        }
       if (self.isPostingSearch) {
             [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchPostingHistoriesCachePath];
        }else{
             [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
        }
    }
    
}


- (void)closeDidClick:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    [self.searchHistories removeObject:cell.textLabel.text];
    if (self.isPostingSearch) {
         [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchPostingHistoriesCachePath];
    }else{
         [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    }
    [self.baseSearchTableView reloadData];
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
    static NSString *cellID = @"PYSearchHistoryCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.keyboardShowing) {
        [self.kSearchTextField resignFirstResponder];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
    return self.navigationController.childViewControllers.count > 1;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return self.navigationController.viewControllers.count > 1;
}

@end


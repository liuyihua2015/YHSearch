//
//  YHSearchSuggestionViewController.h
//  FBSnapshotTestCase
//
//  Created by Yihua Liu on 2020/12/23.
//

#import <UIKit/UIKit.h>

typedef void(^YHSearchSuggestionDidSelectCellBlock)(UITableViewCell *selectedCell);

@protocol YHSearchSuggestionViewDataSource <NSObject, UITableViewDataSource>

@required
- (UITableViewCell *)searchSuggestionView:(UITableView *)searchSuggestionView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)searchSuggestionView:(UITableView *)searchSuggestionView numberOfRowsInSection:(NSInteger)section;
@optional
- (NSInteger)numberOfSectionsInSearchSuggestionView:(UITableView *)searchSuggestionView;
- (CGFloat)searchSuggestionView:(UITableView *)searchSuggestionView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface YHSearchSuggestionViewController : UITableViewController

@property (nonatomic, weak) id<YHSearchSuggestionViewDataSource> dataSource;
@property (nonatomic, copy) NSArray<NSString *> *searchSuggestions;
@property (nonatomic, copy) YHSearchSuggestionDidSelectCellBlock didSelectCellBlock;

+(instancetype)searchSuggestionViewControllerWithDidSelectCellBlock:(YHSearchSuggestionDidSelectCellBlock)didSelectCellBlock;

@end
